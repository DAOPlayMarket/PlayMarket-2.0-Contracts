pragma solidity ^0.4.24;

import '/src/common/Agent.sol';
import '/src/common/SafeMath.sol';

/**
 * @title Developer contract - basic contract for working with developers
 */
contract Developer is Agent, SafeMath {
  
  struct _Developer {    
    bytes32 name;
    bytes32 info;    
    bool isSet;
    bool confirmation;
    int raiting;
  }

  mapping (address => uint256) public developerRevenue;
  mapping (address => _Developer) public developers;

  bool autoConfirm = true;
  int defRaiting = 0;
  
  /**
   * @dev 
   * @param _dev Developer address
   * @param _value Developer revenue 
   */
  function buyApp(address _dev, uint _value) public onlyAgent {
    assert(developers[_dev].isSet);
    developerRevenue[_dev] = safeAdd(developerRevenue[_dev], _value);
  }

  /**
   * @dev 
   * @param _dev Developer address
   * @param _name Developer name
   * @param _info Additional Information
   */
  function registrationDeveloper(address _dev, bytes32 _name, bytes32 _info) public onlyAgent {
    assert(!developers[_dev].isSet);
    developers[_dev]=_Developer({
      confirmation: autoConfirm,
      name: _name,
      info: _info,
      isSet: true,      
      raiting: defRaiting
    });
  }
	
  /**
   * @dev 
   * @param _dev Developer address
   * @param _name Developer name
   * @param _info Additional Information
   */
  function changeDeveloperInfo(address _dev, bytes32 _name, bytes32 _info) public onlyAgent {
    assert(developers[_dev].isSet);
    developers[_dev].name = _name;
    developers[_dev].info = _info;
  }
  
  /**
   * @dev 
   * @param _dev Developer address
   * @param _raiting Developer raiting
   */
  function changeDeveloperRaiting(address _dev, int _raiting) public onlyAgent {
    assert(developers[_dev].isSet);
    developers[_dev].raiting = _raiting;
    //if (_raiting < 0) developers[_dev].confirmation = false;
  }

  /**
   * @dev 
   * @param _autoConfirm autoConfirm
   */
  function changeAutoConfirm(bool _autoConfirm) public onlyOwner {
    autoConfirm = _autoConfirm;
  }
  
  /**
   * @dev 
   * @param _defRaiting Developer default raiting sets on registration
   */
  function changeDefRaiting(int _defRaiting) public onlyOwner {
    defRaiting = _defRaiting;
  }

  /**
   * @dev 
   * @param _dev Developer address
   */
  function checkConfirmation(address _dev) public constant onlyAgent returns (bool success) {
    require(developers[_dev].confirmation == true);
    return true;
  }
  
  /**
   * @dev 
   * @param _dev Developer address
   * @param _value value
   */
  function confirmationDeveloper(address _dev, bool _value) public onlyAgent {
    assert(developers[_dev].isSet);
    developers[_dev].confirmation = _value;
  }

  /**
   * @dev 
   * @param _dev The address of the node 
   * @return amount revenue
   */
  function getRevenue(address _dev) external constant onlyAgent returns (uint256) {
    return developerRevenue[_dev];
  }  

  /**
   * @dev 
   * @param _dev Developer address
   */  
  function collectDeveloper(address _dev) public onlyAgent{
    developerRevenue[_dev] = 0;
  }
}