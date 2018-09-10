pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Developer contract interface 
 */
interface DeveloperI {

  function buyApp(address _dev, uint _value) external; 

  function registrationDeveloper(address _dev, bytes32 _name, bytes32 _info) external;
  function changeDeveloperInfo(address _dev, bytes32 _name, bytes32 _info) external;
  function changeDeveloperRaiting(address _dev, int _raiting) external;

  function checkConfirmation(address _dev) external constant returns (bool success);
  function confirmationDeveloper(address _dev, bool _value) external;

  function getRevenue(address _dev) external constant returns (uint256);

  function changeAutoConfirm(bool _autoConfirm) external;
  function changeDefRaiting(int _defRaiting) external;
}