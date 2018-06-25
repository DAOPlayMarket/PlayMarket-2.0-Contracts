pragma solidity ^0.4.16;

import '/src/common/ownership/Ownable.sol';
import '/src/common/ownership/Ownable.sol';
import '/src/PM2/Application.sol';


/**
 * @title User contract - basic contract for working with users
 */
contract User is Application, Ownable, SafeMath{
	event RegistrationUser(address indexed user, uint info);	
	struct _User {
		uint8 status;
		bool confirmation;
		uint info;
	}
	
	struct Purchase {
		bool confirmation;
	}
	uint256 public commission;
	mapping (address => uint256) public developerRevenue;
	mapping (address => _User) public users;
	mapping (address => mapping (uint =>  mapping (uint => Purchase))) public purchases;
	function registrationUser (uint _info) public {
		users[msg.sender] = _User({
			status: 1,
			confirmation: false,
			info: _info
		});
		RegistrationUser(msg.sender,_info);	
	}
	
	function buyApp (uint _idApp, uint _category) public payable {
		assert(applications[_category][_idApp].value == msg.value);
		purchases[msg.sender][_category][_idApp].confirmation = true;
		uint sum = sub(msg.value,div(msg.value,10));
		developerRevenue[applications[_category][_idApp].developer] = add(developerRevenue[applications[_category][_idApp].developer],sum);
		commission = add(commission,sub(msg.value,sum));
	}
}
