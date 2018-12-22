pragma solidity ^0.4.25;

import './AppDD.sol';

/**
 * @title External interface for AppDAO
 */
interface CommonI {
    function transferOwnership(address _newOwner) external;
    function acceptOwnership() external;
    function updateAgent(address _agent, bool _state) external;    
}

/**
 * @title Decentralized Autonomous Organization for Application
 */
contract AppDAO is AppDD {

    //minimum balance for adding proposal - default 100 tokens
    uint minBalance = 10000000000; 
    // minimum quorum - number of votes must be more than minimum quorum
    uint public minimumQuorum;
    // debating period duration
    uint public debatingPeriodDuration;
    // requisite majority of votes (by the system a simple majority)
    uint public requisiteMajority;

    struct _Proposal {
        // proposal may execute only after voting ended
        uint endTimeOfVoting;
        // if executed = true
        bool executed;
        // if passed = true
        bool proposalPassed;
        // number of votes already voted
        uint numberOfVotes;
        // in support of votes
        uint votesSupport;
        // against votes
        uint votesAgainst;
        
        // the address where the `amount` will go to if the proposal is accepted
        address recipient;
        // the amount to transfer to `recipient` if the proposal is accepted.
        uint amount;
        // keccak256(abi.encodePacked(recipient, amount, transactionByteCode));
        bytes32 transactionHash;

        // a plain text description of the proposal
        string desc;
        // a hash of full description data of the proposal (optional)
        string fullDescHash;
    }

    _Proposal[] public Proposals;

    event ProposalAdded(uint proposalID, address recipient, uint amount, string description, string fullDescHash);
    event Voted(uint proposalID, bool position, address voter, string justification);
    event ProposalTallied(uint proposalID, uint votesSupport, uint votesAgainst, uint quorum, bool active);    
    event ChangeOfRules(uint newMinimumQuorum, uint newdebatingPeriodDuration, uint newRequisiteMajority);
    event Payment(address indexed sender, uint amount);

    // Modifier that allows only owners of Application tokens to vote and create new proposals
    modifier onlyMembers {
        require(balances[msg.sender] > 0);
        _;
    }

    /**
     * Change voting rules
     *
     * Make so that Proposals need to be discussed for at least `_debatingPeriodDuration/60` hours,
     * have at least `_minimumQuorum` votes, and have 50% + `_requisiteMajority` votes to be executed
     *
     * @param _minimumQuorum how many members must vote on a proposal for it to be executed
     * @param _debatingPeriodDuration the minimum amount of delay between when a proposal is made and when it can be executed
     * @param _requisiteMajority the proposal needs to have 50% plus this number
     */
    function changeVotingRules(
        uint _minimumQuorum,
        uint _debatingPeriodDuration,
        uint _requisiteMajority
    ) onlyOwner public {
        minimumQuorum = _minimumQuorum;
        debatingPeriodDuration = _debatingPeriodDuration;
        requisiteMajority = _requisiteMajority;

        emit ChangeOfRules(minimumQuorum, debatingPeriodDuration, requisiteMajority);
    }

    /**
     * Add Proposal
     *
     * Propose to send `_amount / 1e18` ether to `_recipient` for `_desc`. `_transactionByteCode ? Contains : Does not contain` code.
     *
     * @param _recipient who to send the ether to
     * @param _amount amount of ether to send, in wei
     * @param _desc Description of job
     * @param _fullDescHash Hash of full description of job
     * @param _transactionByteCode bytecode of transaction
     */
    function addProposal(address _recipient, uint _amount, string _desc, string _fullDescHash, bytes _transactionByteCode, uint _debatingPeriodDuration) onlyMembers public returns (uint) {
        require(balances[msg.sender] > minBalance);

        if (_debatingPeriodDuration == 0) {
            _debatingPeriodDuration = debatingPeriodDuration;
        }

        Proposals.push(_Proposal({      
            endTimeOfVoting: now + _debatingPeriodDuration * 1 minutes,
            executed: false,
            proposalPassed: false,
            numberOfVotes: 0,
            votesSupport: 0,
            votesAgainst: 0,
            recipient: _recipient,
            amount: _amount,
            transactionHash: keccak256(abi.encodePacked(_recipient, _amount, _transactionByteCode)),
            desc: _desc,
            fullDescHash: _fullDescHash
        }));
        
        // add proposal in ERC20 base contract for block transfer
        super.addProposal(Proposals.length-1, Proposals[Proposals.length-1].endTimeOfVoting);

        emit ProposalAdded(Proposals.length-1, _recipient, _amount, _desc, _fullDescHash);

        return Proposals.length-1;
    }

    /**
     * Check if a proposal code matches
     *
     * @param _proposalID number of the proposal to query
     * @param _recipient who to send the ether to
     * @param _amount amount of ether to send
     * @param _transactionByteCode bytecode of transaction
     */
    function checkProposalCode(uint _proposalID, address _recipient, uint _amount, bytes _transactionByteCode) view public returns (bool) {
        require(Proposals[_proposalID].recipient == _recipient);
        require(Proposals[_proposalID].amount == _amount);
        // compare ByteCode        
        return Proposals[_proposalID].transactionHash == keccak256(abi.encodePacked(_recipient, _amount, _transactionByteCode));
    }

    /**
     * Log a vote for a proposal
     *
     * Vote `supportsProposal? in support of : against` proposal #`proposalID`
     *
     * @param _proposalID number of proposal
     * @param _supportsProposal either in favor or against it
     * @param _justificationText optional justification text
     */
    function vote(uint _proposalID, bool _supportsProposal, string _justificationText) onlyMembers public returns (uint) {
        // Get the proposal
        _Proposal storage p = Proposals[_proposalID]; 
        require(now <= p.endTimeOfVoting);

        // get numbers of votes for msg.sender
        uint votes = safeSub(balances[msg.sender], voted[_proposalID][msg.sender]);
        require(votes > 0);

        voted[_proposalID][msg.sender] = safeAdd(voted[_proposalID][msg.sender], votes);

        // Increase the number of votes
        p.numberOfVotes = p.numberOfVotes + votes;
        
        if (_supportsProposal) {
            p.votesSupport = p.votesSupport + votes;
        } else {
            p.votesAgainst = p.votesAgainst + votes;
        }
        
        emit Voted(_proposalID, _supportsProposal, msg.sender, _justificationText);
        return p.numberOfVotes;
    }

    /**
     * Finish vote
     *
     * Count the votes proposal #`_proposalID` and execute it if approved
     *
     * @param _proposalID proposal number
     * @param _transactionByteCode optional: if the transaction contained a bytecode, you need to send it
     */
    function executeProposal(uint _proposalID, bytes _transactionByteCode) public {
        // Get the proposal
        _Proposal storage p = Proposals[_proposalID];

        require(now > p.endTimeOfVoting                                                                       // If it is past the voting deadline
            && !p.executed                                                                                    // and it has not already been executed
            && p.transactionHash == keccak256(abi.encodePacked(p.recipient, p.amount, _transactionByteCode))  // and the supplied code matches the proposal
            && p.numberOfVotes >= minimumQuorum);                                                             // and a minimum quorum has been reached
        // then execute result
        if (p.votesSupport > requisiteMajority) {
            // Proposal passed; execute the transaction
            require(p.recipient.call.value(p.amount)(_transactionByteCode));
            p.proposalPassed = true;
        } else {
            // Proposal failed
            p.proposalPassed = false;
        }
        p.executed = true;

        // delete proposal from active list
        super.delProposal(_proposalID);
       
        // Fire Events
        emit ProposalTallied(_proposalID, p.votesSupport, p.votesAgainst, p.numberOfVotes, p.proposalPassed);
    }

    // function is needed if execution transactionByteCode in Proposal failed
    function delActiveProposal(uint _proposalID) public onlyOwner {
        // delete proposal from active list
        super.delProposal(_proposalID);   
    }

    /**
    * @dev Allows the DAO to transfer control of the _contract to a _newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _contract, address _newOwner) public onlyOwner {
        CommonI(_contract).transferOwnership(_newOwner);
    }

    /**
     * @dev Accept transferOwnership on a this (DAO) contract
     */
    function acceptOwnership(address _contract) public onlyOwner {
        CommonI(_contract).acceptOwnership();        
    }

    function updateAgent(address _contract, address _agent, bool _state) public onlyOwner {
        CommonI(_contract).updateAgent(_agent, _state);        
    }

    /**
     * Set minimum balance for adding proposal
     */
    function setMinBalance(uint _minBalance) public onlyOwner {
        assert(_minBalance > 0);
        minBalance = _minBalance;
    }
}