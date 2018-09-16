pragma solidity ^0.4.24;

import '../../common/Agent.sol';
import '../../common/SafeMath.sol';
import '../storage/devStorageI.sol';
import '../storage/logStorageI.sol';

/**
 * @title Developer contract - basic contract for working with developers
 */
contract Dev is Agent, SafeMath {
  
  bool autoConfirm = true;
  int defRating = 0;

  DevStorageI public DevStorage;
  LogStorageI public LogStorage;

  event setDevStorageContractEvent(address _contract);

  // link to dev storage
  function setDevStorageContract(address _contract) public onlyOwner {
    DevStorage = DevStorageI(_contract);
    emit setDevStorageContractEvent(_contract);
  }
  
  // link to log storage
  function setDevLogStorageContract(address _contract) public onlyOwner {
    LogStorage = LogStorageI(_contract);    
  }  

  function addDev(bytes32 _name, bytes32 _info, bytes26 _reserv) public {
    require(!DevStorage.getState(msg.sender));
    DevStorage.addDev(msg.sender, _name, _info, autoConfirm, _reserv);
    DevStorage.setRating(msg.sender, defRating);
    LogStorage.addDevEvent(msg.sender, _name, _info);
  }
	
  function changeNameDev(bytes32 _name, bytes32 _info) public {
    require(!DevStorage.getState(msg.sender));
    DevStorage.changeName(msg.sender,_name, _info);
    LogStorage.changeNameDevEvent(msg.sender, _name, _info);
  }
  
  // collect the accumulated amount
  function collectDev() external {
    require(DevStorage.getRevenue(msg.sender) > 0);
    DevStorage.collect(msg.sender);
  }

  function setConfirmationDev(address _dev, bool _state) external onlyAgent {
    require(!DevStorage.getState(_dev));
    DevStorage.setConfirmation(_dev, _state);
    LogStorage.setConfirmationDevEvent(_dev, _state);
  }

  function changeRatingDev(address _dev, int _rating) public onlyAgent {
    require(!DevStorage.getState(_dev));
    DevStorage.setRating(_dev, _rating);
    if (_rating < 0) DevStorage.setConfirmation(msg.sender, false);
  }

  /************************************************************************* 
  // default params setters (onlyOwner => DAO)
  **************************************************************************/ 
  function changeAutoConfirm(bool _autoConfirm) public onlyOwner {
    autoConfirm = _autoConfirm;
  }
  
  function changeDefRating(int _defRating) public onlyOwner {
    defRating = _defRating;
  }
}