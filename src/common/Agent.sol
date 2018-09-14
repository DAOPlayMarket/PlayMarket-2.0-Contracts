pragma solidity ^0.4.24;

import './Ownable.sol';

/**
 * @title Agent contract - base contract with an agent
 */
contract Agent is Ownable {

  address public defAgent;

  mapping(address => bool) public Agents;
  
  constructor() public {
    defAgent = msg.sender;
    Agents[msg.sender] = true;
  }
  
  modifier onlyAgent() {
    assert(Agents[msg.sender]);
    _;
  }
  
  function updateAgent(address _agent, bool _status) public onlyOwner {
    assert(_agent != address(0));
    Agents[_agent] = _status;
  }  
}