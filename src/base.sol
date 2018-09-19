pragma solidity ^0.4.24;

import './common/Ownable.sol';
import './platform/storage/logStorageI.sol';

contract Base is Ownable {

	LogStorageI public LogStorage;

  event setLogStorageContractEvent(address _contract);

  // link to log storage  
  function setLogStorageContract(address _contract) public onlyOwner {
    LogStorage = LogStorageI(_contract);
    emit setLogStorageContractEvent(_contract);
  }
}