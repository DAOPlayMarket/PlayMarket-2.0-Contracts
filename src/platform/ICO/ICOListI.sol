pragma solidity ^0.4.24;

/**
 * @title ICOList contract interface
 */
interface ICOListI {
  
  /**
   * @dev CreateICO 
   * @param _CSID - CrowdSale ID in array CrowdSales;
   * @param _ATID - AppToken ID in array AppTokens;
   */
  function CreateICO(string _name, string _symbol, uint _decimals, address _multisigWallet, uint _startsAt, uint _duration, uint _totalInUSD, uint _app, address _dev, uint _CSID, uint _ATID) external returns (address);

  /**
   * @dev DeleteICO 
   */
  function DeleteICO(uint _app, address _dev) external;
  
  function setPMFund(address _PMFund) external;
  function setPEXContract(address _contract) external;
  // confirm ICO and add token to DAO PlayMarket 2.0 Exchange (DAOPEX)
  function setConfirmation(address _dev, uint _app, bool _state) external returns (address);
}