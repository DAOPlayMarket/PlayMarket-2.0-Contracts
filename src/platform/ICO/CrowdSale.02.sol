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
  
  uint public decimals;
  uint public multiplier;
    
  AppTokenI public AppToken;

  address public dev;
  uint public countUse;  
  uint public totalSupply;  
  /* The UNIX timestamp start date of the crowdsale */
  uint public startsAt;  
  
  uint[8] public price;
  uint256 public numberOfPeriods;
  uint256 public durationOfPeriod;
  uint256 public TokensInPeriod;
  
  /* How many unique addresses that have invested */
  uint public investorCount = 0;
  
  /* How many wei of funding we have raised */
  uint public weiRaised = 0;
  
  /* The number of tokens already sold through this contract*/
  uint public tokensSold = 0;
  
  /* How many tokens he charged in a particular period */
  mapping (uint => uint) public tokenAmountOfPeriod;
  
  /* How much ETH each address has invested to this crowdsale */
  mapping (address => uint) public investedAmountOf;
  
  /* How much tokens this crowdsale has credited for each investor address */
  mapping (address => uint) public tokenAmountOf;
  
  /* Wei will be transfered on this address */
  address public multisigWallet;
  
  /* How much wei we have given back to investors. */
  uint public weiRefunded = 0;

  /* A new investment was made */
  event Invested(address investor, uint weiAmount, uint tokenAmount);
  
  // Refund was processed for a contributor
  event Refund(address investor, uint weiAmount);

  // Coolect wei for dev
  event collectWei(address _dev, uint _sum);
  
  /**
   * @dev Constructor sets default parameters
   */
  constructor(uint _initialSupply, uint _decimals, address _multisigWallet, uint _startsAt, uint _numberOfPeriods, uint _durationOfPeriod, uint _targetInUSD, address _RateContract, address _dev, address _owner) public {

    owner =_owner;
    decimals = _decimals;
    multiplier = 10 ** decimals;
    multisigWallet =_multisigWallet;
    startsAt = _startsAt;
    totalSupply = 100 * 10**3;
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
    require(receiver != address(AppToken));
    
    uint weiAmount = msg.value;
   
    // Determine in what period we hit
    uint currentPeriod = getStage();
    require(currentPeriod > 0);

    if (price[currentPeriod] == 0) {
      // recalc price of tokens

    }
    
    // Calculating the number of tokens
    uint tokenAmount = safeDiv(weiAmount, price[currentPeriod]);
    
    require(safeAdd(tokenAmountOfPeriod[currentPeriod], tokenAmount) <= TokensInPeriod);

    if(investedAmountOf[receiver] == 0) {
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

    // Tell us invest was success
    emit Invested(receiver, weiAmount, tokenAmount);	
  }
  
   /** 
   * @dev 
   */
  function getTokenDev(uint _amount) public {
    require(getStage() == 9);
    require(msg.sender == dev);    
    AppToken.transfer(msg.sender, _amount);
  }
  
  /** 
   * @dev Gets the current stage.
   * @return uint current stage
   */
  function getStage() public view returns (uint) {    
    uint stage = (block.timestamp - startsAt) / durationOfPeriod;

    if (stage > 8) { return 8; }
    else { return stage; }
  }

  function collect(uint _sum) public {
    require(_sum > 0);    
    require(msg.sender == dev);
    multisigWallet.transfer(_sum);
    emit collectWei(dev, _sum);
  }

  function setTokenContract(address _contract) external onlyOwner {
    AppToken = AppTokenI(_contract);
  }
}