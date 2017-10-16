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
