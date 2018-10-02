pragma solidity ^0.4.24;

import '../../common/Ownable.sol';
import '../../common/ERC20.sol';
import '../../fund/PMFundI.sol';

/**
 * @title Application Token based on ERC20 token
 */
contract AppToken is ERC20, Ownable {
	
  bytes32 public version = "1.0.0";

  uint public initialSupply = 100 * 10**6;
  uint public decimals = 8;

  string public name;
  string public symbol;

  /** Name and symbol were updated. */
  event UpdatedTokenInformation(string _name, string _symbol);

  constructor(string _name, string _symbol, address _CrowdSale, address _PMFund, address _dev) public {
    name = _name;
    symbol = _symbol;

    totalSupply_ = initialSupply*10**decimals;
    // creating initial tokens
    balances[_CrowdSale] = totalSupply_;    
    emit Transfer(0x0, _CrowdSale, balances[_CrowdSale]);

    // send 5% - to DAO PlayMArket 2.0 Foundation
    uint value = safePerc(totalSupply_,5);
    balances[_CrowdSale] = safeSub(balances[_CrowdSale], value);
    balances[_PMFund] = value;
    // inform the fund about new tokens
    PMFundI(_PMFund).makeDeposit(address(this));
    emit Transfer(_CrowdSale, _PMFund, balances[_PMFund]);  

    // send 10% - to developer for the organization AirDrop/Bounty etc.
    value = safePerc(totalSupply_,10);
    balances[_CrowdSale] = safeSub(balances[_CrowdSale], value);
    balances[_dev] = value;
    emit Transfer(_CrowdSale, _dev, balances[_dev]);  

    // change owner
    owner = _CrowdSale;
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

  function getDecimals() public view returns (uint) {
    return decimals;
  }

  function getName() public view returns (string) {
    return name;
  }

  function getSymbol() public view returns (string) {
    return symbol;
  }
}
