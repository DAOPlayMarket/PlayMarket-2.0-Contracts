pragma solidity ^0.4.24;

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
  
  RateContractI public RateContract;
  AppTokenI public AppToken;

  address public dev;
  uint public countUse;  
  uint public totalSupply;  
  bool public SoftCap;
  uint public targetInUSD;
  /* The UNIX timestamp start date of the crowdsale */
  uint public startsAt;
  
  /* Price in USD * 10**6 */
  uint[3] public price;
  uint256 public numberOfPeriods;
  uint256 public durationOfPeriod;
  
  /* How many unique addresses that have invested */
  uint public investorCount = 0;
  
  /* How many wei of funding we have raised */
  uint public weiRaised = 0;
  
  /* How many usd of funding we have raised */
  uint public usdRaised = 0;
  
  /* The number of tokens already sold through this contract*/
  uint public tokensSold = 0;
  
  /* How many tokens he charged for each investor's address in a particular period */
  mapping (uint => mapping (address => uint)) public tokenAmountOfPeriod;
  
  /* How much ETH each address has invested to this crowdsale */
  mapping (address => uint) public investedAmountOf;
  
  /* How much tokens this crowdsale has credited for each investor address */
  mapping (address => uint) public tokenAmountOf;
  
  /* Wei will be transfered on this address */
  address public multisigWallet;
  
  /* How much wei we have given back to investors. */
  uint public weiRefunded = 0;

  uint public m15;
  uint public m30;
  uint public m45;

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

    require(_numberOfPeriods == 3);
    require(_durationOfPeriod == 30 days);

    owner =_owner;
    decimals = _decimals;
    multiplier = 10 ** decimals;
    multisigWallet =_multisigWallet;
    startsAt = _startsAt;
    totalSupply = _initialSupply;    
    targetInUSD = _targetInUSD;
    RateContract = RateContractI(_RateContract);
    numberOfPeriods =_numberOfPeriods;
    durationOfPeriod = _durationOfPeriod;
    
    dev = _dev;
    uint _price = safeDiv(_targetInUSD,40500000);
    price[0] = safePerc(_price,8500);
    price[1] = safePerc(_price,9000);
    price[2] = safePerc(_price,9500);

    m15 = 15*10**(6+decimals);
    m30 = 30*10**(6+decimals);
    m45 = 45*10**(6+decimals);
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
    
    uint weiAmount = msg.value;
   
    // Determine in what period we hit
    uint currentPeriod = getStage();
    require(currentPeriod < 3);
    
    // Calculating the number of tokens
    uint tokenAmount = calculateTokens(weiAmount,currentPeriod);
    
    require(safeAdd(tokenAmount,tokensSold) <= m45);
    
    if(investedAmountOf[receiver] == 0) {
       // A new investor
       investorCount++;
    }
    
    tokenAmountOfPeriod[currentPeriod][receiver]=safeAdd(tokenAmountOfPeriod[currentPeriod][receiver],tokenAmount);
	
    // Update investor
    investedAmountOf[receiver] = safeAdd(investedAmountOf[receiver],weiAmount);
    tokenAmountOf[receiver] = safeAdd(tokenAmountOf[receiver],tokenAmount);

    // Update totals
    weiRaised = safeAdd(weiRaised,weiAmount);
    tokensSold = safeAdd(tokensSold,tokenAmount);
    usdRaised = safeAdd(usdRaised,weiToUsdCents(weiAmount));

    if(tokensSold > safeDiv(totalSupply,100)) {
      SoftCap = true;
    }

    AppToken.transfer(receiver, tokenAmount);    

    // Tell us invest was success
    emit Invested(receiver, weiAmount, tokenAmount);	
  }
  
   /** 
   * @dev 
   */
  function getTokenDev() public {
    require(getStage() == 3);
    require(msg.sender == dev);
    uint timePassed = block.timestamp - (startsAt + 90 days);
    uint countNow = safeDiv(timePassed,60 days);
    if(countNow > 10) {
      countNow = 10;
    }
    uint difference = safeSub(countNow,countUse);
    require(difference > 0);
    uint sumToken = safeDiv((safeMul(safeSub(safePerc(totalSupply,8500),tokensSold),difference*10)),100);
    AppToken.transfer(msg.sender, sumToken);
    countUse = safeAdd(countUse,difference);
  }
  
  /** 
   * @dev Gets the current stage.
   * @return uint current stage
   */
  function getStage() public view returns (uint) {
    if((block.timestamp < (startsAt + 30 days)) && (tokensSold < m15)) {
      return 0;
    }else if ((block.timestamp < (startsAt + 60 days)) && (tokensSold < m30)) {
      return 1;
    }else if ((block.timestamp < (startsAt + 90 days)) && (tokensSold < m45)) {
      return 2;
    }
    return 3;
  }
  
    /**
   * @dev Calculating tokens count
   * @param weiAmount invested
   * @param period period
   * @return tokens amount
   */
  function calculateTokens(uint weiAmount,uint period) internal view returns (uint) {
    uint usdAmount = weiToUsdCents(weiAmount);    
    return safeDiv(safeMul(multiplier, usdAmount),price[period]);
  }
  
  /**
   * @dev Converts wei value into USD cents according to current exchange rate
   * @param weiValue wei value to convert
   * @return USD cents equivalent of the wei value
   */
  function weiToUsdCents(uint weiValue) internal view returns (uint) {
    return safeDiv(safeMul(weiValue, RateContract.getRate("ETH")), 1e14);
  }
  
  /**
   * @dev Investors can claim refund.
   */
  function refund() public {
    require(getStage() == 3 && SoftCap == false);
    uint weiValue = investedAmountOf[msg.sender];
    if (weiValue == 0){
      revert();
    }
    investedAmountOf[msg.sender] = 0;
    weiRefunded = safeAdd(weiRefunded, weiValue);
    emit Refund(msg.sender, weiValue);
    msg.sender.transfer(weiValue);
  }
  
  function collect(uint _sum) public {
    require(_sum > 0);
    require(getStage() == 3 && SoftCap == true);
    require(msg.sender == dev);
    multisigWallet.transfer(_sum);
    emit collectWei(dev, _sum);
  }

  function setTokenContract(address _contract) external onlyOwner {
    AppToken = AppTokenI(_contract);
  }
}