pragma solidity ^0.4.24;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {

    /**
    * @dev Subtracts two numbers, reverts on overflow.
    */
    function safeSub(uint256 x, uint256 y) internal pure returns (uint256) {
        assert(y <= x);
        uint256 z = x - y;
        return z;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function safeAdd(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        assert(z >= x);
        return z;
    }
	
	/**
    * @dev Integer division of two numbers, reverts on division by zero.
    */
    function safeDiv(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x / y;
        return z;
    }
    
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */	
    function safeMul(uint256 x, uint256 y) internal pure returns (uint256) {    
        if (x == 0) {
            return 0;
        }
    
        uint256 z = x * y;
        assert(z / x == y);
        return z;
    }

    /**
    * @dev Returns the integer percentage of the number.
    */
    function safePerc(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0) {
            return 0;
        }
        
        uint256 z = x * y;
        assert(z / x == y);    
        z = z / 100;
        return z;
    }

    /**
    * @dev Returns the minimum value of two numbers.
    */	
    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x <= y ? x : y;
        return z;
    }

    /**
    * @dev Returns the maximum value of two numbers.
    */
    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x >= y ? x : y;
        return z;
    }
}