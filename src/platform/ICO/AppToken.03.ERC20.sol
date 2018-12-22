pragma solidity ^0.4.24;

import '../../common/AppDAO.sol';

/**
 * @title CrowdSale interface to get wallet address
 */
interface CrowdSaleI {
    function Wallet() external returns (address);
}

/**
 * @title Application Token based on ERC20, AppDAO, AppDD
 */
contract AppToken is AppDAO {
	
  bytes32 public version = "ERC20 1.0.1";

  uint public initialSupply = 100 * 10**3; // default 100 thousand tokens
  uint public decimals = 8;

  string public name;
  string public symbol;

  address public Wallet;

  /** Name and symbol were updated. */
  event UpdatedTokenInformation(string _name, string _symbol);

  /** Period were updated. */
  event UpdatedPeriod(uint _period);

  constructor(string _name, string _symbol, address _CrowdSale, address _PMFund, address _dev) public {
    name = _name;
    symbol = _symbol;

    totalSupply_ = initialSupply*10**decimals;
    // creating initial tokens
    balances[_CrowdSale] = totalSupply_;    
    emit Transfer(0x0, _CrowdSale, balances[_CrowdSale]);

    // send 5% - to DAO PlayMarket 2.0 Foundation
    uint value = safePerc(totalSupply_,500);
    balances[_CrowdSale] = safeSub(balances[_CrowdSale], value);
    balances[_PMFund] = value;

    emit Transfer(_CrowdSale, _PMFund, balances[_PMFund]);  

    Wallet = CrowdSaleI(_CrowdSale).Wallet();
    require(Wallet != address(0));

    // send 55% - to developer for the organization AirDrop/Bounty etc.
    value = safePerc(totalSupply_,5500);
    balances[_CrowdSale] = safeSub(balances[_CrowdSale], value);
    balances[Wallet] = value;
    emit Transfer(_CrowdSale, Wallet, balances[Wallet]);  

    ChangeOverPeriod[_CrowdSale][1] = int256(balances[_CrowdSale]);
    owners.push(_CrowdSale);
    ChangeOverPeriod[_PMFund][1] = int256(balances[_PMFund]);
    owners.push(_PMFund);
    ChangeOverPeriod[Wallet][1] = int256(balances[Wallet]);
    owners.push(Wallet);

    // _minimumQuorum = safePerc(totalSupply_, 5000)
    // _requisiteMajority = safePerc(totalSupply_, 2500)
    // _debatingPeriodDuration = 60 minutes
    changeVotingRules(safePerc(totalSupply_, 5000), 60, safePerc(totalSupply_, 2500));
    
    // change owner
    owner = address(_CrowdSale);
  } 

  /**
  * Owner can update token information here.
  *
  * It is often useful to conceal the actual token association, until
  * the token operations, like central issuance or reissuance have been completed.
  *
  * This function allows the token owner to rename the token after the operations
  * have been completed and then point the audience to use the token contract.
  */
  function setTokenInformation(string _name, string _symbol) public onlyOwner {
    name = _name;
    symbol = _symbol;
    emit UpdatedTokenInformation(_name, _symbol);
  }


  /**
   * Owner can change start one time
   */
  function setStart(uint _start) external onlyOwner {
    require(start == 0);
    start = _start;    
  }

  /**
  * Owner can change period
  *
  */
  function setPeriod(uint _period) public onlyOwner {
    period = _period;
    emit UpdatedPeriod(_period);
    owner = address(this);
  }
}