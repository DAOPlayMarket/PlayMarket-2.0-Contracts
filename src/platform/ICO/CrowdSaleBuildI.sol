pragma solidity ^0.4.24;

/**
 * @title CrowdSale build contract (for apps ICO)
 */
interface CrowdSaleBuildI {
  
   /**
   * @dev 
   * @param _emission how many tokens will be released
   * @param _decimals decimals Tokens
   */
  function setInfo(uint _emission, uint _decimals, uint _duration) external;

  /**
   * @dev 
   * @param _contract address RateContract
   */
  function setRateContract(address _contract) external;
  
  /**
   * @dev CreateCrowdSaleContract - create new CrowdSale contract and return him address
   */   
  function CreateCrowdSaleContract(address _multisigWallet, uint _startsAt, uint _targetInUSD, address _dev) external returns (address);
}