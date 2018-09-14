pragma solidity ^0.4.24;

import '/src/common/Agent.sol';
import '/src/platform/common/logsI.sol';

/**
 * @title Logs contract - basic contract for working with logs (only events)
 */
contract Logs is LogsI, Agent {
  
  //App events 
  event registrationApplicationEvent(uint _app, string hash, string hashTag, bool publish, uint256 price, address adrDev);
  event confirmationApplicationEvent(uint _app, bool _status, address _moderator);
  event changeHashEvent(uint _app, string hash, string hashTag);
  event changePublishEvent(uint _app, bool publish);
  event changePriceEvent(uint _app, uint256 price);
  event buyAppEvent(address indexed user, address indexed developer, uint _app, address indexed adrNode, uint256 price);
  
  //Ico App events 
  event registrationApplicationICOEvent(uint _app, string hash, string hashTag);
  event changeIcoHashEvent(uint _app, string hash, string hashTag);
  
  //Developer events 
  event registrationDeveloperEvent(address indexed developer, bytes32 name, bytes32 info);
  event changeDeveloperInfoEvent(address indexed developer, bytes32 name, bytes32 info);
  event confirmationDeveloperEvent(address indexed developer, bool value);
  
  //Node events
  event registrationNodeEvent(address indexed adrNode, bool confirmation, string hash, string hashTag, uint256 deposit, string ip, string coordinates);
  event confirmationNodeEvent(address adrNode, bool value);
  event makeDepositEvent(address indexed adrNode, uint256 deposit);
  event takeDepositEvent(address indexed adrNode, uint256 deposit);
  event changeInfoNodeEvent(address adrNode, string hash, string hashTag, string ip, string coordinates);
  
  //Reviews events
  event newRating(address voter , uint _app, uint vote, string description, bytes32 txIndex, uint256 blocktimestamp);
  
  //ICO events 
  event releaseICOEvent(address adrDev, uint _app, bool release, address ICO);
  event newContractEvent(string name, string symbol, address adrDev, uint _app);
  
  function registrationApplicationEvent_(uint _app, string hash, string hashTag, bool publish, uint256 price, address adrDev) external onlyAgent {
    emit registrationApplicationEvent(_app, hash, hashTag, publish, price, adrDev);
  }

  function confirmationApplicationEvent_(uint _app, bool _status, address _moderator) public onlyAgent {
    emit confirmationApplicationEvent(_app, _status, _moderator);
  }
  
  function changeHashEvent_(uint _app, string hash, string hashTag) external onlyAgent {
    emit changeHashEvent(_app, hash, hashTag);
  }
  
  function changePublishEvent_(uint _app, bool publish) public onlyAgent {
    emit changePublishEvent(_app, publish);
  }
  
  function changePriceEvent_(uint _app, uint256 price) public onlyAgent {
    emit changePriceEvent(_app, price);
  }
  
  function buyAppEvent_(address user, address developer, uint _app, address adrNode, uint256 price) public onlyAgent {
    emit buyAppEvent(user, developer, _app, adrNode, price);
  }
  
  function registrationApplicationICOEvent_(uint _app, string hash, string hashTag) external onlyAgent {
    emit registrationApplicationICOEvent(_app, hash, hashTag);
  }
  
  function changeIcoHashEvent_(uint _app, string hash, string hashTag) external onlyAgent {
    emit changeIcoHashEvent(_app, hash, hashTag);
  }
  
  function registrationDeveloperEvent_(address developer, bytes32 name, bytes32 info) external onlyAgent {
    emit registrationDeveloperEvent(developer, name, info);
  }
  
  function changeDeveloperInfoEvent_(address developer, bytes32 name, bytes32 info) external onlyAgent {
    emit changeDeveloperInfoEvent(developer, name, info);
  }
  
  function confirmationDeveloperEvent_(address developer, bool value) public onlyAgent {
    emit confirmationDeveloperEvent(developer, value);
  }
  
  function registrationNodeEvent_(address adrNode, bool confirmation, string hash, string hashTag, uint256 deposit, string ip, string coordinates) external onlyAgent {
    emit registrationNodeEvent(adrNode, confirmation, hash, hashTag, deposit, ip, coordinates);
  }
  
  function confirmationNodeEvent_(address adrNode, bool value) public onlyAgent {
    emit confirmationNodeEvent(adrNode, value);
  }
  
  function makeDepositEvent_(address adrNode, uint256 deposit) public onlyAgent {
    emit makeDepositEvent(adrNode, deposit);
  }
  
  function takeDepositEvent_(address adrNode, uint256 deposit) public onlyAgent {
    emit takeDepositEvent(adrNode, deposit);
  }
  
  function changeInfoNodeEvent_(address adrNode, string hash, string hashTag, string ip, string coordinates) external onlyAgent {
    emit changeInfoNodeEvent(adrNode, hash, hashTag, ip, coordinates);
  }
  
  function newRating_(address voter , uint _app, uint vote, string description, bytes32 txIndex, uint256 blocktimestamp) external onlyAgent {
    emit newRating(voter , _app, vote, description, txIndex, blocktimestamp);
  }
  
  function releaseICOEvent_(address adrDev, uint _app, bool release, address ICO) public onlyAgent {
    emit releaseICOEvent(adrDev, _app, release, ICO);
  }
  
  function newContractEvent_(string name, string symbol, address adrDev, uint _app) external onlyAgent {
    emit newContractEvent(name, symbol, adrDev, _app);
  }
}