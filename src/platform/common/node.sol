pragma solidity ^0.4.24;

import '../../Base.sol';
import '../../common/Agent.sol';
import '../../common/SafeMath.sol';
import '../storage/logStorageI.sol';
import '../storage/nodeStorageI.sol';

/**
 * @title Node contract - basic contract for working with nodes
 */
contract Node is Agent, SafeMath, Base {

  NodeStorageI public NodeStorage;

  event setStorageContractEvent(address _contract);

  // link to node storage
  function setNodeStorageContract(address _contract) public onlyOwner {
    NodeStorage = NodeStorageI(_contract);
    emit setStorageContractEvent(_contract);
  }

  function addNode(uint32 _hashType, bytes21 _reserv, string _hash, string _ip, string _coordinates) external {
    NodeStorage.addNode(msg.sender, _hashType, _reserv, _hash, _ip, _coordinates);
    LogStorage.addNodeEvent(msg.sender, _hashType, _reserv, _hash, _ip, _coordinates);
  }

  function changeNodeInfo(string _hash, uint32 _hashType, string _ip, string _coordinates) external {
    require(!NodeStorage.getState(msg.sender));
    NodeStorage.changeInfo(msg.sender, _hash, _hashType, _ip, _coordinates);
    LogStorage.changeInfoNodeEvent(msg.sender, _hash, _hashType, _ip, _coordinates);
  }  

  // request a collect the accumulated amount
  function requestCollectNode() external {
    require(!NodeStorage.getState(msg.sender));
    require(block.timestamp > NodeStorage.getCollectTime(msg.sender));
    NodeStorage.requestCollect(msg.sender);
    // ++ LogStorage
  }

  // collect the accumulated amount
  function collectNode() external {
    require(!NodeStorage.getState(msg.sender));    
    require(block.timestamp > NodeStorage.getCollectTime(msg.sender));
    NodeStorage.collect(msg.sender);
    // ++ LogStorage
  }

  // make an insurance deposit ETH and PMT
  // make sure, approve PMT to this contract first from address msg.sender
  function makeDeposit(address _node, uint _value) external payable {
    require(!NodeStorage.getState(_node));
    require(msg.value > 0 && _value > 0);
    require(address(NodeStorage).call.value(msg.value)(abi.encodeWithSignature("makeDeposit(address,address,uint)", _node, msg.sender, _value)));
  }  

  // make an insurance deposit ETH
  function makeDepositETH(address _node) external payable {
    require(!NodeStorage.getState(_node));
    require(msg.value > 0);
    require(address(NodeStorage).call.value(msg.value)(abi.encodeWithSignature("makeDepositETH(address)", _node)));
  }    

  // make an insurance deposit PMT
  // make sure, approve PMT to this contract first from address msg.sender
  function makeDepositPMT(address _node, uint _value) external payable {
    require(!NodeStorage.getState(_node));
    require(_value > 0);
    require(address(NodeStorage).call.value(0)(abi.encodeWithSignature("makeDepositPMT(address,address,uint)", _node, msg.sender, _value)));
  }

  // request a deposit refund
  function requestRefund() external {
    require(!NodeStorage.getState(msg.sender));
    uint _refundTime;
    (,,,,_refundTime,)=NodeStorage.getDeposit(msg.sender);
    require(block.timestamp > _refundTime);
    NodeStorage.requestRefund(msg.sender);
    // ++ LogStorage
  }

  // request a deposit refund
  function refund() external {
    require(!NodeStorage.getState(msg.sender));
    uint _refundTime;
    (,,,,_refundTime,)=NodeStorage.getDeposit(msg.sender);
    require(block.timestamp > _refundTime);
    NodeStorage.refund(msg.sender);
    // ++ LogStorage
  }

  function setConfirmationNode(address _node, bool _state) external onlyAgent {
    require(!NodeStorage.getState(_node));
    NodeStorage.setConfirmation(_node, _state);
    // ++ LogStorage     
  }

  function setDepositLimitsNode(address _node, uint _ETH, uint _PMT) external onlyAgent {
    require(!NodeStorage.getState(_node));
    require(_ETH > NodeStorage.getDefETH());
    require(_PMT > NodeStorage.getDefPMT());
    NodeStorage.setDepositLimits(_node, _ETH, _PMT);
  }
}
