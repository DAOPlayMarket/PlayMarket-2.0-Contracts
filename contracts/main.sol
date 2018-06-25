pragma solidity ^0.4.18;

 /**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {

  function sub(uint256 x, uint256 y) internal pure returns (uint256) {
    uint256 z = x - y;
    assert(z <= x);
    return z;
  }

  function add(uint256 x, uint256 y) internal pure returns (uint256) {
    uint256 z = x + y;
    assert(z >= x);
    return z;
  }
	
  function div(uint256 x, uint256 y) internal pure returns (uint256) {
    uint256 z = x / y;
    return z;
  }
	
  function mul(uint256 x, uint256 y) internal pure returns (uint256) {
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
      OwnershipTransferred(owner, newOwner);
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
 * @title Developer contract - basic contract for working with developers
 */
contract Developer is Agent, SafeMath{
  struct _Developer {
		bool confirmation;
    bytes32 name;
		bytes32 info;
    bool isSet;
	}


	mapping (address => _Developer) public developers;
	bool autoConfirm = true;
  
	function registrationDeveloper (address _adrDev, bytes32 _info, bytes32 _name) public onlyAgent {
		developers[_adrDev]=_Developer({
			confirmation: autoConfirm,
			info: _info,
      name: _name,
      isSet: true
		});
	}
	
	function changeAoutoConfirm(bool _autoConfirm ) public onlyOwner {
		autoConfirm = _autoConfirm;
	}
  
  function checkConfirmation (address _addrDev) public constant onlyAgent returns (bool success) {
      require(developers[_addrDev].confirmation == true);
      return true;
  }
  
  function confirmationDeveloper(address _developer, bool _value) public onlyAgent {
		assert(developers[_developer].isSet);
		developers[_developer].confirmation = _value;
	}
}


/**
 * @title Node contract - basic contract for working with nodes
 */
contract Node is Agent, SafeMath {
	
  struct _Node {
    bool confirmation;
    bytes32 IP;
    bytes32 X;
    bytes32 Y;
    uint256 deposit;
    bool isSet;
	}
  
	mapping (address => uint256) public nodeRevenue;
	mapping (address => _Node) public nodes;
	
 	function buyApp(address _adrNode, uint _value, uint _proc) public onlyAgent {
		require(nodes[_adrNode].confirmation == true);
    nodeRevenue[_adrNode] = add(nodeRevenue[_adrNode],div(mul(_value,_proc),100));
	}

  function registrationNode (address _adrNode, bytes32 _IP, bytes32 _X, bytes32 _Y, uint256 _deposit) public onlyAgent {
		nodes[_adrNode] = _Node({
      confirmation: false,
      IP: _IP,
      X: _X,
      Y: _Y,
      deposit: _deposit,
      isSet: true
		});
	}
  
  function getDeposit(address _adrNode) public constant onlyAgent returns (uint256) {
    return nodes[_adrNode].deposit;
  }
  
  function makeDeposit(address _adrNode, uint256 _value) public onlyAgent {
    require(_value > 0);
    nodes[_adrNode].deposit = add(nodes[_adrNode].deposit, _value);
  }
  
  function takeDeposit(address _adrNode, uint256 _value) public onlyAgent {
    require(nodes[_adrNode].deposit >= _value);
    nodes[_adrNode].deposit = sub(nodes[_adrNode].deposit, _value);
  }
  
  function collectNode(address _adrNode) public onlyAgent{
		nodeRevenue[_adrNode] = 0;
	}
  
  function confirmationNode(address _node, bool _value) public onlyAgent{
		assert(nodes[_node].isSet);
    nodes[_node].confirmation = _value;
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
    uint256 value;
    bool publish;
	}

  struct _ApplicationICO {
    address adr;
    string hash;
    string hashTag;
  }

	_Application[] public applications;
  //_ApplicationICO[] public applicationsICO;
  mapping (uint => _ApplicationICO) public applicationsICO;
  mapping (address => mapping (uint =>  bool)) public purchases;
  mapping (address => uint256) public developerRevenue;
  
	function registrationApplication (string _hash, string _hashTag, bool _publish, uint256 _value, address _dev) public onlyAgent returns (uint256) {
		applications.push(_Application({
      developer: _dev,
      hash: _hash,
      hashTag: _hashTag,
      value: _value,
      publish: _publish
    }));
    return applications.length-1;
	}
  
  function registrationApplicationICO (uint _idApp, address _addr, string _hash, string _hashTag, address _dev) public onlyAgent {
    require(checkDeveloper(_idApp,_dev));
    applicationsICO[_idApp].adr =_addr;
    applicationsICO[_idApp].hash =_hash;
    applicationsICO[_idApp].hashTag =_hashTag;
	}
	
	function changeHash (uint _idApp,  string _hash, string _hashTag, address _dev) public onlyAgent {
		require(checkDeveloper(_idApp,_dev));
    applications[_idApp].hash =_hash;
    applications[_idApp].hashTag =_hashTag;
	}
  
  function changePublish (uint _idApp, bool _publish, address _dev) public onlyAgent {
		require(checkDeveloper(_idApp,_dev));
    applications[_idApp].publish =_publish;
	}
  
  function changeIcoInfo (uint _idApp, address _addr, string _hash, string _hashTag, address _dev) public onlyAgent {
		require(checkDeveloper(_idApp,_dev));
    applicationsICO[_idApp].adr =_addr;
    applicationsICO[_idApp].hash =_hash;
    applicationsICO[_idApp].hashTag =_hashTag;
	}
  
  function checkDeveloper(uint _idApp, address _dev) private constant returns (bool success) {
      require(applications[_idApp].developer == _dev);
      return true;
  }
  
  function getDeveloper(uint _idApp) public onlyAgent constant  returns (address) {
    return applications[_idApp].developer;
  }
  
  function checkSum(uint _idApp, uint256 _value) private constant returns (bool success) {
      require(applications[_idApp].value == _value);
      return true;
  }

  function buyApp (uint _idApp, address _user, address _dev, uint _value, uint _proc) public onlyAgent {
		require(checkSum(_idApp,_value));
    purchases[_user][_idApp] = true;
		developerRevenue[_dev] = add(developerRevenue[_dev],div(mul(_value,_proc),100));
	}

  function collectDeveloper(address _dev) public onlyAgent{
		developerRevenue[_dev] = 0;
	}
  
  function checkBuy(uint _idApp, address _user) public constant returns (bool success) {
      return purchases[_user][_idApp];
  }
}

