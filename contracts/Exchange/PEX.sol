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
 */
contract ERC20 {
  uint public decimals;
  string public name;
  
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
 * @title PlayMarket 2.0 Exchange
 */
contract PEX is SafeMath, Ownable {
  
  mapping (address => bool) admins;
  address public feeAccount;
  uint public feeMake; 
  uint public feeTake; 

  mapping (address => mapping (address => uint)) public tokens; 
  mapping (address => mapping (bytes32 => bool)) public orders;
  mapping (address => mapping (bytes32 => uint)) public orderFills;  
  
  struct whitelistToken {
    bool active;
    uint256 timestamp;
  }
  mapping (address => whitelistToken) public whitelistTokens;

  event Deposit(address token, address user, uint amount, uint balance);
  event Withdraw(address token, address user, uint amount, uint balance);
  event Order(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user);
  event Cancel(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, bytes32 hash);
  event Trade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, address user, address recipient, bytes32 hash, uint256 timestamp);
  event WhitelistTokens(address token, bool active, uint256 timestamp);
  
  modifier onlyAdmin {
    assert(msg.sender == owner || admins[msg.sender]);
    _;
  }

  modifier onlyWhitelistTokens(address token, uint256 timestamp) {
    assert(whitelistTokens[token].active && whitelistTokens[token].timestamp <= timestamp);
    _;
  }
  
  function PEX(address feeAccount_, uint feeMake_, uint feeTake_) public {
    feeAccount = feeAccount_;
    feeMake = feeMake_;
    feeTake = feeTake_;
  }
  
  function setAdmin(address admin_, bool value) public onlyOwner {
    admins[admin_] = value;
  }

  function changeFeeAccount(address feeAccount_) public onlyAdmin {
    require(feeAccount_ != address(0));
    feeAccount = feeAccount_;
  }

  function changeFeeMake(uint feeMake_) public onlyAdmin {
    feeMake = feeMake_;
  }

  function changeFeeTake(uint feeTake_) public onlyAdmin {
    feeTake = feeTake_;
  }

  function setWhitelistTokens(address token, bool active, uint256 timestamp) public onlyAdmin {
    whitelistTokens[token].active = active;
    whitelistTokens[token].timestamp = timestamp;
    emit WhitelistTokens(token, active, timestamp);
  }

  /**
   * deposit ETH
   */
  function() public payable {
    require(msg.value > 0);
    deposit(msg.sender);
  }
  
  /**
   * Make deposit.
   *
   * @param receiver The Ethereum address who make deposit
   *
   */
  function deposit(address receiver) private {
    tokens[0][receiver] = safeAdd(tokens[0][receiver], msg.value);
    emit Deposit(0, receiver, msg.value, tokens[0][receiver]);
  }
  
  /**
   * Withdraw deposit.
   *
   * @param amount Withdraw amount
   *
   */
  function withdraw(uint amount) public {
    require(tokens[0][msg.sender] >= amount);
    tokens[0][msg.sender] = safeSub(tokens[0][msg.sender], amount);
    msg.sender.transfer(amount);
    emit Withdraw(0, msg.sender, amount, tokens[0][msg.sender]);
  }
  
  function depositToken(address token, uint amount) public onlyWhitelistTokens(token, block.timestamp) {
    require(token != address(0));
    require(ERC20(token).transferFrom(msg.sender, this, amount));
    tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
    emit Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  function withdrawToken(address token, uint amount) public {
    require(token != address(0));
    require(tokens[token][msg.sender] >= amount);
    tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount);
    require(ERC20(token).transfer(msg.sender, amount));
    emit Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
  }
  
  function balanceOf(address token, address user) public constant returns (uint) {
    return tokens[token][user];
  }
  
  function order(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce) public {
    bytes32 hash = keccak256(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, msg.sender);
    orders[msg.sender][hash] = true;
    emit Order(tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, msg.sender);
  }
  
  function trade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) public {
    bytes32 hash = keccak256(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user);
    if (!(
      (orders[user][hash] || ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash),v,r,s) == user) &&
      block.timestamp <= expires &&
      safeAdd(orderFills[user][hash], amount) <= amountBuy
    )) revert();
    tradeBalances(tokenBuy, amountBuy, tokenSell, amountSell, user, amount);
    orderFills[user][hash] = safeAdd(orderFills[user][hash], amount);
    emit Trade(tokenBuy, amount, tokenSell, amountSell * amount / amountBuy, user, msg.sender, hash, block.timestamp);
  }

  function tradeBalances(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, address user, uint amount) private {
    uint feeMakeXfer = safeMul(amount, feeMake) / (10**18);
    uint feeTakeXfer = safeMul(amount, feeTake) / (10**18);
    tokens[tokenBuy][msg.sender] = safeSub(tokens[tokenBuy][msg.sender], safeAdd(amount, feeTakeXfer));
    tokens[tokenBuy][user] = safeAdd(tokens[tokenBuy][user], safeSub(amount, feeMakeXfer));
    tokens[tokenBuy][feeAccount] = safeAdd(tokens[tokenBuy][feeAccount], safeAdd(feeMakeXfer, feeTakeXfer));
    tokens[tokenSell][user] = safeSub(tokens[tokenSell][user], safeMul(amountSell, amount) / amountBuy);
    tokens[tokenSell][msg.sender] = safeAdd(tokens[tokenSell][msg.sender], safeMul(amountSell, amount) / amountBuy);
  }
  
  function cancelOrder(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) public {
    bytes32 hash = keccak256(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, msg.sender);
    if (!(orders[msg.sender][hash] || ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash),v,r,s) == msg.sender)) revert();
    orderFills[msg.sender][hash] = amountBuy;
    emit Cancel(tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, msg.sender, v, r, s, hash);
  }
  
  function testTrade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount, address sender) public constant returns(bool) {
    if (!(
      tokens[tokenBuy][sender] >= amount &&
      availableVolume(tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user, v, r, s) >= amount
    )) return false;
    return true;
  }

  function availableVolume(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) public constant returns(uint) {
    bytes32 hash = keccak256(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user);
    if (!(
      (orders[user][hash] || ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash),v,r,s) == user) &&
      block.timestamp <= expires
    )) return 0;
    
    uint available1 = safeSub(amountBuy, orderFills[user][hash]);
    uint available2 = safeMul(tokens[tokenSell][user], amountBuy) / amountSell;
    if (available1<available2) return available1;
    return available2;
  }

  function amountFilled(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user) public constant returns(uint) {
    bytes32 hash = keccak256(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user);
    return orderFills[user][hash];
  }
}

