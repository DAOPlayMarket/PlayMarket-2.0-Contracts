pragma solidity ^0.4.24;

/**
 * @title CrowdSale management contract interface
 */
contract CrowdSaleI {
  
  /**
   * @dev Investors can claim refund.
   */
  function refund() public;
  
  function collect(uint _sum) public;

  function setTokenContract(address _contract) external;
}