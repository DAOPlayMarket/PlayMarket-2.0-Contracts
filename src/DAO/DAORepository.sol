pragma solidity ^0.4.24;

import '../common/Agent.sol';
import '../common/SafeMath.sol';
import '../common/ERC20I.sol';
import './DAORepositoryI.sol';

/**
 * @title DAO PlayMarket 2.0 repository - safe repository for PMT
 */
contract DAORepository is DAORepositoryI, Agent, SafeMath {

  bytes32 public version = "1.0.0";

  uint private guardInterval = 5 minutes;

  struct _Proposal {
    uint propID;          // proposal ID in DAO    
    uint endTime;         // end time of voting
  }
  
  _Proposal[] public Proposals;                             // contains active proposals

  mapping (address => uint) public repository;              // contains PMT balances
  mapping (uint => mapping (address => uint)) public voted; // contains voted PMT on proposals

  bool public WithdrawIsBlockedByFund = false;

  ERC20I public PMT;
  
  /**
   * @dev Constructor sets default parameters
   */
  constructor(address _contract) public {
    PMT = ERC20I(_contract);
  }

  /**
   * Access only owner (DAO)
   */

  function addProposal(uint _propID, uint _endTime) external onlyOwner returns (uint) {
    Proposals.push(_Proposal({
      propID: _propID,
      endTime: _endTime
    }));

    return Proposals.length-1;
  }

  function changeProposal(uint _propID, uint _endTime) external onlyOwner {
    Proposals[_propID].endTime = _endTime;    
  }  

  function delProposal(uint _id) external onlyOwner {
    assert(_id >= 0 && _id < Proposals.length);
    assert(Proposals[_id].endTime > now + guardInterval);
    Proposals[_id] = Proposals[Proposals.length-1];
    Proposals.length = Proposals.length-1;
  }

  function cleanProposal() external onlyAgent {
    _Proposal[] p; 
    for (uint k = 0; k < Proposals.length; k++) {
      if (Proposals[k].endTime > now + guardInterval) {
        p.push(Proposals[k]);
      }
    }
    Proposals = p;
  }

  function vote(uint _propID, address _voter, uint _numberOfVotes) external onlyOwner returns (bool) {
    assert(repository[_voter] >= safeAdd(voted[_propID][_voter], _numberOfVotes));
    voted[_propID][_voter] = safeAdd(voted[_propID][_voter], _numberOfVotes);
    return true;
  }

  function changeStateByFund(bool _state) external onlyAgent {
    WithdrawIsBlockedByFund = _state;
  } 
  
  function setPMTContract(address _contract) external onlyOwner {
    PMT = ERC20I(_contract);
  }


  /**
   * Public access everyone
   */

  function getBalance(address _owner) public returns (uint) {
    return repository[_owner];
  }

  function getNotLockedBalance(address _owner) public returns (uint) {
    uint lock = 0;
    for (uint k = 0; k < Proposals.length; k++) {
      if (Proposals[k].endTime > now + guardInterval) {
        if (lock < voted[k][_owner]) {
          lock = voted[k][_owner];
        }
      }
    }
    return safeSub(repository[_owner], lock);
  }

  // make deposit PMT
  // make sure, approve to this contract first
  function makeDeposit(address _from, uint _value) external {
    assert(_from != address(0));
    assert(_value > 0);
    assert(PMT.transferFrom(_from, address(this), _value));
    repository[_from] = safeAdd(repository[_from], _value);
  }

  // refund deposit
  function refund(uint _value) external {
    require(!WithdrawIsBlockedByFund);
    //require(PMT.allowance(address(this), msg.sender) == 0);

    assert(msg.sender != address(0));
    uint freeBalance = getNotLockedBalance(msg.sender);
    assert(freeBalance >=_value);
    repository[msg.sender] = safeSub(repository[msg.sender], _value);
    assert(repository[msg.sender] >= 0);

    //PMT.approve(msg.sender, _value);
    PMT.transfer(msg.sender, _value);
  }

  event AcceptedEtherEvent(address _sender, uint _value);
  
  function() public payable {
    emit AcceptedEtherEvent(msg.sender, msg.value);
  }
}