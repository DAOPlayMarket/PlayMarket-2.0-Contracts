pragma solidity ^0.4.24;

/**
 * @title ICOList contract interface
 */
interface ICOListI {
  
  /**
   * @dev Create CrowdSale contract
   * @param _CSID - CrowdSale ID in array CrowdSales;
   */
  function CreateCrowdSale(address _multisigWallet, uint _startsAt, uint _targetInUSD, uint _CSID, uint _app, address _dev) external returns (address);  

  /**
   * @dev Create AppToken contract   
   * @param _ATID - AppToken ID in array AppTokens;
   */
  function CreateAppToken(string _name, string _symbol, address _crowdsale, uint _ATID, uint _app, address _dev) external returns (address);
  
  /**
   * @dev CreateICO 
   */
  function CreateICO(string _name, string _symbol, uint _decimals, uint _startsAt, uint _duration, uint _targetInUSD, address _crowdsale, address _apptoken, uint _app, address _dev) external;

  /**
   * @dev DeleteICO 
   */
  function DeleteICO(uint _app, address _dev) external;

  function setAppTokenContract(uint _ATID, address _contract) external;
  function setCrowdSaleContract(uint _CSID, address _contract) external;
  
  function setPMFund(address _PMFund) external;
  function setPEXContract(address _contract) external;
  // confirm ICO and add token to DAO PlayMarket 2.0 Exchange (DAOPEX)
  function setConfirmation(address _dev, uint _app, bool _state) external returns (address);

  function updateAgentStorage(address _agent, uint32 _store, bool _state) external;
}