pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Node storage contract interface
 */
interface NodeStorageI {
  
  function addNode(address _node, uint32 _hashType, bytes21 _reserv, string _hash, string _ip, string _coordinates) external;
  function changeInfo(address _node, string _hash, uint32 _hashType, string _ip, string _coordinates) external;
  function buyObject(address _node) payable external;
  // request a collect the accumulated amount
  function requestCollect(address _node) external;
  // collect the accumulated amount
  function collect(address _node) external;
  // make an insurance deposit ETH and PMT
  // make sure, approve to this contract first
  function makeDeposit(address _node, address _from, uint256 _value) payable external;
  // make an insurance deposit ETH
  function makeDepositETH(address _node) payable external;
  // make an insurance deposit PMT
  // make sure, approve to this contract first
  function makeDepositPMT(address _node, address _from, uint256 _value) payable external;
  // request a deposit refund
  function requestRefund(address _node) external;
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
  function getReserv(address _node) external view returns (bytes21);
  function getHash(address _node) external view returns (string);
  function getIP(address _node) external view returns (string);
  function getCoordinates(address _node) external view returns (string);
  function getRevenue(address _node) external view returns (uint256);
  function getDeposit(address _node) external view returns (uint256, uint256, uint256, uint256, uint256, bool);
  function getDefETH() external view returns (uint256);
  function getDefPMT() external view returns (uint256);
  function getDefRefundTime() external view returns (uint256);
  /************************************************************************* 
  // Nodes setters
  **************************************************************************/
  function setPMTContract(address _contract) external;
  function setHashType(address _node, uint32 _hashType) external;
  function setStore(address _node, uint32 _store) external;
  function setConfirmation(address _node, bool _state) external;
  function setCollectState(address _node, bool _state) external;
  function setCollectTime(address _node, uint _time) external;
  function setReserv(address _node, bytes21 _reserv) external ;
  function setHash(address _node, string _hash) external ;
  function setIP(address _node, string _ip) external ;
  function setCoordinates(address _node, string _coordinates) external ;
  function setDepositLimits(address _node, uint256 _ETH, uint256 _PMT) external;
  function setDefETH(uint256 _ETH) external;
  function setDefPMT(uint256 _PMT) external;
  function setDefRefundTime(uint256 _refundTime) external;
}