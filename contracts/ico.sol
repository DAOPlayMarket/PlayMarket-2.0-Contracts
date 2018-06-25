pragma solidity ^0.4.21;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {

  function safeSub(uint256 x, uint256 y) internal pure returns (uint256) {
    uint256 z = x - y;
    assert(z <= x);
	  return z;
  }

  function safeAdd(uint256 x, uint256 y) internal pure returns (uint256) {
    uint256 z = x + y;
	  assert(z >= x);
	  return z;
  }
	
  function safeDiv(uint256 x, uint256 y) internal pure returns (uint256) {
    uint256 z = x / y;
    return z;
  }
	
  function safeMul(uint256 x, uint256 y) internal pure returns (uint256) {
    uint256 z = x * y;
    assert(x == 0 || z / x == y);
    return z;
  }

  function min(uint256 x, uint256 y) internal pure returns (uint256) {
    uint256 z = x <= y ? x : y;
    return z;
  }

  function max(uint256 x, uint256 y) internal pure returns (uint256) {
    uint256 z = x >= y ? x : y;
    return z;
  }
}


/**
 * @title Ownable contract - base contract with an owner
 */
contract Ownable {
  
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);
  
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
   */
  function Ownable () public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    assert(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    assert(_newOwner != address(0));      
    newOwner = _newOwner;
  }

  /**
   * @dev Accept transferOwnership.
   */
  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      emit OwnershipTransferred(owner, newOwner);
      owner = newOwner;
    }
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {

  function totalSupply() public view  returns (uint256);
	function balanceOf(address _owner) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool success);
  
	function allowance(address _owner, address _spender) public view returns (uint256);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function approve(address _spender, uint256 _value) public returns (bool success);
	
  event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, SafeMath{
	
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

/**
 * @title StandartToken
 * @dev 
 */
contract StandartTokenPMT is StandardToken, Ownable {

  string public name;
  string public symbol;
  uint public decimals;
  
  address public exchangeRateAddress;
  address public developer;
  uint public countUse;
  uint public currentPeriod;
  bool public onceUse = false;
  bool public SoftCap;
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
  function StandartTokenPMT(uint256 _initialSupply, uint _decimals, string _name, string _symbol, address _multisigWallet, uint _startsAt, uint _totalInUSD, address _DAOPlayMarket, address _exchangeRateAddress, address _developer) public {
    decimals = _decimals;
    name = _name;
    symbol = _symbol;
    multisigWallet =_multisigWallet;
    startsAt = _startsAt;
    totalSupply_ = _initialSupply;
    exchangeRateAddress = _exchangeRateAddress;
    
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
    uint timePassed = block.timestamp - (startsAt + 90 minutes);
    uint countNow = safeDiv(timePassed,60 minutes);
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
    if((block.timestamp < (startsAt + 30 minutes)) && (tokensSold < 15*10**(6+decimals))){
      return 0;
    }else if ((block.timestamp < (startsAt + 60 minutes)) && (tokensSold < 30*10**(6+decimals))){
      return 1;
    }else if ((block.timestamp < (startsAt + 90 minutes)) && (tokensSold < 45*10**(6+decimals))){
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
    return safeDiv(safeMul(weiValue, getExchangeRate()), 1e14);
  }
  
  /**
   * Create new tokens or transfer issued tokens to the investor depending on the cap model.
   */
  function assignTokens(address receiver, uint tokenAmount) private {
     this.transfer(receiver, tokenAmount);
  }
 
  /**
   * @return exchangeRate
   */
  function getExchangeRate() public constant returns (uint) {
    return exchangeRateContract(exchangeRateAddress).exchangeRate();
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


/**
 * @title exchangeRate
 * @dev 
 */
contract exchangeRateContract {
  uint public exchangeRate;
}


/**
 * @title IcoTokensPMT
 * @dev 
 */
contract IcoTokensPMT is Ownable,SafeMath{
  
  struct _contractAdd {
    string name;
    string symbol;
    uint decimals;
    address contractAddress;
    bool release;
  }

  address public DAOPlayMarket;
  address public exchangeRateAddress;
  uint256 public initialSupply = 10000000000000000;
  uint public decimals_ = 8; 
  
  mapping (address => mapping (uint =>  _contractAdd)) public contractAdd;
  event newContract(uint256 totalSupply, uint decimals, string name, string symbol, address dev, uint idApp, address contractToken);
  event releaseICO(address dev, uint idApp, bool release);
  
  function IcoTokensPMT (address _DAOPlayMarket, address _exchangeRateAddress ) public{
    DAOPlayMarket = _DAOPlayMarket;
    exchangeRateAddress = _exchangeRateAddress;
  }
  /**
   * @dev getTokensContract 
   */
  function getTokensContract(string _name, string _symbol,address _multisigWallet, uint _startsAt, uint _totalInUSD, uint _idApp) public {
    require(contractAdd[msg.sender][_idApp].release == false);
    StandartTokenPMT contractAddress = new StandartTokenPMT(initialSupply, decimals_, _name, _symbol, _multisigWallet, _startsAt, _totalInUSD, DAOPlayMarket, exchangeRateAddress, msg.sender);
    contractAdd[msg.sender][_idApp].name = _name;
    contractAdd[msg.sender][_idApp].symbol = _symbol;
    contractAdd[msg.sender][_idApp].decimals = decimals_;
    contractAdd[msg.sender][_idApp].contractAddress = address(contractAddress);
    contractAdd[msg.sender][_idApp].release = false;
    uint amount = safeDiv(safeMul(initialSupply,85),100);
    contractAddress.mint(address(contractAddress), amount);
    emit newContract(initialSupply, decimals_, _name, _symbol, msg.sender, _idApp, address(contractAddress) );
  }

  /**
   * @dev 
   * @param _initialSupply how many tokens will be released
   * @param _decimals decimals Tokens
   */
  function setInfo(uint256 _initialSupply, uint _decimals) public onlyOwner {
    initialSupply = _initialSupply;
    decimals_ = _decimals;
  }
  
  /**
   * @dev 
   * @param _DAOPlayMarket platform address
   */
  function setAddressDAOPlayMarket(address _DAOPlayMarket) public onlyOwner {
    DAOPlayMarket = _DAOPlayMarket;
  }
  
  /**
   * @dev 
   * @param _exchangeRateAddress current rate address
   */
  function setExchangeRateAddress(address _exchangeRateAddress) public onlyOwner {
    exchangeRateAddress = _exchangeRateAddress;
  }
  
  /**
   * @dev 
   * @param _dev address developer
   * @param _idApp id app
   * @param _release release
   */
  function setRelease(address _dev, uint _idApp, bool _release ) public onlyOwner {
    contractAdd[_dev][_idApp].release = _release;
    emit releaseICO(_dev, _idApp, _release);
    
  }
  
}
