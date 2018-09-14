pragma solidity ^0.4.24;

import '/src/common/SafeMath.sol';
import '/src/common/Agent.sol';
import '/src/platform/common/appI.sol';
import '/src/platform/common/appStorageI.sol';
//import '/src/platform/common/objStorageI.sol';

/**
 * @title Application contract - basic contract for working with applications
 */
contract Application is ApplicationI, Agent, SafeMath {

  AppStorageI public AppStorage;

  event setStorageContractEvent(address _contract);

  function setStorageContract(address _contract) external onlyOwner {
    AppStorage = AppStorageI(_contract);
    emit setStorageContractEvent(_contract);
  }
	
  /**
   * @dev 
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _publish publish
   * @param _price price App
   * @param _dev Developer address
   * @return number of current applications
   */
  function registrationApplication(string _hash, string _hashTag, bool _publish, uint256 _price, address _dev, uint _kind) external onlyAgent returns (uint256) {    
    return AppStorage.addApp(_dev, _hash, _hashTag, _price, _kind, _publish, false);
  }
  
  /**
   * @dev 
   * @param _app ID application
   * @param _status true/false
   */
  function confirmationApplication(uint _app, bool _status) external onlyAgent {
    AppStorage.confirmApp(_app, _status);
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function registrationApplicationICO(uint _app, string _hash, string _hashTag, address _dev) external onlyAgent {
    require(checkDeveloper(_app,_dev));
    AppStorage.addAppICO(_app, _hash, _hashTag);
  }
	
   /**
   * @dev 
   * @param _app ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function changeHash(uint _app, string _hash, string _hashTag, address _dev) external onlyAgent {  
    require(checkDeveloper(_app,_dev));
    AppStorage.changeHash(_app, _hash, _hashTag);
  }
  
  /**
   * @dev 
   * @param _app ID application
   * @param _publish publish
   * @param _dev Developer address
   */
  function changePublish(uint _app, bool _publish, address _dev) external onlyAgent {
    require(checkDeveloper(_app,_dev));
    AppStorage.changePublish(_app, _publish);
    
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _price new price application
   * @param _dev Developer address
   */
  function changePrice(uint _app, uint256 _price, address _dev) external onlyAgent {
    require(checkDeveloper(_app,_dev));
    AppStorage.changePrice(_app, _price);
  }
  
  /**
   * @dev 
   * @param _app ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function changeIcoHash(uint _app, string _hash, uint16 _hashTag, address _dev) external onlyAgent {
    require(checkDeveloper(_app,_dev));
    AppStorage.changeIcoHash(_app, _hash, _hashTag);
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _dev Developer address
   * @return boolean
   */  
  function checkDeveloper(uint _app, address _dev) private view returns (bool success) {
      require(AppStorage.getDeveloper(_app) == _dev);
      return true;
  }

  /**
   * @dev 
   * @param _app ID application
   * @return developer address
   */  
  function getDeveloper(uint _app) external onlyAgent view returns (address) {
    return AppStorage.getDeveloper(_app);
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _price price application
   * @return boolean
   */  
  function checkSum(uint _app, uint256 _price) private view returns (bool success) {
      require(AppStorage.getPrice(_app) == _price);
      return true;
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _user user address
   * @param _price price application in virtual units (PMC)
   */  
  function buyApp(uint _app, address _user, uint _price) external onlyAgent {
    require(checkSum(_app,_price));
    AppStorage.buyObject(_app, _user, 0, true);
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _user user address
   * @param _obj ID object in application
   */  
  function buyObject(uint _app, address _user, uint _obj, bool _state) external onlyAgent {
    AppStorage.buyObject(_app, _user, _obj, _state);
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _user user address
   * @param _obj ID object in application
   * @param _price price of object in application
   */  
  function buyObject(uint _app, address _user, uint _obj, bool _state, uint _price) external onlyAgent {
    AppStorage.buyObject(_app, _user, _obj, _state);
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _user user address
   * @param _user _obj ID object (0 - means application)
   * @return boolean
   */
  function checkBuy(uint _app, address _user, uint _obj) external view returns (bool success) {
    return AppStorage.checkBuy(_app, _user, _obj);
  }
}