pragma solidity ^0.4.24;

import '../../common/Agent.sol';
import '../../common/SafeMath.sol';
import '../storage/devStorageI.sol';

/**
 * @title Developer contract - basic contract for working with developers
 */
contract Developer is Agent, SafeMath {
  
  bool autoConfirm = true;
  int defRaiting = 0;

  DevStorageI public DevStorage;

  event setStorageContractEvent(address _contract);

  function setStorageContract(address _contract) external onlyOwner {
    DevStorage = DevStorageI(_contract);
    emit setStorageContractEvent(_contract);
  }
  
  /**
   * @dev 
   * @param _dev Developer address
   * @param _value Developer revenue 
   */
  function buyApp(address _dev, uint _value) public onlyAgent {
    //assert(developers[_dev].isSet);
  }

  /**
   * @dev 
   * @param _dev Developer address
   * @param _name Developer name
   * @param _info Additional Information
   */
  function registrationDeveloper(address _dev, bytes32 _name, bytes32 _info) public onlyAgent {
    //assert(!developers[_dev].isSet);
  }
	
  /**
   * @dev 
   * @param _dev Developer address
   * @param _name Developer name
   * @param _info Additional Information
   */
  function changeDeveloperInfo(address _dev, bytes32 _name, bytes32 _info) public onlyAgent {
    //assert(developers[_dev].isSet);
  }
  
  /**
   * @dev 
   * @param _dev Developer address
   * @param _raiting Developer raiting
   */
  function changeDeveloperRaiting(address _dev, int _raiting) public onlyAgent {
    //assert(developers[_dev].isSet);
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
    //require(developers[_dev].confirmation == true);
    return true;
  }
  
  /**
   * @dev 
   * @param _dev Developer address
   * @param _value value
   */
  function confirmationDeveloper(address _dev, bool _value) public onlyAgent {
    //assert(developers[_dev].isSet);
  }

  /**
   * @dev 
   * @param _dev The address of the node 
   * @return amount revenue
   */
  function getRevenue(address _dev) external constant onlyAgent returns (uint256) {
    //return developerRevenue[_dev];
  }  

  /**
   * @dev 
   * @param _dev Developer address
   */  
  function collectDeveloper(address _dev) public onlyAgent{
    //developerRevenue[_dev] = 0;
  }
}