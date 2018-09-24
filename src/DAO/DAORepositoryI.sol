pragma solidity ^0.4.24;

/**
 * @title DAO PlayMarket 2.0 DAO repository interface
 */
interface DAORepositoryI {

  function addProposal(uint _propID, uint _endTime) external returns (uint);
  function changeProposal(uint _propID, uint _endTime) external;
  function delProposal(uint _id) external;
  function cleanProposal() external;

  function vote(uint _propID, address _voter, uint _numberOfVotes) external returns (bool);

  function getBalance(address _owner) external returns (uint);
  function getNotLockedBalance(address _owner) external returns (uint);
  
  // make deposit PMT
  // make sure, approve to this contract first
  function makeDeposit(address _from, uint _value) external;
  // refund deposit
  function changeStateByFund(bool _state) external;
  function setPMTContract(address _contract) external;
}