/**
 * @title PlayMarket contract - basic contract PM2
 */
contract PlayMarket is Ownable {
  Developer public adrDeveloperContract;
  Application public adrApplicationContract;
  Node public adrNodeContract;
  
  uint256 public procDev = 99;
  uint256 public procNode = 1;
  uint256 public deposit = 100*10**18;
  
  event setDeveloperAdrEvent(address adrDev);
  event setApplicationAdrEvent(address adrApp);
  event setUserAdrAdrEvent(address adrUser);
  event setNodeAdrAdrEvent(address adrNode);
  event registrationApplicationEvent(uint idApp, string hash, string hashTag, bool publish, uint256 value, address adrDev);
  event registrationApplicationICOEvent(uint idApp, address adr, string hash, string hashTag);
  event changeHashEvent(uint idApp, string hash, string hashTag);
  event changeIcoInfoEvent(uint idApp, address adr,  string hash, string hashTag);
  event registrationDeveloperEvent(address indexed developer, bytes32 info, bytes32 name);
  event registrationNodeEvent(address indexed adrNode, bool confirmation, bytes32 IP, bytes32 X, bytes32 Y, uint256 deposit);
  event confirmationNodeEvent(address adrNode, bool value);
  event confirmationDeveloperEvent(address adrDev, bool value);
  event changePublishEvent(uint idApp, bool publish);
  event buyAppEvent(uint idApp, address indexed adrNode, uint256 value);
  event makeDepositEvent(address indexed adrNode, uint256 deposit);
  event takeDepositEvent(address indexed adrNode, uint256 deposit);
  
  function PlayMarket(address _adrDeveloperContract, address _adrApplicationContract, address _adrNodeContract) public {
    require(_adrDeveloperContract != address(0));
    require(_adrApplicationContract != address(0));
    require(_adrNodeContract != address(0));
    
    adrDeveloperContract = Developer(_adrDeveloperContract);
    adrApplicationContract = Application(_adrApplicationContract);
    adrNodeContract = Node(_adrNodeContract);
  }
  
  function setDeveloperAdr(address _adrDeveloperContract) public onlyOwner {
    adrDeveloperContract = Developer(_adrDeveloperContract);
    setDeveloperAdrEvent(_adrDeveloperContract);
  }
  
  function setApplicationAdr(address _adrApplicationContract) public onlyOwner {
    adrApplicationContract = Application(_adrApplicationContract);
    setApplicationAdrEvent(_adrApplicationContract);
  }
  
  function setNodeAdr(address _adrNodeContract) public onlyOwner {
    adrNodeContract = Node(_adrNodeContract);
    setNodeAdrAdrEvent(_adrNodeContract);
  }
  
  function buyApp (uint _idApp, address _adrNode) public payable {
    require(checkBuy(_idApp,msg.sender) == false);
    address adrDev = adrApplicationContract.getDeveloper(_idApp);
    require(adrDeveloperContract.checkConfirmation(adrDev));
    adrNodeContract.buyApp(_adrNode, msg.value, procNode);
    adrApplicationContract.buyApp(_idApp, msg.sender, adrDev, msg.value, procDev);
    buyAppEvent(_idApp, _adrNode, msg.value);
	}
  
  function registrationApplication (string _hash, string _hashTag, bool _publish, uint256 _value) public {
    require(adrDeveloperContract.checkConfirmation(msg.sender));
    uint256 _idApp = adrApplicationContract.registrationApplication(_hash, _hashTag, _publish, _value, msg.sender);
    registrationApplicationEvent(_idApp, _hash, _hashTag, _publish, _value, msg.sender);
    
  }
  
  function registrationApplicationICO(uint _idApp, address _addr, string _hash, string _hashTag) public {
    require(adrDeveloperContract.checkConfirmation(msg.sender));
    adrApplicationContract.registrationApplicationICO(_idApp, _addr, _hash, _hashTag, msg.sender);
    registrationApplicationICOEvent(_idApp, _addr, _hash, _hashTag);
  }  
  
  function changeHash(uint _idApp, string _hash, string _hashTag) public {
    require(adrDeveloperContract.checkConfirmation(msg.sender));
    adrApplicationContract.changeHash(_idApp, _hash, _hashTag, msg.sender);
    changeHashEvent(_idApp, _hash, _hashTag);
	}
  
  function changeIcoInfo(uint _idApp, address _addr, string _hash, string _hashTag) public {
    require(adrDeveloperContract.checkConfirmation(msg.sender));
		adrApplicationContract.changeIcoInfo( _idApp, _addr, _hash, _hashTag, msg.sender);
    changeIcoInfoEvent(_idApp, _addr, _hash, _hashTag);
	}
  
  function changePublish (uint _idApp, bool _publish) public {
    require(adrDeveloperContract.checkConfirmation(msg.sender));
    adrApplicationContract.changePublish(_idApp, _publish, msg.sender);
		changePublishEvent(_idApp, _publish);
	}
  
  function registrationDeveloper(bytes32 _info, bytes32 _name) public {
    adrDeveloperContract.registrationDeveloper(msg.sender, _info, _name);
    registrationDeveloperEvent(msg.sender, _info, _name);	
	}
	

  function registrationNode(bytes32 _IP, bytes32 _X, bytes32 _Y) public payable {
    require(msg.value == deposit);
    require(adrNodeContract.getDeposit(msg.sender) == 0);
    adrNodeContract.registrationNode(msg.sender, _IP, _X, _Y, msg.value);
    registrationNodeEvent(msg.sender, false, _IP, _X, _Y, msg.value);	
	}
  
  function makeDeposit() public payable {
    adrNodeContract.makeDeposit(msg.sender, msg.value);
    makeDepositEvent(msg.sender, msg.value);
  }
  
  function takeDeposit() public {
    uint256 depositNode = adrNodeContract.getDeposit(msg.sender);
    adrNodeContract.takeDeposit(msg.sender, depositNode);
    adrNodeContract.confirmationNode(msg.sender, false);
    msg.sender.transfer(depositNode);
    confirmationNodeEvent(msg.sender, false);
    takeDepositEvent(msg.sender, depositNode);
  }
  
  function confirmationNode(address _node, bool _value) public onlyOwner {
    adrNodeContract.confirmationNode(_node,_value);
    confirmationNodeEvent(_node, _value);
	}
  
  function confirmationDeveloper(address _developer, bool _value) public onlyOwner {
    adrDeveloperContract.confirmationDeveloper(_developer,_value);
    confirmationDeveloperEvent(_developer, _value);
	}

	function collectNode() public {
    msg.sender.transfer(adrNodeContract.nodeRevenue(msg.sender));
    adrNodeContract.collectNode(msg.sender);
	}
  
	function collectDeveloper() public {
		msg.sender.transfer(adrApplicationContract.developerRevenue(msg.sender));
    adrApplicationContract.collectDeveloper(msg.sender);
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
  
}
