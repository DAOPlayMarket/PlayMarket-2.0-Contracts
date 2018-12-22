pragma solidity ^0.4.25;

import '../../common/Ownable.sol';
import '../../common/SafeMath.sol';
import './AppTokenI.sol';
import '../../common/RateContractI.sol';
import '../../exchange/PEXI.sol';

/**
 * @title CrowdSale management contract 
 */
contract CrowdSale is Ownable, SafeMath {

  bytes32 public version = "1.0.0";
  
  uint256 public decimals;
  uint256 public multiplier;
    
  AppTokenI public AppToken;

  uint256 ROIM = 6; // default ROIM = 6 month

  address public dev;
  uint256 public countUse;  
  uint256 public totalSupply;  
  /* The UNIX timestamp start date of the crowdsale */
  uint256 public startsAt;  
  
  uint256[8] public price;
  uint256[8] public earned;

  uint256 public numberOfPeriods;
  uint256 public durationOfPeriod;
  uint256 public TokensInPeriod;
  
  /* How many unique addresses that have invested */
  uint256 public investorCount = 0;
  
  /* How many wei of funding we have raised */
  uint256 public weiRaised = 0;
  
  /* The number of tokens already sold through this contract*/
  uint256 public tokensSold = 0;
  
  /* How many tokens he charged in a particular period */
  mapping (uint256 => uint256) public tokenAmountOfPeriod;
  
  /* How much ETH each address has invested to this crowdsale */
  mapping (address => uint256) public investedAmountOf;
  
  /* How much tokens this crowdsale has credited for each investor address */
  mapping (address => uint256) public tokenAmountOf;
  
  /* Wei will be transfered on this address */
  address public Wallet;
  
  /* A new investment was made */
  event Invested(address investor, uint256 weiAmount, uint256 tokenAmount);
  
  /**
   * @dev Constructor sets default parameters
   */
  constructor(uint256 _initialSupply, uint256 _decimals, address _Wallet, uint256 _startsAt, uint256 _numberOfPeriods, uint256 _durationOfPeriod, uint256 _targetInUSD, address _RateContract, address _dev, address _owner) public {

    owner =_owner;
    decimals = _decimals;
    multiplier = 10 ** decimals;
    Wallet =_Wallet;
    startsAt = _startsAt;
    totalSupply = _initialSupply;
    numberOfPeriods =_numberOfPeriods;
    durationOfPeriod = _durationOfPeriod;
    TokensInPeriod = safePerc(totalSupply, 500); // 5%
    
    dev = _dev;
  }
  
  /**
   * Buy tokens from the contract
   */
  function() public payable {
    investInternal(msg.sender);
  }
  
  /**
   * Make an investment.
   *
   * Crowdsale must be running for one to invest.
   * We must have not pressed the emergency brake.
   *
   * @param receiver The Ethereum address who receives the tokens
   *
   */
  function investInternal(address receiver) private {
    require(msg.value > 0);
    require(block.timestamp > startsAt);

    if (receiver == address(AppToken)) {
      dev.transfer(msg.value);
      return;
    }
    
    uint256 weiAmount = msg.value;
   
    // Determine in what period we hit
    uint256 currentPeriod = 0;
    if (block.timestamp > startsAt) {
      currentPeriod = (block.timestamp - startsAt) / durationOfPeriod;
    }
    
    if (currentPeriod > 8) {
      currentPeriod = 8;
    }

    require(currentPeriod > 0);

    if (price[currentPeriod] == 0) {
      // recalc price of tokens
      earned[currentPeriod] = AppToken.TakeProfit();
      price[currentPeriod] = safeDiv(safeMul(safeMul(earned[currentPeriod], ROIM), multiplier), totalSupply);
      require(price[currentPeriod] > 0);
    }
    
    // Calculating the number of tokens
    uint256 tokenAmount = safeDiv(safeMul(weiAmount, multiplier), price[currentPeriod]);
    
    require(safeAdd(tokenAmountOfPeriod[currentPeriod], tokenAmount) <= TokensInPeriod);

    if (investedAmountOf[receiver] == 0) {
       // A new investor
       investorCount++;
    }
    
    tokenAmountOfPeriod[currentPeriod] = safeAdd(tokenAmountOfPeriod[currentPeriod], tokenAmount);
	
    // Update investor
    investedAmountOf[receiver] = safeAdd(investedAmountOf[receiver], weiAmount);
    tokenAmountOf[receiver] = safeAdd(tokenAmountOf[receiver], tokenAmount);

    // Update totals
    weiRaised = safeAdd(weiRaised, weiAmount);
    tokensSold = safeAdd(tokensSold, tokenAmount);

    AppToken.transfer(receiver, tokenAmount);
    Wallet.transfer(weiAmount);

    // Tell us invest was success
    emit Invested(receiver, weiAmount, tokenAmount);	
  }

  function setTokenContract(address _contract) external onlyOwner {
    AppToken = AppTokenI(_contract);
    // sync start date
    AppToken.setStart(startsAt);
    // sync duration of period
    AppToken.setPeriod(durationOfPeriod);
    // set owner to AppDAO
    owner = address(AppToken);
  }

  function setROIM(uint256 _ROIM) external onlyOwner {
    ROIM = _ROIM;
  }

  // withdraw dividends during STO to dev address
  function withdraw(uint256 _value) external {
    AppToken.withdraw(_value);
  }  
}