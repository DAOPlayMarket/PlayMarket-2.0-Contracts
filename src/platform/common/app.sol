pragma solidity ^0.4.24;

import '../../Base.sol';
import '../../common/Agent.sol';
import '../../common/SafeMath.sol';
import '../storage/appStorageI.sol';
import '../storage/logStorageI.sol';

/**
 * @title Application contract - basic contract for working with applications storage
 */
contract App is Agent, SafeMath, Base {

  AppStorageI public AppStorage;

  event setAppStorageContractEvent(address _contract);

  // link to app storage
  function setAppStorageContract(address _contract) public onlyOwner {
    AppStorage = AppStorageI(_contract);
    emit setAppStorageContractEvent(_contract);
  }

  function setAppConfirmation(uint _app, bool _state, uint32 _hashType, string _hash) external onlyAgent {
    AppStorage.setConfirmation(_app, _state);
    LogStorage.setConfirmationAppEvent(_app, _state, msg.sender, _hashType, _hash); // msg.sender - moderator
  }
  
  // after change hash application - confirmation sets to false
  function changeHashApp(uint _app, string _hash, uint32 _hashType) external {  
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.changeHashApp(_app, _hash, _hashType);
    LogStorage.changeHashAppEvent(_app, _hash, _hashType);
  }
  
  function changePublish(uint _app, bool _publish) external {
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.setPublish(_app, _publish);
    LogStorage.changePublishEvent(_app, _publish);
  }

  function setPrice(uint _app, uint _obj, uint _price) external {
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.setPrice(_app, _obj, _price);
    LogStorage.setPriceEvent(_app, _obj, _price);
  }

  function setPrice(uint _app, uint[] _arrObj, uint[] _arrPrice) external {
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.setPrice(_app, _arrObj, _arrPrice);
  }
  
  function setPrice(uint _app, uint[] _arrObj, uint _price) external {
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.setPrice(_app, _arrObj, _price);
  }
  
  function setDuration(uint _app, uint _obj, uint _duration) external {
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.setDuration(_app, _obj, _duration);
  }

  function setDuration(uint _app, uint[] _arrObj, uint[] _arrPrice) external {
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.setDuration(_app, _arrObj, _arrPrice);
  }
  
  function setDuration(uint _app, uint[] _arrObj, uint _price) external {
    require(AppStorage.getDeveloper(_app) == msg.sender);
    AppStorage.setDuration(_app, _arrObj, _price);
  }
  
  function getDeveloper(uint _app) external view returns (address) {
    return AppStorage.getDeveloper(_app);
  }

  // check objects buy
  function getBuyObject(uint _app, address _user, uint _obj) external view returns (bool success) {
    return AppStorage.getBuyObject(_app, _user, _obj);
  }
  
  // check objects buy
  function getTimeSubscription(uint _app, address _user, uint _obj) external view returns (uint _endTime) {
    return AppStorage.getTimeSubscription(_app, _user, _obj);
  }

  function getInfoApp(uint _app) external view returns (uint32, uint32, bool, bool, uint, string) {
    return AppStorage.getInfo(_app);
  }

  function getInfoAppICO(uint _app) external view returns (uint32, bool, string) {
    return AppStorage.getInfoICO(_app);
  }
  
  /**
   * @dev We do not store the data in the contract, but generate the event. This allows you to make feedback as cheap as possible. The event generation costs 8 wei for 1 byte, and data storage in the contract 20,000 wei for 32 bytes
   * @param _app voice application identifier
   * @param vote voter rating
   * @param description voted opinion
   * @param txIndex identifier for the answer
   */
  function feedbackRating(uint _app, uint vote, string description, bytes32 txIndex) external {
    require( vote > 0 && vote <= 10);
    LogStorage.feedbackRatingEvent(msg.sender, _app, vote, description, txIndex, block.timestamp);
  }
}