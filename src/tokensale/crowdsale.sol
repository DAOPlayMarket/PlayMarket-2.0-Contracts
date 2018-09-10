pragma solidity ^0.4.24;

import '/src/common/SafeMath.sol';
import '/src/common/Agent.sol';
import '/src/common/ERC20.sol';
import '/src/common/RateI.sol';
import '/src/exchange/PEX.sol';

/**
 * @title StandartToken
 */
contract CrowdSale is ERC20, Ownable {

  string public name;
  string public symbol;
  uint public decimals;
  
  RateContractI public RateContract;
  address public developer;
  uint public countUse;
  uint public currentPeriod;
  uint public initialSupply_;
  bool public onceUse = false;
  bool public SoftCap;
  uint public totalInUSD;
  /* The UNIX timestamp start date of the crowdsale */
  uint public startsAt;
  
  /* Price in USD * 10**6 */
  uint[3] public price;
  
  /* How many unique addresses that have invested */
  uint public investorCount = 0;
  
  /* How many wei of funding we have raised */
  uint public weiRaised = 0;
  
  /* How many usd of funding we have raised */
  uint public usdRaised = 0;
  
  /* The number of tokens already sold through this contract*/
  uint public tokensSold = 0;
  
  /* How many tokens he charged for each investor's address in a particular period */
  mapping (uint => mapping (address => uint256)) public tokenAmountOfPeriod;
  
  /* How much ETH each address has invested to this crowdsale */
  mapping (address => uint256) public investedAmountOf;
  
  /* How much tokens this crowdsale has credited for each investor address */
  mapping (address => uint256) public tokenAmountOf;
  
  /* Wei will be transfered on this address */
  address public multisigWallet;
  
  /* How much wei we have given back to investors. */
  uint public weiRefunded = 0;

  /* A new investment was made */
  event Invested(address investor, uint weiAmount, uint tokenAmount);
  
  // Refund was processed for a contributor
  event Refund(address investor, uint weiAmount);
  // Coolect wei for developer
  event collectWei(address developer, uint _sum);
  
  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor(uint256 _initialSupply, uint _decimals, string _name, string _symbol, address _multisigWallet, uint _startsAt, uint _totalInUSD, address _DAOPlayMarket, address _RateContract, address _developer) public {
    decimals = _decimals;
    name = _name;
    symbol = _symbol;
    multisigWallet =_multisigWallet;
    startsAt = _startsAt;
    totalSupply_ = _initialSupply;
    initialSupply_ = _initialSupply;
    totalInUSD = _totalInUSD;
    RateContract = RateContractI(_RateContract);
    
    balances[_DAOPlayMarket] = safeDiv(safeMul(totalSupply_,15),100);
    emit Transfer(0x0, _DAOPlayMarket, balances[_DAOPlayMarket]);
    
    balances[msg.sender] = safeDiv(safeMul(totalSupply_,85),100);
    emit Transfer(0x0, msg.sender, balances[msg.sender]);
    
    developer = _developer;
    uint _price = safeDiv(_totalInUSD,40500000);
    price[0] = safeDiv(safeMul(_price,85),100);
    price[1] = safeDiv(safeMul(_price,90),100);
    price[2] = safeDiv(safeMul(_price,95),100);    
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
    currentPeriod = getStage();
    require(currentPeriod < 3);
    
    // Calculating the number of tokens
    uint tokenAmount = calculateTokens(weiAmount,currentPeriod);
    
    require(safeAdd(tokenAmount,tokensSold)<=(45*10**(6+decimals)));
    
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
    if(tokensSold > safeDiv(totalSupply_,100)) {
      SoftCap = true;
    }
    assignTokens(receiver, tokenAmount);

    // send ether to the fund collection wallet
    //multisigWallet.transfer(weiAmount);

    // Tell us invest was success
    emit Invested(receiver, weiAmount, tokenAmount);
	
  }
  
   /** 
   * @dev 
   */
  function getTokenDeveloper() public {
    require(getStage() == 3);
    require(msg.sender == developer);
    uint timePassed = block.timestamp - (startsAt + 90 days);
    uint countNow = safeDiv(timePassed,60 days);
    if(countNow > 10) {
      countNow = 10;
    }
    uint difference = safeSub(countNow,countUse);
    require(difference>0);
    uint sumToken = safeDiv((safeMul(safeSub(safeDiv(safeMul(totalSupply_,85),100),tokensSold),difference*10)),100);
    this.transfer(msg.sender, sumToken);
    countUse = safeAdd(countUse,difference);
  }
  
  /** 
   * @dev Gets the current stage.
   * @return uint current stage
   */
  function getStage() public constant returns (uint){
    if((block.timestamp < (startsAt + 30 days)) && (tokensSold < 15*10**(6+decimals))){
      return 0;
    }else if ((block.timestamp < (startsAt + 60 days)) && (tokensSold < 30*10**(6+decimals))){
      return 1;
    }else if ((block.timestamp < (startsAt + 90 days)) && (tokensSold < 45*10**(6+decimals))){
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
  function calculateTokens(uint weiAmount,uint period) internal constant returns (uint) {
    uint usdAmount = weiToUsdCents(weiAmount);
    uint multiplier = 10 ** decimals;
    return safeDiv(safeMul(multiplier, usdAmount),price[period]);
  }
  
  /**
   * @dev Converts wei value into USD cents according to current exchange rate
   * @param weiValue wei value to convert
   * @return USD cents equivalent of the wei value
   */
  function weiToUsdCents(uint weiValue) internal constant returns (uint) {
    return safeDiv(safeMul(weiValue, RateContract.getRate("ETH")), 1e14);
  }
  
  /**
   * Create new tokens or transfer issued tokens to the investor depending on the cap model.
   */
  function assignTokens(address receiver, uint tokenAmount) private {
     this.transfer(receiver, tokenAmount);
  }
 
  /**
   * @return true
   */
  function mint(address dst, uint wad) public onlyOwner returns (bool) {
    require(onceUse == false);
    onceUse = true;
    return super.transfer(dst, wad);
    
  }
  
  /**
   * @dev Investors can claim refund.
   */
  function refund() public {
    require(getStage() == 3 && SoftCap == false);
    uint256 weiValue = investedAmountOf[msg.sender];
    if (weiValue == 0){
      revert();
    }
    investedAmountOf[msg.sender] = 0;
    weiRefunded = safeAdd(weiRefunded, weiValue);
    emit Refund(msg.sender, weiValue);
    msg.sender.transfer(weiValue);
  }
  
  function collect(uint256 _sum) public {
    require(_sum > 0);
    require(getStage() == 3 && SoftCap == true);
    require(msg.sender == developer);
    multisigWallet.transfer(_sum);
    emit collectWei(developer, _sum);
  }

}