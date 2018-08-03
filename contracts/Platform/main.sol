pragma solidity ^0.4.21;

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
 * @title Developer interface contract - basic contract for working with developers
 */
contract Developer {
  
  struct _Developer {
    bool confirmation;
    bytes32 name;
    bytes32 info;
    bool isSet;
  }

  mapping (address => _Developer) public developers;
  bool autoConfirm = true;
  
  /**
   * @dev 
   * @param _adrDev Developer address
   * @param _name Developer name
   * @param _info Additional Information
   */
  function registrationDeveloper(address _adrDev, bytes32 _name, bytes32 _info) public;
	
  /**
   * @dev 
   * @param _adrDev Developer address
   * @param _name Developer name
   * @param _info Additional Information
   */
  function changeDeveloperInfo(address _adrDev, bytes32 _name, bytes32 _info) public;
  
  /**
   * @dev 
   * @param _adrDev Developer address
   */
  function checkConfirmation(address _adrDev) public constant returns (bool success);
  
  /**
   * @dev 
   * @param _adrDev Developer address
   * @param _value value
   */
  function confirmationDeveloper(address _adrDev, bool _value) public;
}

/**
 * @title Node interface contract - basic contract for working with nodes
 */
contract Node{
	
  struct _Node {
    bool confirmation;
    string hash;
    string hashTag;
    uint256 deposit;
    bool isSet;
  }
  
  mapping (address => uint256) public nodeRevenue;
  mapping (address => _Node) public nodes;
	
  /**
   * @dev 
   * @param _adrNode The address of the node through which the transaction passes
   * @param _value application fee
   * @param _proc percentage payment to the node
   */
  function buyApp(address _adrNode, uint _value, uint _proc) public;

  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _deposit deposit
   * @param _ip ip
   * @param _coordinates coordinates
   */
  function registrationNode(address _adrNode, string _hash, string _hashTag, uint256 _deposit, string _ip, string _coordinates) public;
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _ip ip
   * @param _coordinates coordinates
   */
  function changeInfoNode(address _adrNode, string _hash, string _hashTag, string _ip, string _coordinates) public;
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @return amount deposit
   */
  function getDeposit(address _adrNode) public constant returns (uint256);
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value deposit amount
   */
  function makeDeposit(address _adrNode, uint256 _value) public;
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value deposit amount
   */
  function takeDeposit(address _adrNode, uint256 _value) public;
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   */
  function collectNode(address _adrNode) public;
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value value
   */
  function confirmationNode(address _adrNode, bool _value) public;
}

/**
 * @title Application interface contract - basic contract for working with applications
 */
contract Application{
	
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
  function registrationApplication(string _hash, string _hashTag, bool _publish, uint256 _price, address _dev) public returns (uint256);
  
  /**
   * @dev 
   * @param _idApp ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function registrationApplicationICO(uint _idApp, string _hash, string _hashTag, address _dev) public;
	
   /**
   * @dev 
   * @param _idApp ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function changeHash(uint _idApp,  string _hash, string _hashTag, address _dev) public;
  
  /**
   * @dev 
   * @param _idApp ID application
   * @param _publish publish
   * @param _dev Developer address
   */
  function changePublish(uint _idApp, bool _publish, address _dev) public;
  
  /**
   * @dev 
   * @param _idApp ID application
   * @param _price new price application
   * @param _dev Developer address
   */
  function changePrice(uint _idApp, uint256 _price, address _dev) public;
  
  /**
   * @dev 
   * @param _idApp ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function changeIcoHash(uint _idApp, string _hash, string _hashTag, address _dev) public;

  /**
   * @dev 
   * @param _idApp ID application
   * @return developer address
   */  
  function getDeveloper(uint _idApp) public constant returns (address);

  /**
   * @dev 
   * @param _idApp ID application
   * @param _user user address
   * @param _dev Developer address
   * @param _price price application
   * @param _proc percentage payment to the developer
   */  
  function buyApp (uint _idApp, address _user, address _dev, uint _price, uint _proc) public;

  /**
   * @dev 
   * @param _dev Developer address
   */  
  function collectDeveloper(address _dev) public;

  /**
   * @dev 
   * @param _idApp ID application
   * @param _user user address
   * @return success
   */    
  function checkBuy(uint _idApp, address _user) public constant returns (bool success);
}

