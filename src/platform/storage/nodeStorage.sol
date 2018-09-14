pragma solidity ^0.4.24;

import '../../common/SafeMath.sol';
import '../../common/AgentStorage.sol';
import '../../common/ERC20I.sol';
import './nodeStorageI.sol';

/**
 * @title Node Storage contract - contains info about Nodes
 */
contract NodeStorage is NodeStorageI, AgentStorage, SafeMath {

  event confirmationNodeEvent(address _node, bool _state);
  event requestRefundNodeEvent(address _node, uint256 _refundTime);
  event refundNodeEvent(address _node, uint256 _ETH, uint256 _PMT);

  struct _Node {
    uint16  hashType;   // default 0 - IPFS
    uint32  store;      // default 1
    bool state;         // service variable to determine the state of the structure
    bool confirmation;  // decides platform    
    bytes24 reserv;
    string hash;        // connect string
    string ip;          // IP address node
    string coordinates;
  }

  struct _InsuranceDeposit {
    uint256 ETH;        // current Node insurance deposit in ETH
    uint256 PMT;        // current Node insurance deposit in PMT
    uint256 minETH;     // current minimal insurance deposit in ETH for a specific Node
    uint256 minPMT;     // current minimal insurance deposit in PMT for a specific Node
    uint256 refundTime; // after this time Node may get back insurance deposit (both)
    bool refundState;   // true if the node requested a refund deposit (can be a false, if the managing contract decides)
  }

  uint256 private defETH = 10 * 1 ether;        // default minimum deposit 10 ETH
  uint256 private defPMT = 5000 * 10**4;        // default minimum deposit 5000 PMT
  uint256 private defRefundTime = 30 * 1 days;  // default time, after which you can refund deposit

  ERC20I private PMTContract;
  
  mapping (address => _Node) private Nodes;
  mapping (address => uint256) private NodesRevenue;
  mapping (address => _InsuranceDeposit) private NodesDeposit;

  constructor (address _PMT) public {
    PMTContract = ERC20I(_PMT);
  }
  
  function addNode(address _node, uint16 _hashType, bytes24 _reserv, string _hash, string _ip, string _coordinates) external onlyAgentStore(Nodes[_node].store) {
    assert(!Nodes[_node].state);
    Nodes[_node]=_Node({
      hashType: _hashType,
      store: Agents[msg.sender].store,
      state: true,
      confirmation: false,
      reserv: _reserv,
      hash: _hash,
      ip: _ip,
      coordinates: _coordinates
    });
  }

  function changeInfo(address _node, string _hash, uint16 _hashType, string _ip, string _coordinates) external onlyAgentStore(Nodes[_node].store) {
    Nodes[_node].hash = _hash;
    Nodes[_node].hashType = _hashType;
    Nodes[_node].ip = _ip;
    Nodes[_node].coordinates = _coordinates;
  }

  function buyObject(address _node) payable external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    assert(msg.value > 0);
    if (NodesDeposit[_node].ETH > NodesDeposit[_node].minETH && NodesDeposit[_node].PMT > NodesDeposit[_node].minPMT) {
      NodesRevenue[_node] = safeAdd(NodesRevenue[_node], msg.value);  
    } else {
      Nodes[_node].confirmation = false;
      emit confirmationNodeEvent(_node, false);
    }    
  }

  // collect the accumulated amount
  function collect(address _node) external onlyAgentStore(Nodes[_node].store) {
    uint256 amount = NodesRevenue[_node];
    assert(amount > 0);
    NodesRevenue[_node] = 0;
    _node.transfer(amount);
  }

  // make an insurance deposit ETH and PMT
  // make sure, approve to this contract first
  function makeDeposit(address _node, address _from, uint256 _value) payable external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    assert(msg.value > 0 && _value > 0);
    assert(!PMTContract.transferFrom(_from, this, _value));
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
  function makeDepositPMT(address _node, address _from, uint256 _value) payable external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    assert(_value > 0);
    assert(!PMTContract.transferFrom(_from, this, _value));
    NodesDeposit[_node].PMT = safeAdd(NodesDeposit[_node].PMT, _value);
  }

  // request a deposit refund
  function requestRefund(address _node) external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    assert(block.timestamp > NodesDeposit[_node].refundTime);
    NodesDeposit[_node].refundState = true;
    NodesDeposit[_node].refundTime = block.timestamp + defRefundTime;

    emit requestRefundNodeEvent(_node, NodesDeposit[_node].refundTime);
  }

  // refund deposit
  function refund(address _node) external onlyAgentStore(Nodes[_node].store) {
    assert(Nodes[_node].state);
    assert(NodesDeposit[_node].refundState);
    assert(block.timestamp > NodesDeposit[_node].refundTime);

    NodesDeposit[_node].refundState = false;
    uint256 amountETH = NodesDeposit[_node].ETH;
    uint256 amountPMT = NodesDeposit[_node].PMT;
    NodesDeposit[_node].ETH = 0;
    NodesDeposit[_node].PMT = 0;

    _node.transfer(amountETH);
    PMTContract.approve(_node, amountPMT);

    emit refundNodeEvent(_node, amountETH, amountPMT);
  }

  /************************************************************************* 
  // Nodes getters
  **************************************************************************/
  function getPMTContract() external view onlyOwner returns (address) {
    return PMTContract;
  }  

  function getHashType(address _node) external view onlyAgentStore(Nodes[_node].store) returns (uint16) {
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

  function getReserv(address _node) external view onlyAgentStore(Nodes[_node].store) returns (bytes24) {
    return Nodes[_node].reserv;
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

  function getRevenue(address _node) external view onlyAgentStore(Nodes[_node].store) returns (uint256) {
    return NodesRevenue[_node];
  }

  function getDeposit(address _node) external view onlyAgentStore(Nodes[_node].store) returns (uint256, uint256, uint256, uint256, uint256, bool) {
    return (NodesDeposit[_node].ETH, NodesDeposit[_node].PMT, NodesDeposit[_node].minETH, NodesDeposit[_node].minPMT, NodesDeposit[_node].refundTime, NodesDeposit[_node].refundState);
  }

  function getDefETH() external view onlyOwner returns (uint256) {
    return defETH;
  }

  function getDefPMT() external view onlyOwner returns (uint256) {
    return defPMT;
  }

  function getDefRefundTime() external view onlyOwner returns (uint256) {
    return defRefundTime;
  }

  /************************************************************************* 
  // Nodes setters
  **************************************************************************/
  function setPMTContract(address _contract) external onlyOwner {
    PMTContract = ERC20I(_contract);
  }  

  function setHashType(address _node, uint16 _hashType) external onlyAgentStore(Nodes[_node].store) {
    Nodes[_node].hashType = _hashType;
  }

  function setStore(address _node, uint32 _store) external onlyOwner {
    Nodes[_node].store = _store;
  }

  function setConfirmation(address _node, bool _state) external onlyAgentStore(Nodes[_node].store) {
    assert(Agents[msg.sender].store == Nodes[_node].store); //not sure...
    Nodes[_node].confirmation = _state;
    emit confirmationNodeEvent(_node, _state);
  }

  function setReserv(address _node, bytes24 _reserv) external onlyAgentStore(Nodes[_node].store){
    Nodes[_node].reserv = _reserv;
  }

  function setHash(address _node, string _hash) external onlyAgentStore(Nodes[_node].store){
    Nodes[_node].hash = _hash;
  }

  function setIP(address _node, string _ip) external onlyAgentStore(Nodes[_node].store){
    Nodes[_node].ip = _ip;
  }

  function setCoordinates(address _node, string _coordinates) external onlyAgentStore(Nodes[_node].store){
    Nodes[_node].coordinates = _coordinates;
  }

  function setDepositLimits(address _node, uint256 _ETH, uint256 _PMT) external onlyAgentStore(Nodes[_node].store) {
    assert(_ETH > defETH);
    assert(_PMT > defPMT);
    NodesDeposit[_node].minETH = _ETH;
    NodesDeposit[_node].minPMT = _PMT;
  }

  function setDefETH(uint256 _ETH) external onlyOwner {
    defETH = _ETH;
  }

  function setDefPMT(uint256 _PMT) external onlyOwner {
    defETH = _PMT;
  }

  function setDefRefundTime(uint256 _refundTime) external onlyOwner{
    defRefundTime = _refundTime;
  }
}