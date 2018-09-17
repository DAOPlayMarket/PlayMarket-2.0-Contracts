pragma solidity ^0.4.24;

/**
 * @title PlayMarket 2.0 Exchange Interface
 */
contract PEXI {

    function setWhitelistTokens(address token, bool active, uint256 timestamp) external;
    function withdraw(uint amount) external;
    function depositToken(address token, uint amount) external;
    function withdrawToken(address token, uint amount) external;
    function balanceOf(address token, address user) external view returns (uint);
    
    function order(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce) external;
    function trade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) external;
    function tradeBalances(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, address user, uint amount) private;
    function cancelOrder(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) external;
    
    function testTrade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount, address sender) external view returns(bool);
    function availableVolume(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) public view returns(uint);
    
    function amountFilled(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user) external view returns(uint);

    function setAccountType(address user_, uint256 type_) external;
    function getAccountType(address user_) external view returns(uint256);
    function setFeeType(uint256 type_ , uint256 feeMake_, uint256 feeTake_) external;
    function getFeeMake(uint256 type_ ) external view returns(uint256);
    function getFeeTake(uint256 type_ ) external view returns(uint256);
    function changeFeeAccount(address feeAccount_) external;
}