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
    
  mapping (address => mapping (address => uint)) private fund; // fund[token][user] = balance
  
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
    require (offset < Tokens.length);
    require (limit <= Tokens.length);

    for (uint k = offset; k < limit; k++) {
      if (fund[Tokens[k].token][msg.sender] == 0) {
        // calc the number of tokens due
        uint _value = DAORepository.getBalance(msg.sender);      // get User balance in DAO Repository
        _value = safeDiv(safeMul(_value, 100), TotalPMT);        // calc the percentage of the total PMT
        _value = safePerc(fund[Tokens[k].token][address(this)], _value);
        // transfer balances
        fund[Tokens[k].token][address(this)] = safeSub(fund[Tokens[k].token][address(this)], _value);
        fund[Tokens[k].token][msg.sender] = safeAdd(fund[Tokens[k].token][msg.sender], _value);
      }
    }
  }

  // withdraw token
  function withdraw(address _token, uint _value) external {
    assert(_token != address(0));
    require(fund[_token][msg.sender] > 0);
    require(fund[_token][msg.sender] > _value);
    fund[_token][msg.sender] = safeSub(fund[_token][msg.sender], _value);
    require(AppTokenI(_token).transfer(msg.sender, _value));    
  }

  // withdraw token by DAO
  function withdraw(address _token, address _spender, uint _value) external onlyOwner {
    require(_token != address(0));
    require(fund[_token][_spender] > 0);
    require(fund[_token][_spender] > _value);
    fund[_token][_spender] = safeSub(fund[_token][_spender], _value);
    require(AppTokenI(_token).transfer(_spender, _value));    
  }

  function startFunding() external onlyAgent {
    require (!WithdrawIsBlocked);
    Tokens.length = 0;  // just in case

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
}