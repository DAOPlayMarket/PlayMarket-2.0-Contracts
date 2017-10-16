pragma solidity ^0.4.15;

import '/src/common/ownership/Ownable.sol';
import '/src/common/SafeMath.sol';

contract Developer is Ownable, SafeMath {
	event RegistrationDeveloper(address indexed developer, uint info);	
	struct _Developer {
		bool confirmation;
		uint info;
		uint8 status;
	}
	
	struct Vote {
        uint vote; 
		bool voted; 
    }
	
	mapping (address => _Developer) public developers;
	mapping (address => mapping (address => Vote)) public votesDeveloper;
	
	function registrationDeveloper (uint _info) public {
		developers[msg.sender]=_Developer({
			confirmation: false,
			info: _info,
			status: 1
		});
		RegistrationDeveloper(msg.sender,_info);	
	}
	
	function voting(address _developer,uint vote) public {
		assert(vote<=5);
		Vote storage sender = votesDeveloper[_developer][msg.sender];
        assert(!sender.voted);
        sender.voted = true;
		sender.vote=vote;
	}
	
}
