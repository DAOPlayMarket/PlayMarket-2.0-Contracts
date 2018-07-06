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
 * @title Node contract - basic contract for working with nodes
 */
contract Node is Agent, SafeMath {
	
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
   * @return _proc percentage payment to the node
   */
  function buyApp(address _adrNode, uint _value, uint _proc) public onlyAgent {
    require(nodes[_adrNode].confirmation == true);
    nodeRevenue[_adrNode] = safeAdd(nodeRevenue[_adrNode],safeDiv(safeMul(_value,_proc),100));
  }

  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _hash hash
   * @return _hashTag hashTag
   * @return _deposit deposit
   */
  function registrationNode (address _adrNode, string _hash, string _hashTag, uint256 _deposit) public onlyAgent {
    nodes[_adrNode] = _Node({
      confirmation: false,
      hash: _hash,
      hashTag: _hashTag,
      deposit: _deposit,
      isSet: true
    });
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _hash hash
   * @return _hashTag hashTag
   */
  function changeNodeHash (address _adrNode, string _hash, string _hashTag) public onlyAgent {
    assert(nodes[_adrNode].isSet);
    nodes[_adrNode].hash = _hash;
    nodes[_adrNode].hashTag = _hashTag;
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   */
  function getDeposit(address _adrNode) public constant onlyAgent returns (uint256) {
    return nodes[_adrNode].deposit;
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value deposit amount
   */
  function makeDeposit(address _adrNode, uint256 _value) public onlyAgent {
    require(_value > 0);
    nodes[_adrNode].deposit = safeAdd(nodes[_adrNode].deposit, _value);
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value deposit amount
   */
  function takeDeposit(address _adrNode, uint256 _value) public onlyAgent {
    require(nodes[_adrNode].deposit >= _value);
    nodes[_adrNode].deposit = safeSub(nodes[_adrNode].deposit, _value);
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   */
  function collectNode(address _adrNode) public onlyAgent{
    nodeRevenue[_adrNode] = 0;
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value value
   */
  function confirmationNode(address _adrNode, bool _value) public onlyAgent{
    assert(nodes[_adrNode].isSet);
    nodes[_adrNode].confirmation = _value;
  }
}
