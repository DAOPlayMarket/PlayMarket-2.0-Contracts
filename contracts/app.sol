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
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
 * @title Agent contract - base contract with an agent
 */
contract Agent is Ownable {
  address public adrAgent;
  
  function Agent() public {
    adrAgent = msg.sender;
  }
  
  modifier onlyAgent() {
    assert(msg.sender == adrAgent);
    _;
  }
  
  function setAgent(address _adrAgent) public onlyOwner{
    adrAgent = _adrAgent;
  }
  
}

/**
 * @title Application contract - basic contract for working with applications
 */
contract Application is Agent, SafeMath {
	
  struct _Application {
    address developer;
    string hash;
    string hashTag;
    uint256 price;
    bool publish;
  }

  struct _ApplicationICO {
    string hash;
    string hashTag;
  }

  _Application[] public applications;
  mapping (uint => _ApplicationICO) public applicationsICO;
  mapping (address => mapping (uint =>  bool)) public purchases;
  mapping (address => uint256) public developerRevenue;
  
  /**
   * @dev 
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _publish publish
   * @param _price price App
   * @param _dev Developer address
   * @return number of current applications
   */
  function registrationApplication(string _hash, string _hashTag, bool _publish, uint256 _price, address _dev) public onlyAgent returns (uint256) {
    applications.push(_Application({
      developer: _dev,
      hash: _hash,
      hashTag: _hashTag,
      price: _price,
      publish: _publish
    }));
    return applications.length-1;
  }
  
  /**
   * @dev 
   * @param _idApp ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function registrationApplicationICO(uint _idApp, string _hash, string _hashTag, address _dev) public onlyAgent {
    require(checkDeveloper(_idApp,_dev));
    applicationsICO[_idApp].hash =_hash;
    applicationsICO[_idApp].hashTag =_hashTag;
  }
	
   /**
   * @dev 
   * @param _idApp ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function changeHash(uint _idApp,  string _hash, string _hashTag, address _dev) public onlyAgent {
    require(checkDeveloper(_idApp,_dev));
    applications[_idApp].hash =_hash;
    applications[_idApp].hashTag =_hashTag;
  }
  
  /**
   * @dev 
   * @param _idApp ID application
   * @param _publish publish
   * @param _dev Developer address
   */
  function changePublish(uint _idApp, bool _publish, address _dev) public onlyAgent {
    require(checkDeveloper(_idApp,_dev));
    applications[_idApp].publish =_publish;
  }
  
  /**
   * @dev 
   * @param _idApp ID application
   * @param _price new price application
   * @param _dev Developer address
   */
  function changePrice(uint _idApp, uint256 _price, address _dev) public onlyAgent {
    require(checkDeveloper(_idApp,_dev));
    applications[_idApp].price =_price;
  }
  
  /**
   * @dev 
   * @param _idApp ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function changeIcoHash(uint _idApp, string _hash, string _hashTag, address _dev) public onlyAgent {
    require(checkDeveloper(_idApp,_dev));
    applicationsICO[_idApp].hash =_hash;
    applicationsICO[_idApp].hashTag =_hashTag;
  }

  /**
   * @dev 
   * @param _idApp ID application
   * @param _dev Developer address
   * @return boolean
   */  
  function checkDeveloper(uint _idApp, address _dev) private constant returns (bool success) {
      require(applications[_idApp].developer == _dev);
      return true;
  }

  /**
   * @dev 
   * @param _idApp ID application
   * @return developer address
   */  
  function getDeveloper(uint _idApp) public onlyAgent constant  returns (address) {
    return applications[_idApp].developer;
  }

  /**
   * @dev 
   * @param _idApp ID application
   * @param _price price application
   * @return boolean
   */  
  function checkSum(uint _idApp, uint256 _price) private constant returns (bool success) {
      require(applications[_idApp].price == _price);
      return true;
  }

  /**
   * @dev 
   * @param _idApp ID application
   * @param _user user address
   * @param _dev Developer address
   * @param _price price application
   * @param _proc percentage payment to the developer
   */  
  function buyApp (uint _idApp, address _user, address _dev, uint _price, uint _proc) public onlyAgent {
    require(checkSum(_idApp,_price));
    purchases[_user][_idApp] = true;
    developerRevenue[_dev] = safeAdd(developerRevenue[_dev],safeDiv(safeMul(_price,_proc),100));
  }

  /**
   * @dev 
   * @param _dev Developer address
   */  
  function collectDeveloper(address _dev) public onlyAgent{
    developerRevenue[_dev] = 0;
  }

  /**
   * @dev 
   * @param _idApp ID application
   * @param _user user address
   * @return boolean
   */    
  function checkBuy(uint _idApp, address _user) public constant returns (bool success) {
      return purchases[_user][_idApp];
  }
}