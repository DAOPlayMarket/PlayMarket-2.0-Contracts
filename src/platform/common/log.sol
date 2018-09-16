pragma solidity ^0.4.24;

import '../../common/Agent.sol';
import '../storage/logStorageI.sol';

/**
 * @title Logs contract - basic contract for working with logs (only events)
 */
contract Log is Agent {

  LogStorageI public LogStorage;

  event setLogStorageContractEvent(address _contract);

  // link to log storage  
  function setLogStorageContract(address _contract) public onlyOwner {
    LogStorage = LogStorageI(_contract);
    emit setLogStorageContractEvent(_contract);
  }
 
  function releaseICOEvent_(address adrDev, uint _app, bool release, address ICO) public onlyAgent {
    //emit releaseICOEvent(adrDev, _app, release, ICO);
  }
  
  function newContractEvent_(string name, string symbol, address adrDev, uint _app) external onlyAgent {
    //emit newContractEvent(name, symbol, adrDev, _app);
  }
}