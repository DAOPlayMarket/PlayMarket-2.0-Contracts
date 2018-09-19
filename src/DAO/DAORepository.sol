pragma solidity ^0.4.24;

import '../common/Ownable.sol';
import '../common/SafeMath.sol';
import '../common/ERC20I.sol';
import './DAORepositoryI.sol';

/**
 * @title DAO PlayMarket 2.0 repository - safe repository for PMT
 */
contract DAORepository is DAORepositoryI, Ownable, SafeMath {

  bytes32 public version = "1.0.0";

  uint private guardInterval = 5 minutes;

  struct _Proposal {
    uint id;       // proposal ID in DAO
    uint endTime;  // end time of voting
  }
  
  _Proposal[] public Proposals;                              // contains active proposals

  mapping (address => uint) private repository;              // contains PMT balances
  mapping (uint => mapping (address => uint)) private voted; // contains voted PMT on proposals

  bool public WithdrawIsBlockedByFund = false;

  ERC20I public PMT;
  
  /**
   * @dev Constructor sets default parameters
   */
  constructor(address _contract) public {
    PMT = ERC20I(_contract);
  }

  function addProposal(uint _propID, uint _endTime) external onlyOwner returns (uint) {
    Proposals.push(_Proposal({
      id: _propID,
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

  function cleanProposal() external onlyOwner {
    _Proposal[] p; 
    for (uint k = 0; k < Proposals.length; k++) {
      if (Proposals[k].endTime < now + guardInterval) {
        p.push(Proposals[k]);
      }
    }
    Proposals = p;
  }

  function vote(uint _propID, address _voter, uint _numberOfVotes) external onlyOwner {
    assert(repository[_voter] > safeAdd(voted[_propID][_voter], _numberOfVotes));
    voted[_propID][_voter] = safeAdd(voted[_propID][_voter], _numberOfVotes);
  }

  function getNotLockedBalance(address _owner) public onlyOwner returns (uint) {
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
  function makeDeposit(address _from, uint _value) external onlyOwner {
    assert(_from != address(0));
    assert(_value > 0);
    assert(PMT.transferFrom(_from, address(this), _value));
    repository[_from] = safeAdd(repository[_from], _value);
  }

  // refund deposit
  function refund(address _spender, uint _value) external onlyOwner {
    require(!WithdrawIsBlockedByFund);
    require(PMT.allowance(address(this), _spender) == 0);

    assert(_spender != address(0));
    uint freeBalance = getNotLockedBalance(_spender);
    assert(freeBalance >=_value);
    repository[_spender] = safeSub(repository[_spender], _value);
    assert(repository[_spender] >= 0);

    PMT.approve(_spender, _value);
  }

  function changeStateByFund(bool _state) external onlyOwner {
    WithdrawIsBlockedByFund = _state;
  } 
  
  function setPMTContract(address _contract) external onlyOwner {
    PMT = ERC20I(_contract);
  }

  function() public payable {}
}