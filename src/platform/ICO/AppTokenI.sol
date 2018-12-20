pragma solidity ^0.4.24;

/**
 * @title AppToken interface (ERC223)
 * @dev see https://github.com/ethereum/EIPs/issues/223
 */
interface AppTokenI {

  function balanceOf(address _owner) external view returns (uint balance);
  
  function name() external view returns (string _name);
  function symbol() external view returns (string _symbol);
  function decimals() external view returns (uint256 _decimals);
  function totalSupply() external view returns (uint256 supply);

  function transfer(address to, uint value) external returns (bool ok);
  function transfer(address to, uint value, bytes data) external returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) external returns (bool ok);
  function transferFrom(address from, address to, uint value) external returns (bool ok);

  function TakeProfit() external returns (uint256);
  
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);  
}