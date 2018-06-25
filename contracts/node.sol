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
