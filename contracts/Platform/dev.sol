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
contract Developer is Agent{
  
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
  function registrationDeveloper(address _adrDev, bytes32 _name, bytes32 _info) public onlyAgent {
    assert(!developers[_adrDev].isSet);
    developers[_adrDev]=_Developer({
      confirmation: autoConfirm,
      name: _name,
      info: _info,
      isSet: true
    });
  }
	
  /**
   * @dev 
   * @param _adrDev Developer address
   * @param _name Developer name
   * @param _info Additional Information
   */
  function changeDeveloperInfo(address _adrDev, bytes32 _name, bytes32 _info) public onlyAgent {
    assert(developers[_adrDev].isSet);
    developers[_adrDev].name = _name;
    developers[_adrDev].info = _info;
  }
  
  /**
   * @dev 
   * @param _autoConfirm autoConfirm
   */
  function changeAoutoConfirm(bool _autoConfirm ) public onlyOwner {
    autoConfirm = _autoConfirm;
  }
  
  /**
   * @dev 
   * @param _adrDev Developer address
   */
  function checkConfirmation(address _adrDev) public constant onlyAgent returns (bool success) {
    require(developers[_adrDev].confirmation == true);
    return true;
  }
  
  /**
   * @dev 
   * @param _adrDev Developer address
   * @param _value value
   */
  function confirmationDeveloper(address _adrDev, bool _value) public onlyAgent {
    assert(developers[_adrDev].isSet);
    developers[_adrDev].confirmation = _value;
  }
}
