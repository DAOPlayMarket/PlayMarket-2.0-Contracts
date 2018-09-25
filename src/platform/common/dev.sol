pragma solidity ^0.4.24;

import '../../Base.sol';
import '../../common/Agent.sol';
import '../../common/SafeMath.sol';
import '../storage/devStorageI.sol';
import '../storage/logStorageI.sol';

/**
 * @title Developer contract - basic contract for working with developers
 */
contract Dev is Agent, SafeMath, Base {
  
  int public defRating = 0;

  DevStorageI public DevStorage;

  event setDevStorageContractEvent(address _contract);

  // link to dev storage
  function setDevStorageContract(address _contract) public onlyOwner {
    DevStorage = DevStorageI(_contract);
    emit setDevStorageContractEvent(_contract);
  }
  
  function addDev(bytes32 _name, bytes32 _info, bytes27 _reserv) public {
    require(!DevStorage.getState(msg.sender));
    DevStorage.addDev(msg.sender, _name, _info, _reserv);
    DevStorage.setRating(msg.sender, defRating);
    LogStorage.addDevEvent(msg.sender, _name, _info);
  }
	
  function changeNameDev(bytes32 _name, bytes32 _info) public {
    require(DevStorage.getState(msg.sender));
    DevStorage.changeName(msg.sender,_name, _info);
    LogStorage.changeNameDevEvent(msg.sender, _name, _info);
  }
  
  // collect the accumulated amount
  function collectDev() external {
    require(DevStorage.getRevenue(msg.sender) > 0);
    DevStorage.collect(msg.sender);
  }

  function setStoreBlockedDev(address _dev, bool _state) external onlyAgent {
    require(DevStorage.getState(_dev));
    DevStorage.setStoreBlocked(_dev, _state);
    LogStorage.setStoreBlockedDevEvent(_dev, _state);
  }

  function setRatingDev(address _dev, int _rating) external onlyAgent {
    require(DevStorage.getState(_dev));
    DevStorage.setRating(_dev, _rating);
    LogStorage.setRatingDevEvent(_dev, _rating);
  }

  /************************************************************************* 
  // Devs getters
  **************************************************************************/
  function getNameDev() external view returns (bytes32) {
    return DevStorage.getName(msg.sender);
  }

  function getInfoDev() external view returns (bytes32) {
    return DevStorage.getInfo(msg.sender);
  }

  function getStateDev() external view returns (bool) {
    return DevStorage.getState(msg.sender);
  }

  function getReservDev() external view returns (bytes27) {
    return DevStorage.getReserv(msg.sender);
  }

  function getStoreBlockedDev() external view returns (bool) {
    return DevStorage.getStoreBlocked(msg.sender);
  }
  
  function getRatingDev() external view returns (int256) {
    return DevStorage.getRating(msg.sender);
  }

  function getRevenueDev() external view returns (uint256) {
    return DevStorage.getRevenue(msg.sender);
  }  

  /************************************************************************* 
  // default params setters (onlyOwner => DAO)
  **************************************************************************/ 

  function changeDefRating(int _defRating) public onlyOwner {
    defRating = _defRating;
  }
}