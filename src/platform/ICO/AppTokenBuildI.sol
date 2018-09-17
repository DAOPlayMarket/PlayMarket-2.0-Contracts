pragma solidity ^0.4.24;

/**
 * @title AppToken build contract interface (for apps ICO)
 */
interface AppTokenBuildI {
  
  /**
   * @dev CreateAppTokenContract - create new AppToken contract and return him address
   */   
  function CreateAppTokenContract(string _name, string _symbol, address _CrowdSale, address _PMFund) external returns (address);
}