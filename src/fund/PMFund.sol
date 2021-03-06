pragma solidity ^0.4.24;

import '../common/Agent.sol';
import '../common/SafeMath.sol';
import '../platform/ICO/AppTokenI.sol';
import '../DAO/DAORepositoryI.sol';
import './PMFundI.sol';

/**
 * @title DAO PlayMarket 2.0 Foundation contract
 */
contract PMFund is Agent, SafeMath {

  bytes32 public version = "1.0.0";

  bool public WithdrawIsBlocked = false;

  uint TotalPMT = 30000000000; // total count PMT tokens (decimals 4)

  struct _Token {
    address token;    // App Token address
    uint decimals;    // App Token decimals
    uint total;       // Total number of tokens transferred to PMFund
  }
  
  _Token[] public Tokens;   // contains only new Tokens!

  DAORepositoryI public DAORepository;
    
  mapping (address => mapping (address => uint)) private fund;      // fund[token][user] = balance of app tokens
  mapping (address => mapping (address => uint)) private withdrawn; // withdrawn[token][user] = balance of already withdrawn tokens
  uint private multiplier = 100000; // precision to ten thousandth percent (0.001%)
  
  /**
   * @dev Constructor sets default parameters
   */
  constructor(address _DAORepository) public {
    DAORepository = DAORepositoryI(_DAORepository);
  }
  
  function() public payable {}

  // make deposit AppTokens on deploy token contract
  // call only one time to one token!
  function makeDeposit(address _token) external onlyAgent {
    assert(_token != address(0));
    assert(fund[_token][address(this)] == 0);
    
    fund[_token][address(this)] = AppTokenI(_token).balanceOf(address(this));

    Tokens.push(_Token({
      token: _token,
      decimals: AppTokenI(_token).decimals(),
      total: fund[_token][address(this)]
    }));
  }

  // get AppTokens to sender address 
  function getTokens(uint offset, uint limit) external {
    require (WithdrawIsBlocked);
    require (limit <= Tokens.length);
    require (offset < limit);
    uint _value = 0;
    uint _balance = DAORepository.getBalance(msg.sender); // get User balance in DAO Repository
    uint k = 0;
    for (k = offset; k < limit; k++) {
      _value = safeSub(_balance, withdrawn[Tokens[k].token][msg.sender]); // calc difference between current balance and already withdrawn
      if (_value > 0) {
        withdrawn[Tokens[k].token][msg.sender] = _balance;        
        _value = safeMul(_value, multiplier);
        _value = safeDiv(safeMul(_value, 100), TotalPMT); // calc the percentage of the total PMT (from 100%)

        _value = safePerc(Tokens[k].total, _value);
        _value = safeDiv(_value, safeDiv(multiplier, 100));  // safeDiv(multiplier, 100) - convert to hundredths
        // transfer balances
        fund[Tokens[k].token][address(this)] = safeSub(fund[Tokens[k].token][address(this)], _value);
        fund[Tokens[k].token][msg.sender] = safeAdd(fund[Tokens[k].token][msg.sender], _value);
      }
    }
  }

  // withdraw token
  function withdraw(address _token, uint _value) external {
    assert(_token != address(0));
    require(fund[_token][msg.sender] >= _value);
    fund[_token][msg.sender] = safeSub(fund[_token][msg.sender], _value);
    require(AppTokenI(_token).transfer(msg.sender, _value));    
  }

  // withdraw token by DAO
  function withdraw(address _token, address _spender, uint _value) external onlyOwner {
    require(_token != address(0));
    require(fund[_token][_spender] >= _value);
    fund[_token][_spender] = safeSub(fund[_token][_spender], _value);
    require(AppTokenI(_token).transfer(_spender, _value));    
  }
  
  // withdraw token by DAO
  function withdrawPMfund(address _token, address _spender, uint _value) external onlyOwner {
    require(_token != address(0));
    require(fund[_token][address(this)] >= _value);
    fund[_token][address(this)] = safeSub(fund[_token][address(this)], _value);
    require(AppTokenI(_token).transfer(_spender, _value));    
  }

  function startFunding() external onlyAgent {
    require (!WithdrawIsBlocked);

    WithdrawIsBlocked = true;
    DAORepository.changeStateByFund(WithdrawIsBlocked);
  }
  
  function stopFunding() external onlyAgent {
    require (WithdrawIsBlocked);
    Tokens.length = 0;

    WithdrawIsBlocked = false;
    DAORepository.changeStateByFund(WithdrawIsBlocked);
  }

  function setTotalPMT(uint _value) external onlyOwner {
    assert(_value > 0);
    TotalPMT = _value;
  }
  
  function setMultiplier(uint _value) external onlyOwner {
    assert(_value > 0);
    multiplier = _value;
  }
  
  function getMultiplier() external view returns (uint ) {
    return multiplier;
  }
  
  function getFund(address _token, address _owner) external view returns (uint ) {
    return fund[_token][_owner];
  }

  function getWithdrawn(address _token, address _owner) external view returns (uint ) {
    return withdrawn[_token][_owner];
  }  
}