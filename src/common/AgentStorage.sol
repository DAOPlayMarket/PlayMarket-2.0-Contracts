pragma solidity ^0.4.24;

import './Ownable.sol';

/**
 * @title AgentStorage contract
 */
contract AgentStorage is Ownable {

  struct _Agent {
    bool   state;
    uint32 store;
  }

  // msg.sender => _Agent
  mapping(address => _Agent) public Agents;
  // devs => store ID => isBlocked?
  mapping(address => mapping(uint32 => bool)) public DevsStoreBlocked;
  
  constructor() public {    
    Agents[msg.sender] = _Agent(true, 1);
  }

  modifier onlyAgentStore(uint32 _store) {
    assert(Agents[msg.sender].state);
    assert(Agents[msg.sender].store == _store);
    _;
  }
  
  modifier onlyAgentDev(address _dev) {
    assert(Agents[msg.sender].state);
    assert(!DevsStoreBlocked[_dev][Agents[msg.sender].store]); 
    _;
  }
  
  function updateAgentStorage(address _agent, uint32 _store, bool _state) public onlyOwner {
    assert(_agent != address(0));
    assert(_store != 0);
    Agents[_agent] = _Agent(_state, _store);
  }

  function updateDevState(address _dev, bool _state) public {
    // check agent rights
    assert(Agents[msg.sender].state);    
    // agents can block the devs only in their store
    DevsStoreBlocked[_dev][Agents[msg.sender].store] = _state; 
  }
}