pragma solidity ^0.4.24;

import '../../common/SafeMath.sol';
import '../../common/AgentStorage.sol';
import '../../common/ERC20I.sol';
import './nodeStorageI.sol';

/**
 * @title Node Storage contract - contains info about Nodes
 */
contract NodeStorage is NodeStorageI, AgentStorage, SafeMath {

  struct _Node {
    uint32  hashType;   // default 0 - IPFS
    uint32  store;      // default 1
    bool state;         // service variable to determine the state of the structure
    bool confirmation;  // decides platform    
    bool collectState;  // true if the node requested a collect the accumulated amount    
    uint collectTime;   // after this time Node may collect the accumulated amount
    string hash;        // connect string
    string ip;          // IP address node
    string coordinates;
  }

  struct _InsuranceDeposit {
    uint ETH;           // current Node insurance deposit in ETH
    uint PMT;           // current Node insurance deposit in PMT
    uint minETH;        // current minimal insurance deposit in ETH for a specific Node
    uint minPMT;        // current minimal insurance deposit in PMT for a specific Node
    uint refundTime;    // after this time Node may get back insurance deposit (both)
    bool refundState;   // true if the node requested a refund deposit (can be a false, if the managing contract decides)
  }

  uint private defETH = 10 * 1 ether;         // default minimum deposit 10 ETH
  uint private defPMT = 5000 * 10**4;         // default minimum deposit 5000 PMT  
  uint private defRefundTime = 30 * 1 days;   // default time, after which you can refund deposit
  uint private defCollectTime = 15 * 1 days;  // default time, after which you can collect the accumulated amount

  ERC20I private PMTContract;
  
  mapping (address => _Node) private Nodes;
  mapping (address => uint) private NodesRevenue;
  mapping (address => _InsuranceDeposit) private NodesDeposit;

  constructor (address _PMT) public {
    PMTContract = ERC20I(_PMT);
  }
  
  function addNode(address _node, uint32 _hashType, string _hash, string _ip, string _coordinates) external onlyAgentStorage() {
    assert(!Nodes[_node].state);
    Nodes[_node]=_Node({
      hashType: _hashType,
      store: Agents[msg.sender].store,
      state: true,
      confirmation: false,
      collectState: false,      
      collectTime: 0,
      hash: _hash,
      ip: _ip,
      coordinates: _coordinates
    });

    // set the minimum insurance to default deposit
    _InsuranceDeposit storage dep = NodesDeposit[_node];
    dep.minETH = defETH;
    dep.minPMT = defPMT;
  }

  function changeInfo(address _node, string _hash, uint32 _hashType, string _ip, string _coordinates) external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    Nodes[_node].hash = _hash;
    Nodes[_node].hashType = _hashType;
    Nodes[_node].ip = _ip;
    Nodes[_node].coordinates = _coordinates;
  }

  function buyObject(address _node) payable external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].confirmation);
    //assert(msg.value > 0);
    NodesRevenue[_node] = safeAdd(NodesRevenue[_node], msg.value);  
  }

  // request a collect the accumulated amount
  function requestCollect(address _node) external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    assert(block.timestamp > Nodes[_node].collectTime);
    Nodes[_node].collectState = true;
    Nodes[_node].collectTime = block.timestamp + defCollectTime;
  }

  // collect the accumulated amount
  function collect(address _node) external onlyAgentStore(Nodes[_node].store) returns (uint) {
    assert(Nodes[_node].state);
    assert(Nodes[_node].collectState);
    assert(block.timestamp > Nodes[_node].collectTime);

    Nodes[_node].collectState = false;

    uint amount = NodesRevenue[_node];
    assert(amount > 0);
    NodesRevenue[_node] = 0;
    _node.transfer(amount);

    return amount;
  }  

  // make an insurance deposit ETH and PMT
  // make sure, approve to this contract first
  function makeDeposit(address _node, address _from, uint _value) payable external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    assert(msg.value > 0 && _value > 0);
    assert(PMTContract.transferFrom(_from, this, _value));
    NodesDeposit[_node].ETH = safeAdd(NodesDeposit[_node].ETH, msg.value);
    NodesDeposit[_node].PMT = safeAdd(NodesDeposit[_node].PMT, _value);
  }

  // make an insurance deposit ETH
  function makeDepositETH(address _node) payable external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    assert(msg.value > 0);
    NodesDeposit[_node].ETH = safeAdd(NodesDeposit[_node].ETH, msg.value);
  }

  // make an insurance deposit PMT
  // make sure, approve to this contract first
  function makeDepositPMT(address _node, address _from, uint _value) payable external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    assert(_value > 0);
    assert(PMTContract.transferFrom(_from, this, _value));
    NodesDeposit[_node].PMT = safeAdd(NodesDeposit[_node].PMT, _value);
  }

  // request a deposit refund
  function requestRefund(address _node) external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    assert(block.timestamp > NodesDeposit[_node].refundTime);
    NodesDeposit[_node].refundState = true;
    NodesDeposit[_node].refundTime = block.timestamp + defRefundTime;

    // in defRefundTime days will be able to receive an insurance deposit
    Nodes[_node].confirmation = false; 
  }

  // refund deposit
  function refund(address _node) external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    assert(NodesDeposit[_node].refundState);
    assert(block.timestamp > NodesDeposit[_node].refundTime);

    NodesDeposit[_node].refundState = false;
    uint amountETH = NodesDeposit[_node].ETH;
    uint amountPMT = NodesDeposit[_node].PMT;
    NodesDeposit[_node].ETH = 0;
    NodesDeposit[_node].PMT = 0;

    _node.transfer(amountETH);
    PMTContract.transfer(_node, amountPMT);
  }

  // redress of damage, call only by DAO
  function redress(address _node, uint _amountETH, uint _amountPMT, uint _revenueETH) external onlyOwner {
    assert(NodesDeposit[_node].ETH >= _amountETH 
      && NodesDeposit[_node].PMT >= _amountPMT
      && NodesRevenue[_node] >= _revenueETH);

    NodesDeposit[_node].ETH = safeSub(NodesDeposit[_node].ETH, _amountETH);
    NodesDeposit[_node].PMT = safeSub(NodesDeposit[_node].PMT, _amountPMT);
    NodesRevenue[_node] = safeSub(NodesRevenue[_node], _revenueETH);

    owner.transfer(_amountETH);
    PMTContract.transfer(owner, _amountPMT);
    owner.transfer(_revenueETH);
  }

  /************************************************************************* 
  // Nodes getters
  **************************************************************************/
  function getPMTContract() external view onlyOwner returns (address) {
    return PMTContract;
  }  

  function getHashType(address _node) external view onlyAgentStore(Nodes[_node].store) returns (uint32) {
    return Nodes[_node].hashType;
  }

  function getStore(address _node) external view onlyAgentStore(Nodes[_node].store) returns (uint32) {
    return Nodes[_node].store;
  }

  function getState(address _node) external view onlyAgentStore(Nodes[_node].store) returns (bool) {
    return Nodes[_node].state;
  }

  function getConfirmation(address _node) external view onlyAgentStore(Nodes[_node].store) returns (bool) {
    return Nodes[_node].confirmation;
  }

  function getCollectState(address _node) external view onlyAgentStore(Nodes[_node].store) returns (bool) {
    return Nodes[_node].collectState;
  }

  function getCollectTime(address _node) external view onlyAgentStore(Nodes[_node].store) returns (uint) {
    return Nodes[_node].collectTime;
  }

  function getHash(address _node) external view onlyAgentStore(Nodes[_node].store) returns (string) {
    return Nodes[_node].hash;
  }

  function getIP(address _node) external view onlyAgentStore(Nodes[_node].store) returns (string) {
    return Nodes[_node].ip;
  }

  function getCoordinates(address _node) external view onlyAgentStore(Nodes[_node].store) returns (string) {
    return Nodes[_node].coordinates;
  }

  function getInfo(address _node) external view onlyAgentStore(Nodes[_node].store) returns (uint32, bool, uint, string, string, string) {
    return (Nodes[_node].hashType,      
      Nodes[_node].collectState, 
      Nodes[_node].collectTime,
      Nodes[_node].hash,
      Nodes[_node].ip,
      Nodes[_node].coordinates);
  }

  function getRevenue(address _node) external view onlyAgentStore(Nodes[_node].store) returns (uint) {
    return NodesRevenue[_node];
  }

  function getDeposit(address _node) external view onlyAgentStore(Nodes[_node].store) returns (uint, uint, uint, uint, uint, bool) {
    return (NodesDeposit[_node].ETH, NodesDeposit[_node].PMT, NodesDeposit[_node].minETH, NodesDeposit[_node].minPMT, NodesDeposit[_node].refundTime, NodesDeposit[_node].refundState);
  }

  function getDefETH() external view onlyOwner returns (uint) {
    return defETH;
  }

  function getDefPMT() external view onlyOwner returns (uint) {
    return defPMT;
  }

  function getDefRefundTime() external view onlyOwner returns (uint) {
    return defRefundTime;
  }

  function getDefCollectTime() external view onlyOwner returns (uint) {
    return defCollectTime;
  }

  /************************************************************************* 
  // Nodes setters
  **************************************************************************/
  function setPMTContract(address _contract) external onlyOwner {
    PMTContract = ERC20I(_contract);
  }  

  function setHashType(address _node, uint32 _hashType) external onlyAgentStore(Nodes[_node].store) {
    Nodes[_node].hashType = _hashType;
  }

  function setStore(address _node, uint32 _store) external onlyOwner {
    Nodes[_node].store = _store;
  }

  function setConfirmation(address _node, bool _state) external onlyAgentStore(Nodes[_node].store) {
    assert(Agents[msg.sender].store == Nodes[_node].store); //not sure...
    Nodes[_node].confirmation = _state;
  }

  function setCollectState(address _node, bool _state) external onlyAgentStore(Nodes[_node].store) {    
    Nodes[_node].collectState = _state;
  }

  function setCollectTime(address _node, uint _time) external onlyAgentStore(Nodes[_node].store) {    
    Nodes[_node].collectTime = _time;
  }

  function setHash(address _node, string _hash) external onlyAgentStore(Nodes[_node].store) {
    Nodes[_node].hash = _hash;
  }

  function setIP(address _node, string _ip) external onlyAgentStore(Nodes[_node].store) {
    Nodes[_node].ip = _ip;
  }

  function setCoordinates(address _node, string _coordinates) external onlyAgentStore(Nodes[_node].store) {
    Nodes[_node].coordinates = _coordinates;
  }

  function setDepositLimits(address _node, uint _ETH, uint _PMT) external onlyAgentStore(Nodes[_node].store) {
    NodesDeposit[_node].minETH = _ETH;
    NodesDeposit[_node].minPMT = _PMT;

    if (NodesDeposit[_node].ETH < NodesDeposit[_node].minETH || NodesDeposit[_node].PMT < NodesDeposit[_node].minPMT) {
      Nodes[_node].confirmation = false;
    }    
  }

  function setDefETH(uint _ETH) external onlyOwner {
    defETH = _ETH;
  }

  function setDefPMT(uint _PMT) external onlyOwner {
    defPMT = _PMT;
  }

  function setDefRefundTime(uint _refundTime) external onlyOwner{
    defRefundTime = _refundTime;
  }

  function setDefCollectTime(uint _collectTime) external onlyOwner{
    defCollectTime = _collectTime;
  }
}
