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
  
  _Proposal[] public Proposals;                             // contains all proposals
  _Proposal[] public ProposalsActive;                       // contains active proposals
  
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
  function addProposal(uint _propID, uint _endTime) external onlyOwner {
    Proposals.push(_Proposal({
      propID: _propID,
      endTime: _endTime
    }));
    
    ProposalsActive.push(_Proposal({
      propID: _propID,
      endTime: _endTime
    }));
  }

  function changeProposal(uint _propID, uint _endTime) external onlyOwner {
    Proposals[_propID].endTime = _endTime;
    uint k = 0;
    for(k; k < ProposalsActive.length; k++){
      if(ProposalsActive[k].propID == _propID){
        ProposalsActive[k].endTime = _endTime;
      }
    }
  }  

  function delProposalActive(uint _propID) external onlyOwner {
    assert(_propID >= 0 && _propID < Proposals.length);
    uint k = 0;
    while (k < ProposalsActive.length){
      if(ProposalsActive[k].propID == _propID){
        require(ProposalsActive[k].endTime < now + guardInterval);
        ProposalsActive[k] = ProposalsActive[ProposalsActive.length-1];
        ProposalsActive.length = ProposalsActive.length-1;   
      }else{
        k++;
      }
    }
  }

  function cleanProposalActive() external onlyAgent {
    uint k = 0;
    while (k < ProposalsActive.length){
      if(ProposalsActive[k].endTime < now + guardInterval){
        ProposalsActive[k] = ProposalsActive[ProposalsActive.length-1];
        ProposalsActive.length = ProposalsActive.length-1;   
      }else{
        k++;
      }
    }
  }

  function vote(uint _propID, address _voter, uint _numberOfVotes) external onlyOwner returns (bool) {
    assert(repository[_voter] >= safeAdd(voted[_propID][_voter], _numberOfVotes));
    voted[_propID][_voter] = safeAdd(voted[_propID][_voter], _numberOfVotes);
    return true;
  }

  function getVoted(uint _propID, address _voter) external view returns (uint) {
    return voted[_propID][_voter];
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

  function getBalance(address _owner) public view returns (uint) {
    return repository[_owner];
  }

  function getNotLockedBalance(address _owner) public view returns (uint) {
    uint lock = 0;
    for (uint k = 0; k < ProposalsActive.length; k++) {
      if (ProposalsActive[k].endTime > now - guardInterval) {
        if (lock < voted[ProposalsActive[k].propID][_owner]) {
          lock = voted[ProposalsActive[k].propID][_owner];
        }
      }
    }
    return safeSub(repository[_owner], lock);
  }

  // make deposit PMT
  // make sure, approve to this contract first
  function makeDeposit(uint _value) external {
    assert(_value > 0);
    assert(PMT.transferFrom(msg.sender, address(this), _value));
    repository[msg.sender] = safeAdd(repository[msg.sender], _value);
  }

  // refund deposit
  function refund(uint _value) external {
    require(!WithdrawIsBlockedByFund);

    uint freeBalance = getNotLockedBalance(msg.sender);
    assert(freeBalance >=_value);
    repository[msg.sender] = safeSub(repository[msg.sender], _value);

    PMT.transfer(msg.sender, _value);
  }

  event AcceptedEtherEvent(address _sender, uint _value);
  
  function() public payable {
    emit AcceptedEtherEvent(msg.sender, msg.value);
  }
}