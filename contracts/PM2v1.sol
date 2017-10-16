pragma solidity ^0.4.15;

 /**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {

  function sub(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x - y;
    assert(z <= x);
    return z;
  }

  function add(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x + y;
    assert(z >= x);
    return z;
  }
	
  function div(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x / y;
    return z;
  }
	
  function mul(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x * y;
    assert(x == 0 || z / x == y);
    return z;
  }

  function min(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x <= y ? x : y;
    return z;
  }

  function max(uint256 x, uint256 y) internal constant returns (uint256) {
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
 * @title Developer contract - basic contract for working with developers
 */
contract Developer is Ownable, SafeMath{
	event RegistrationDeveloper(address indexed developer, uint info);	
	struct _Developer {
		bool confirmation;
		uint info;
		uint8 status;
	}
	
	struct Vote {
        uint vote; 
		bool voted; 
    }
	
	mapping (address => _Developer) public developers;
	mapping (address => mapping (address => Vote)) public votesDeveloper;
	
	function registrationDeveloper (uint _info) public {
		developers[msg.sender]=_Developer({
			confirmation: false,
			info: _info,
			status: 1
		});
		RegistrationDeveloper(msg.sender,_info);	
	}
	
	function voting(address _developer,uint vote) public {
		assert(vote<=5);
		Vote storage sender = votesDeveloper[_developer][msg.sender];
        assert(!sender.voted);
        sender.voted = true;
		sender.vote=vote;
	}
	
}


/**
 * @title Application contract - basic contract for working with applications
 */
contract Application is Developer, Ownable, SafeMath{
	event RegistrationApplication(uint8 category, uint countAppOfCategory, bool free, uint256 value, address indexed developer, string nameApp, string hashIpfs);
	event changeHashIpfsEvent(uint8 category, uint idApp, string hashIpfs);
	struct _Application {
		uint8 status;
		uint8 category;
		bool free;
		bool confirmation;
		uint256 value;
		address developer;
		string nameApp; 
		string hashIpfs;
	}
	
	mapping (uint => uint) public countAppOfCategory; 
	mapping (uint => mapping (uint => _Application)) public applications;
	function registrationApplication (uint8 _category, bool _free,uint256 _value, string _nameApp, string _hashIpfs) public {
		assert(developers[msg.sender].confirmation==true);
		countAppOfCategory[_category] = add(countAppOfCategory[_category],1); 
		applications[_category][countAppOfCategory[_category]]=_Application({
			status: 1,
			category: _category,
			free: _free,
			confirmation: false,
			value: _value,
			developer: msg.sender,
			nameApp: _nameApp,
			hashIpfs: _hashIpfs
		});
		RegistrationApplication(_category, countAppOfCategory[_category], _free, _value, msg.sender, _nameApp, _hashIpfs );
	}
	
	function changeHashIpfs(uint _idApp, uint8 _category, string _hashIpfs) public {
		assert(developers[msg.sender].confirmation==true);
		assert(applications[_category][_idApp].confirmation==true);
		applications[_category][_idApp].hashIpfs =_hashIpfs;
		changeHashIpfsEvent(_category, _idApp, _hashIpfs);
	}
}

/**
 * @title User contract - basic contract for working with users
 */
contract User is Application, Ownable, SafeMath{
	event RegistrationUser(address indexed user, uint info);	
	struct _User {
		uint8 status;
		bool confirmation;
		uint info;
	}
	
	struct Purchase {
		bool confirmation;
	}
	uint256 public commission;
	mapping (address => uint256) public developerRevenue;
	mapping (address => _User) public users;
	mapping (address => mapping (uint =>  mapping (uint => Purchase))) public purchases;
	function registrationUser (uint _info) public {
		users[msg.sender] = _User({
			status: 1,
			confirmation: false,
			info: _info
		});
		RegistrationUser(msg.sender,_info);	
	}
	
	function buyApp (uint _idApp, uint _category) public payable {
		assert(applications[_category][_idApp].value == msg.value);
		//assert(users[_user].status>0 && users[_user].status<=1);
		purchases[msg.sender][_category][_idApp].confirmation = true;
		uint sum = sub(msg.value,div(msg.value,10));
		developerRevenue[applications[_category][_idApp].developer] = add(developerRevenue[applications[_category][_idApp].developer],sum);
		commission = add(commission,sub(msg.value,sum));
	}
}


/**
 * @title PlayMarket contract - basic contract PM2
 */
contract PlayMarket is User, Ownable, SafeMath{

	function confirmationDeveloper(address _developer, bool _value) public onlyOwner {
		assert(developers[_developer].status>0 && developers[_developer].status<=1);
		developers[_developer].confirmation = _value;
	}

	function confirmationApplication(uint _application,uint _category, bool _value) public onlyOwner{
		assert(applications[_category][_application].status>0 && applications[_category][_application].status<=1);
		applications[_category][_application].confirmation = _value;
	}
	
	function confirmationUser(address _user, bool _value) public onlyOwner{
		assert(users[_user].status>0 && users[_user].status<=1);
		users[_user].confirmation = _value;
	}
	
	function collect() public onlyOwner {
		owner.transfer(commission);
	}
	
	function collectDeveloper() public {
		msg.sender.transfer(developerRevenue[msg.sender]);
	}
}
