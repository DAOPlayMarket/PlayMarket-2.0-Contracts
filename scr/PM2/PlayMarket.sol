pragma solidity ^0.4.15;

import '/src/common/ownership/Ownable.sol';
import '/src/common/ownership/Ownable.sol';
import '/src/PM2/User.sol';

contract PlayMarket is User, Ownable, SafeMath{

	function confirmationDeveloper(address _developer, bool _value) public onlyOwner {
		assert(developers[_developer].status>0 && developers[_developer].status<=1);
		developers[_developer].confirmation = _value;
	}

	function confirmationApplication(uint _application,uint _category, bool _value) public onlyOwner{
		assert(applications[_category][_application].status>0 && applications[_category][_application].status<=1);
		applications[_category][_application].confirmation = _value;
	}
	
	function confirmationUser(address _user, bool _value) public onlyOwner{
		assert(users[_user].status>0 && users[_user].status<=1);
		users[_user].confirmation = _value;
	}
	
	function collect() public onlyOwner {
		owner.transfer(commission);
	}
	
	function collectDeveloper() public {
		msg.sender.transfer(developerRevenue[msg.sender]);
	}
}
