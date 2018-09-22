pragma solidity ^0.4.24;

/**
 * @title DAO PlayMarket 2.0 common interface for PMDAO contract
 */
interface CommonI {
	function transferOwnership(address _newOwner) external;
	function acceptOwnership() external;
	function updateAgent(address _agent, bool _state) external;
	function updateAgentStorage(address _agent, uint32 _store, bool _state) external;
}