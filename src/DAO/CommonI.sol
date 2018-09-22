pragma solidity ^0.4.24;

/**
 * @title DAO PlayMarket 2.0 common interface for PMDAO contract
 */
interface CommonI {
	function transferOwnership(address _newOwner) public;
	function acceptOwnership() external;	
}