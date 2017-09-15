pragma solidity ^0.4.11;

contract SafeMath {
	
    function sub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x - y) <= x);
    }

    function add(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x + y) >= x);
    }
	
	function div(uint256 x, uint256 y) constant internal returns (uint256 z) {
        z = x / y;
    }
	
	function min(uint256 x, uint256 y) constant internal returns (uint256 z) {
        z = x <= y ? x : y;
    }
}

contract Owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        assert (msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }
 
    function acceptOwnership() {
        if (msg.sender == newOwner) {
            OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        }
    }
}

contract Developer{
	event RegistrationDeveloper(address indexed developer, uint info);	
	struct _Developer {
		bool confirmation;
		uint info;
	}
	
	struct Vote {
        uint vote; 
		bool voted; 
    }
	
	mapping (address => _Developer) public developers;
	mapping (address => mapping (address => Vote)) public votesDeveloper;
	
	function registrationDeveloper (uint _info){
		developers[msg.sender]=_Developer({
			confirmation: false,
			info: _info
		});
		RegistrationDeveloper(msg.sender,_info);	
	}
	
	function voting(address _developer,uint vote){
		require(vote<=5);
		Vote storage sender = votesDeveloper[_developer][msg.sender];
        require(!sender.voted);
        sender.voted = true;
		sender.vote=vote;
	}
	
}

contract Application is Developer,SafeMath{
	event RegistrationApplication(uint8 category, uint countAppOfCategory, bool free, uint256 value, address indexed developer, string nameApp);
	struct _Application {
		uint8 status;
		uint8 category;
		bool free;
		bool confirmation;
		uint256 value;
		address developer;
		string nameApp; 
	}
	
	mapping (uint => uint) public countAppOfCategory; 
	mapping (uint => mapping (uint => _Application)) public applications;
	function registrationApplication (uint8 _category, bool _free,uint256 _value, string _nameApp){
		require(developers[msg.sender].confirmation==true);
		countAppOfCategory[_category] = add(countAppOfCategory[_category],1); 
		applications[_category][countAppOfCategory[_category]]=_Application({
			status: 0,
			category: _category,
			free: _free,
			confirmation: false,
			value: _value,
			developer: msg.sender,
			nameApp: _nameApp
		});
		RegistrationApplication(_category,countAppOfCategory[_category],_free,_value,msg.sender,_nameApp);
	}
}

contract User is Application{
	event RegistrationUser(address indexed user, uint info);	
	struct _User {
		uint8 status;
		bool confirmation;
		uint info;
	}
	
	struct Purchase {
		bool confirmation;
	}
	//User[] public users;

	mapping (address => _User) public users;
	mapping (address => mapping (uint =>  mapping (uint => Purchase))) public purchases;
	function registrationUser (uint _info){
		users[msg.sender] = _User({
			status: 0,
			confirmation: false,
			info: _info
		});
		RegistrationUser(msg.sender,_info);	
	}
	
	function buyApp (uint _idApp, uint _category) payable {
		require(applications[_category][_idApp].value == msg.value);
		purchases[msg.sender][_category][_idApp].confirmation = true;
	}
}

contract PlayMarket is User,Owned{
	
	function confirmationDeveloper(address _developer, bool _value) onlyOwner {
		developers[_developer].confirmation = _value;
	}

	function confirmationApplication(uint _application,uint _category, bool _value) onlyOwner{
		applications[_category][_application].confirmation = _value;
	}
	
	function confirmationUser(address _user, bool _value) onlyOwner{
		users[_user].confirmation = _value;
	}
	
	function collect() onlyOwner {
		require(owner.call.value(this.balance)(0));
	}
}
