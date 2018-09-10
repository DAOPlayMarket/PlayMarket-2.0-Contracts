pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Logs contract interface 
 */
interface LogsI { 
  
  //App events 
  function registrationApplicationEvent_(uint idApp, string hash, string hashTag, bool publish, uint256 price, address adrDev) external;
  function confirmationApplicationEvent_(uint idApp, bool _status, address _moderator) external;
  function changeHashEvent_(uint idApp, string hash, string hashTag) external;
  function changePublishEvent_(uint idApp, bool publish) external;
  function changePriceEvent_(uint idApp, uint256 price) external;
  function buyAppEvent_(address user, address developer, uint idApp, address adrNode, uint256 price) external;
  
  //Developer events 
  function registrationDeveloperEvent_(address developer, bytes32 name, bytes32 info) external;
  function changeDeveloperInfoEvent_(address developer, bytes32 name, bytes32 info) external;
  function confirmationDeveloperEvent_(address developer, bool value) external;
  
  //Node events
  function registrationNodeEvent_(address adrNode, bool confirmation, string hash, string hashTag, uint256 deposit, string ip, string coordinates) external;
  function confirmationNodeEvent_(address adrNode, bool value) external;
  function makeDepositEvent_(address adrNode, uint256 deposit) external;
  function takeDepositEvent_(address adrNode, uint256 deposit) external;
  function changeInfoNodeEvent_(address adrNode, string hash, string hashTag, string ip, string coordinates) external;
  
  
  //Reviews events
  function newRating_(address voter , uint idApp, uint vote, string description, bytes32 txIndex, uint256 blocktimestamp) external;

  //ICO App events 
  function registrationApplicationICOEvent_(uint idApp, string hash, string hashTag) external;
  function changeIcoHashEvent_(uint idApp, string hash, string hashTag) external;  
  
  //ICO events  
  function releaseICOEvent_(address adrDev, uint idApp, bool release, address ICO) external;
  function newContractEvent_(string name, string symbol, address adrDev, uint idApp) external;
}