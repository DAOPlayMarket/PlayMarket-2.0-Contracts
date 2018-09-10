pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Application contract interface 
 */
interface ApplicationI {
  
  function registrationApplication(string _hash, string _hashTag, bool _publish, uint256 _price, address _dev, uint _kind) external returns (uint256);  
  function confirmationApplication(uint _app, bool _status) external;
  function registrationApplicationICO(uint _app, string _hash, string _hashTag, address _dev) external;
  function changeHash(uint _app,  string _hash, string _hashTag, address _dev) external;
  function changePublish(uint _app, bool _publish, address _dev) external;
  function changePrice(uint _app, uint256 _price, address _dev) external;
  function changeIcoHash(uint _app, string _hash, string _hashTag, address _dev) external;
  function getDeveloper(uint _app) external constant returns (address);
  function buyApp(uint _app, address _user, uint _price) external;
  function buyObject(uint _app, address _user, uint _obj) external;
  function collectDeveloper(address _dev) external;
  function checkBuy(uint _app, address _user) external constant returns (bool success);
}