/**
 * @title IcoTokensPMT
 * @dev 
 */
contract IcoTokensPMT {
  
  struct _contractAdd {
    string name;
    string symbol;
    uint decimals;
    address contractAddress;
    uint256 totalInUSD;
    bool release;
  }

  address public DAOPlayMarket;
  address public exchangeRateAddress;
  uint256 public initialSupply = 10000000000000000;
  uint public decimals_ = 8; 
  
  mapping (address => mapping (uint =>  _contractAdd)) public contractAdd;
  
  /**
   * @dev getTokensContract 
   */
  function getTokensContract(string _name, string _symbol, address _multisigWallet, uint _startsAt, uint _totalInUSD, uint _idApp, address _adrDev) public; 
  
  /**
   * @dev 
   * @param _dev address developer
   * @param _idApp id app
   * @param _release release
   * @return address
   */
  function setRelease(address _dev, uint _idApp, bool _release) public returns (address) ;
  
  /**
   * @dev deprecated
   * @param _dev address developer
   * @param _idApp id app
   * @return address
   */
  function getAddress(address _dev, uint _idApp) public returns (address);
}

/**
 * @title PlayMarket contract - basic contract PM2
 */
contract PlayMarket is Ownable {
  
  Developer public adrDeveloperContract;
  Application public adrApplicationContract;
  Node public adrNodeContract;
  IcoTokensPMT public adrICOContract;
  
  uint256 public procDev = 99;
  uint256 public procNode = 1;
  uint256 public deposit = 100*10**18;
  
  //setting up smart contract addresses
  event setDeveloperAdrEvent(address adrDev);
  event setApplicationAdrEvent(address adrApp);
  event setNodeAdrEvent(address adrNode);
  event setICOAdrEvent(address adrICO);
  
  //App events 
  event registrationApplicationEvent(uint idApp, string hash, string hashTag, bool publish, uint256 price, address adrDev);
  event changeHashEvent(uint idApp, string hash, string hashTag);
  event changePublishEvent(uint idApp, bool publish);
  event changePriceEvent(uint idApp, uint256 price);
  event buyAppEvent(address indexed user, address indexed developer, uint idApp, address indexed adrNode, uint256 price);
  
  //Ico App events 
  event registrationApplicationICOEvent(uint idApp, string hash, string hashTag);
  event changeIcoHashEvent(uint idApp, string hash, string hashTag);
  
  //Developer events 
  event registrationDeveloperEvent(address indexed developer, bytes32 name, bytes32 info);
  event changeDeveloperInfoEvent(address indexed developer, bytes32 name, bytes32 info);
  event confirmationDeveloperEvent(address adrDev, bool value);
  
  //Node events
  event registrationNodeEvent(address indexed adrNode, bool confirmation, string hash, string hashTag, uint256 deposit, string ip, string coordinates);
  event confirmationNodeEvent(address adrNode, bool value);
  event makeDepositEvent(address indexed adrNode, uint256 deposit);
  event takeDepositEvent(address indexed adrNode, uint256 deposit);
  event changeInfoNodeEvent(address adrNode, string hash, string hashTag, string ip, string coordinates);
  
  //Reviews events
  event newRating(address voter , uint idApp, uint vote, string description, bytes32 txIndex, uint256 block.timestamp);
  
  //ICO events 
  event releaseICOEvent(address adrDev, uint idApp, bool release, address ICO);
  event newContractEvent(string name, string symbol, address adrDev, uint idApp);
  
  function PlayMarket(address _adrDeveloperContract, address _adrApplicationContract, address _adrNodeContract, address _adrICOContract) public {
    require(_adrDeveloperContract != address(0));
    require(_adrApplicationContract != address(0));
    require(_adrNodeContract != address(0));
    require(_adrICOContract != address(0));
    
    adrDeveloperContract = Developer(_adrDeveloperContract);
    adrApplicationContract = Application(_adrApplicationContract);
    adrNodeContract = Node(_adrNodeContract);
    adrICOContract = IcoTokensPMT(_adrICOContract);
  }
  
  function setDeveloperAdr(address _adrDeveloperContract) public onlyOwner {
    adrDeveloperContract = Developer(_adrDeveloperContract);
    emit setDeveloperAdrEvent(_adrDeveloperContract);
  }
  
  function setApplicationAdr(address _adrApplicationContract) public onlyOwner {
    adrApplicationContract = Application(_adrApplicationContract);
    emit setApplicationAdrEvent(_adrApplicationContract);
  }
  
  function setNodeAdr(address _adrNodeContract) public onlyOwner {
    adrNodeContract = Node(_adrNodeContract);
    emit setNodeAdrEvent(_adrNodeContract);
  }
  
  function setICOAdr(address _adrICOContract) public onlyOwner {
    adrICOContract = IcoTokensPMT(_adrICOContract);
    emit setICOAdrEvent(_adrICOContract);
  }
  
  function buyApp(uint _idApp, address _adrNode) public payable {
    require(checkBuy(_idApp,msg.sender) == false);
    address adrDev = adrApplicationContract.getDeveloper(_idApp);
    require(adrDeveloperContract.checkConfirmation(adrDev));
    adrNodeContract.buyApp(_adrNode, msg.value, procNode);
    adrApplicationContract.buyApp(_idApp, msg.sender, adrDev, msg.value, procDev);
    emit buyAppEvent(msg.sender, adrDev, _idApp, _adrNode, msg.value);
  }
  
  function registrationApplication(string _hash, string _hashTag, bool _publish, uint256 _price) public {
    require(adrDeveloperContract.checkConfirmation(msg.sender));
    uint256 _idApp = adrApplicationContract.registrationApplication(_hash, _hashTag, _publish, _price, msg.sender);
    emit registrationApplicationEvent(_idApp, _hash, _hashTag, _publish, _price, msg.sender);
  }
  
  function registrationApplicationICO(uint _idApp, string _hash, string _hashTag) public {
    require(adrDeveloperContract.checkConfirmation(msg.sender));
    adrApplicationContract.registrationApplicationICO(_idApp, _hash, _hashTag, msg.sender);
    emit registrationApplicationICOEvent(_idApp, _hash, _hashTag);
  }  
  
  function changeHash(uint _idApp, string _hash, string _hashTag) public {
    require(adrDeveloperContract.checkConfirmation(msg.sender));
    adrApplicationContract.changeHash(_idApp, _hash, _hashTag, msg.sender);
    emit changeHashEvent(_idApp, _hash, _hashTag);
  }
  
  function changeIcoHash(uint _idApp, string _hash, string _hashTag) public {
    require(adrDeveloperContract.checkConfirmation(msg.sender));
    adrApplicationContract.changeIcoHash( _idApp, _hash, _hashTag, msg.sender);
    emit changeIcoHashEvent(_idApp, _hash, _hashTag);
  }
  
  function changePublish(uint _idApp, bool _publish) public {
    require(adrDeveloperContract.checkConfirmation(msg.sender));
    adrApplicationContract.changePublish(_idApp, _publish, msg.sender);
    emit changePublishEvent(_idApp, _publish);
  }
  
  function changePrice(uint _idApp, uint256 _price) public {
    require(adrDeveloperContract.checkConfirmation(msg.sender));
    adrApplicationContract.changePrice(_idApp, _price, msg.sender);
    emit changePriceEvent(_idApp, _price);
  }
  
  function changePublishOwner(uint _idApp, bool _publish, address _dev) public onlyOwner {
    adrApplicationContract.changePublish(_idApp, _publish, _dev);
    emit changePublishEvent(_idApp, _publish);
  }
  
  function registrationDeveloper(bytes32 _name, bytes32 _info) public {
    adrDeveloperContract.registrationDeveloper(msg.sender, _name,_info);
    emit registrationDeveloperEvent(msg.sender, _name, _info);	
  }
	
  function changeDeveloperInfo(bytes32 _name, bytes32 _info) public {
    adrDeveloperContract.changeDeveloperInfo(msg.sender, _name,_info);
    emit changeDeveloperInfoEvent(msg.sender, _name, _info);	
  }

  function registrationNode( string _hash, string _hashTag, string _ip, string _coordinates) public payable {
    require(msg.value == deposit);
    require(adrNodeContract.getDeposit(msg.sender) == 0);
    adrNodeContract.registrationNode(msg.sender, _hash, _hashTag, msg.value, _ip, _coordinates);
    emit registrationNodeEvent(msg.sender, false, _hash, _hashTag, msg.value, _ip, _coordinates);	
  }
  
  function changeInfoNode(string _hash, string _hashTag, string _ip, string _coordinates) public {
    adrNodeContract.changeInfoNode(msg.sender, _hash, _hashTag, _ip, _coordinates);
    emit changeInfoNodeEvent(msg.sender, _hash, _hashTag, _ip, _coordinates);	
  }
  
  function makeDeposit() public payable {
    adrNodeContract.makeDeposit(msg.sender, msg.value);
    emit makeDepositEvent(msg.sender, msg.value);
  }
  
  function takeDeposit(address _node) public onlyOwner {
    require(_node != address(0));
    uint256 depositNode = adrNodeContract.getDeposit(_node);
    adrNodeContract.takeDeposit(_node, depositNode);
    adrNodeContract.confirmationNode(_node, false);
    _node.transfer(depositNode);
    emit confirmationNodeEvent(_node, false);
    emit takeDepositEvent(_node, depositNode);
  }
  
  function confirmationNode(address _node, bool _value) public onlyOwner {
    adrNodeContract.confirmationNode(_node,_value);
    emit confirmationNodeEvent(_node, _value);
  }
  
  function confirmationDeveloper(address _developer, bool _value) public onlyOwner {
    adrDeveloperContract.confirmationDeveloper(_developer,_value);
    emit confirmationDeveloperEvent(_developer, _value);
  }

  function collectNode() public {
    uint256 amount = adrNodeContract.nodeRevenue(msg.sender);
    adrNodeContract.collectNode(msg.sender);
    msg.sender.transfer(amount);
  }
  
  function collectDeveloper() public {
    uint256 amount = adrApplicationContract.developerRevenue(msg.sender);
    adrApplicationContract.collectDeveloper(msg.sender);
    msg.sender.transfer(amount);
	}
  
  function setProcDev(uint256 _proc) public onlyOwner {
    procDev = _proc;
  }

  function setProcNode(uint256 _proc) public onlyOwner {
    procNode = _proc;
  }
  
  function setDeposit(uint256 _deposit) public onlyOwner {
    deposit = _deposit;
  }
  
  function sendWei(address adr, uint256 sum) public onlyOwner {
    adr.transfer(sum);
  }
  
  function checkBuy(uint _idApp, address _user) public constant returns (bool success) {
      return adrApplicationContract.checkBuy(_idApp, _user);
  }
  
  function setRelease(address _adrDev, uint _idApp, bool _release ) public onlyOwner {
    address newContract  = adrICOContract.setRelease(_adrDev, _idApp, _release);
    emit releaseICOEvent(_adrDev, _idApp, _release, newContract);
  }
  
  function getTokensContract(string _name, string _symbol, address _multisigWallet, uint _startsAt, uint _totalInUSD, uint _idApp) public {
    address adrDev = adrApplicationContract.getDeveloper(_idApp);
    require(msg.sender == adrDev);
    adrICOContract.getTokensContract(_name, _symbol,_multisigWallet, _startsAt, _totalInUSD, _idApp, msg.sender);
    emit newContractEvent(_name, _symbol, msg.sender, _idApp);
  }
  
   /**
   * @dev We do not store the data in the contract, but generate the event. This allows you to make feedback as cheap as possible. The event generation costs 8 wei for 1 byte, and data storage in the contract 20,000 wei for 32 bytes
   * @param idApp voice application identifier
   * @param vote voter rating
   * @param description voted opinion
   * @param txIndex identifier for the answer
   */
  function pushFeedbackRating(uint idApp, uint vote, string description, bytes32 txIndex) public {
    require( vote > 0 && vote <= 5);
    emit newRating(msg.sender, idApp, vote, description, txIndex, block.timestamp);
  }
}
