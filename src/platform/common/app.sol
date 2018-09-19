pragma solidity ^0.4.24;

import '../../common/Agent.sol';
import '../../common/SafeMath.sol';
import '../storage/appStorageI.sol';
import '../storage/logStorageI.sol';

/**
 * @title Application contract - basic contract for working with applications storage
 */
contract App is Agent, SafeMath {

  AppStorageI public AppStorage;
  LogStorageI public LogStorage;

  event setAppStorageContractEvent(address _contract);

  // link to app storage
  function setAppStorageContract(address _contract) public onlyOwner {
    AppStorage = AppStorageI(_contract);
    emit setAppStorageContractEvent(_contract);
  }

  // link to log storage
  function setAppLogStorageContract(address _contract) public onlyOwner {
    LogStorage = LogStorageI(_contract);    
  }  

 // add/register new application
  function addApp(uint32 _hashType, uint32 _appType, uint _price, bool _publish, string _hash) external returns (uint) {
    uint app = AppStorage.addApp(_hashType, _appType, store, _price, _publish, msg.sender, _hash);
    LogStorage.addAppEvent(app, _hashType, _appType, _price, _publish, msg.sender, _hash);
    return app;
  }
  
  function setAppConfirmation(uint _app, bool _state) external onlyAgent {
    AppStorage.setConfirmation(_app, _state);
    LogStorage.setConfirmationAppEvent(_app, _state, msg.sender); // msg.sender - moderator
  }
  
  // after change hash application - confirmation sets to false
  function changeHash(uint _app, string _hash, uint32 _hashType) external {  
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.changeHashApp(_app, _hash, _hashType);
    LogStorage.changeHashAppEvent(_app, _hash, _hashType);
  }
  
  function changePublish(uint _app, bool _publish) external {
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.setPublish(_app, _publish);
    LogStorage.changePublishEvent(_app, _publish);
  }

  function changePrice(uint _app, uint _price) external {
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.setPrice(_app, _price);
    LogStorage.changePriceEvent(_app, _price);
  }
  
  function changeHashICO(uint _app, string _hash, uint32 _hashType) external onlyAgent {
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.changeHashAppICO(_app, _hash, _hashType);
    LogStorage.changeHashAppICOEvent(_app, _hash, _hashType);
  }

  function getDeveloper(uint _app) external view returns (address) {
    return AppStorage.getDeveloper(_app);
  }

  // check application buy
  function checkBuy(uint _app, address _user) external view returns (bool success) {
    return AppStorage.checkBuy(_app, _user, 0);
  }

  // check objects buy
  function checkBuy(uint _app, address _user, uint _obj) external view returns (bool success) {
    return AppStorage.checkBuy(_app, _user, _obj);
  }
}