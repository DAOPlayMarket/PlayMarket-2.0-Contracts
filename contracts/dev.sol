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
