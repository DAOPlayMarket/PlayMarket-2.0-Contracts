pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Node storage contract interface
 */
interface NodeStorageI {
  
  function addNode(address _node, uint32 _hashType, string _hash, string _ip, string _coordinates) external;
  function changeInfo(address _node, string _hash, uint32 _hashType, string _ip, string _coordinates) external;
  function buyObject(address _node) payable external;
  // request a collect the accumulated amount
  function requestCollect(address _node) external;
  // collect the accumulated amount
  function collect(address _node) external returns (uint);
  // make an insurance deposit ETH and PMT
  // make sure, approve to this contract first
  function makeDeposit(address _node, address _from, uint _value) payable external;
  // make an insurance deposit ETH
  function makeDepositETH(address _node) payable external;
  // make an insurance deposit PMT
  // make sure, approve to this contract first
  function makeDepositPMT(address _node, address _from, uint _value) payable external;
  // request a deposit refund
  function requestRefund(address _node, uint _requestETH, uint _requestPMT) external;
  // refund deposit
  function refund(address _node) external;

  function updateAgentStorage(address _agent, uint32 _store, bool _state) external;
  /************************************************************************* 
  // Nodes getters
  **************************************************************************/
  function getPMTContract() external view returns (address);
  function getHashType(address _node) external view returns (uint32);
  function getStore(address _node) external view returns (uint32);
  function getState(address _node) external view returns (bool);
  function getConfirmation(address _node) external view returns (bool);
  function getCollectState(address _node) external view returns (bool);
  function getCollectTime(address _node) external view returns (uint);
  function getHash(address _node) external view returns (string);
  function getIP(address _node) external view returns (string);
  function getCoordinates(address _node) external view returns (string);
  function getInfo(address _node) external view returns (uint32, bool, uint, string, string, string);
  function getRevenue(address _node) external view returns (uint);
  function getDeposit(address _node) external view returns (uint, uint, uint, uint, uint, bool);
  function getDefETH() external view returns (uint);
  function getDefPMT() external view returns (uint);
  function getDefRefundTime() external view returns (uint);
  /************************************************************************* 
  // Nodes setters
  **************************************************************************/
  function setPMTContract(address _contract) external;
  function setHashType(address _node, uint32 _hashType) external;
  function setStore(address _node, uint32 _store) external;
  function setConfirmation(address _node, bool _state) external;
  function setCollectState(address _node, bool _state) external;
  function setCollectTime(address _node, uint _time) external;
  function setHash(address _node, string _hash) external ;
  function setIP(address _node, string _ip) external ;
  function setCoordinates(address _node, string _coordinates) external ;
  function setDepositLimits(address _node, uint _ETH, uint _PMT) external;
  function setDefETH(uint _ETH) external;
  function setDefPMT(uint _PMT) external;
  function setDefRefundTime(uint _refundTime) external;
}