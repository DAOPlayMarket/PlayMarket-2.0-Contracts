pragma solidity ^0.4.15;

import '/src/common/ownership/Ownable.sol';
import '/src/common/ownership/Ownable.sol';
import '/src/PM2/Developer.sol';

contract Application is Developer, Ownable, SafeMath{
	event RegistrationApplication(uint8 category, uint countAppOfCategory, bool free, uint256 value, address indexed developer, string nameApp, string hashIpfs);
	event changeHashIpfsEvent(uint8 category, uint idApp, string hashIpfs);
	struct _Application {
		uint8 status;
		uint8 category;
		bool free;
		bool confirmation;
		uint256 value;
		address developer;
		string nameApp; 
		string hashIpfs;
	}
	
	mapping (uint => uint) public countAppOfCategory; 
	mapping (uint => mapping (uint => _Application)) public applications;
	function registrationApplication (uint8 _category, bool _free,uint256 _value, string _nameApp, string _hashIpfs) public {
		assert(developers[msg.sender].confirmation==true);
		countAppOfCategory[_category] = add(countAppOfCategory[_category],1); 
		applications[_category][countAppOfCategory[_category]]=_Application({
			status: 1,
			category: _category,
			free: _free,
			confirmation: false,
			value: _value,
			developer: msg.sender,
			nameApp: _nameApp,
			hashIpfs: _hashIpfs
		});
		RegistrationApplication(_category, countAppOfCategory[_category], _free, _value, msg.sender, _nameApp, _hashIpfs );
	}
	
	function changeHashIpfs(uint _idApp, uint8 _category, string _hashIpfs) public {
		assert(developers[msg.sender].confirmation==true);
		assert(applications[_category][_idApp].confirmation==true);
		applications[_category][_idApp].hashIpfs =_hashIpfs;
		changeHashIpfsEvent(_category, _idApp, _hashIpfs);
	}
}
