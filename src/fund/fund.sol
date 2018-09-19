pragma solidity ^0.4.24;

import '../common/Ownable.sol';
import '../common/SafeMath.sol';
import '../common/ERC20I.sol';

/**
 * @title DAO PlayMarket 2.0 Foundation contract
 */
contract PMFund is Ownable, SafeMath {

  bytes32 public version = "1.0.0";
    
  mapping (address => mapping (address => uint)) private foundation; // foundation[token][user] = balance
  
  /**
   * @dev Constructor sets default parameters
   */
  constructor() public {}
  
  function() public payable {}  
}