pragma solidity ^0.4.24;

import '../../common/ERC20I.sol';

/**
 * @title Application Token interface
 */
contract AppTokenI is ERC20I {

  function setTokenInformation(string _name, string _symbol) public;
  function getDecimals() public view returns (uint);
  function getName() public view returns (string);
  function getSymbol() public view returns (string);
}