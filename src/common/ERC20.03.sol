pragma solidity ^0.4.25;

import './SafeMath.sol';
import './ERC20I.sol';

/**
 * @title Standard ERC20 token + balance on date
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20 
 */
contract ERC20 is ERC20I, SafeMath {
	
  uint256 totalSupply_;
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 public start = 0;         // Must be equal to the date of issue tokens
  uint256 public period;  // By default, the dividend accrual period is 30 days
  mapping (address => mapping (uint256 => int256)) public ChangeOverPeriod;

  address[] public owners;
  mapping (address => bool) public ownersIndex;

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
   * @dev Balance of tokens on date
   * @param _owner holder address
   * @return balance amount 
   */
  function balanceOf(address _owner, uint _date) public view returns (uint256) {
    require(_date >= start);
    uint256 N1 = (_date - start) / period + 1;
    uint256 N2 = (block.timestamp - start) / period + 1;
    require(N2 >= N1);

    int256 B = int256(balances[_owner]);

    while (N2 > N1) {
      B = B - ChangeOverPeriod[_owner][N2];
      N2--;
    }

    require(B >= 0);
    return uint256(B);
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

    if (ownersIndex[_to] == false && _value > 0) {
      ownersIndex[_to] = true;
      owners.push(_to);
    }
    
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);

    uint256 N = (block.timestamp - start) / period + 1;
    ChangeOverPeriod[msg.sender][N] = ChangeOverPeriod[msg.sender][N] - int256(_value);
    ChangeOverPeriod[_to][N] = ChangeOverPeriod[_to][N] + int256(_value);
   
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

    if (ownersIndex[_to] == false && _value > 0) {
      ownersIndex[_to] = true;
      owners.push(_to);
    }
    
    balances[_from] = safeSub(balances[_from], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);

    uint256 N = (block.timestamp - start) / period + 1;
    ChangeOverPeriod[_from][N] = ChangeOverPeriod[_from][N] - int256(_value);
    ChangeOverPeriod[_to][N] = ChangeOverPeriod[_to][N] + int256(_value);

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

  /** 
   * @dev Trim owners with zero balance
   */
  function trim(uint offset, uint limit) external returns (bool) { 
    uint k = offset;
    uint ln = limit;
    while (k < ln){
      if (balances[owners[k]] == 0) {
        ownersIndex[owners[k]] =  false;
        owners[k] = owners[owners.length-1];
        owners.length = owners.length-1;
        ln--;
      }else{
        k++;
      }
    }
    return true;
  }
}