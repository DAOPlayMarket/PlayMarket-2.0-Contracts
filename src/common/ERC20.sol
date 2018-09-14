pragma solidity ^0.4.24;

import './SafeMath.sol';
import './ERC20I.sol';

/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20 
 */
contract ERC20 is ERC20I, SafeMath {
	
  uint256 totalSupply_;
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  /** 
   * @dev Total Supply
   * @return totalSupply_ 
   */  
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  
  /** 
   * @dev Tokens balance
   * @param _owner holder address
   * @return balance amount 
   */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }
  
  /** 
   * @dev Tranfer tokens to address
   * @param _to dest address
   * @param _value tokens amount
   * @return transfer result
   */
  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(_to != address(0));
    require(balances[msg.sender] >= _value);
    
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /** 
   * @dev Token allowance
   * @param _owner holder address
   * @param _spender spender address
   * @return remain amount
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**    
   * @dev Transfer tokens from one address to another
   * @param _from source address
   * @param _to dest address
   * @param _value tokens amount
   * @return transfer result
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_to != address(0));
    require(balances[_from] >= _value);
    require(allowed[_from][msg.sender] >= _value);
    
    balances[_from] = safeSub(balances[_from], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
    
    emit Transfer(_from, _to, _value);
    return true;
  }
  
  /** 
   * @dev Approve transfer
   * @param _spender holder address
   * @param _value tokens amount
   * @return result  
   */
  function approve(address _spender, uint256 _value) public returns (bool success) {
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _value;
    
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
}