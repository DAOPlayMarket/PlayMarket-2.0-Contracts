pragma solidity ^0.4.24;

/**
 * @title DAO PlayMarket 2.0 Foundation contract interface
 */
interface PMFundI {

  // make deposit AppTokens on deploy token contract
  // call only one time to one token!
  function makeDeposit(address _token) external;
  // get AppTokens to sender address 
  function getTokens(uint offset, uint limit) external;
  // withdraw token
  function withdraw(address _token, uint _value) external;
  // withdraw token by DAO
  function withdraw(address _token, address _spender, uint _value) external;

  function startFunding() external;
  function stopFunding() external;

  function setTotalPMT(uint _value) external;
}