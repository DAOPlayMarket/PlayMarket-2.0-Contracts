pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Log Storage contract interface 
 */
interface LogStorageI { 
  
  //App events 
  function addAppEvent(uint _app, uint32 _hashType, uint32 _appType, uint _price, bool _publish, address _dev, string _hash) external;
  function setConfirmationAppEvent(uint _app, bool _state, address _moderator) external;
  function changeHashEvent(uint _app, string _hash, uint32 _hashType) external;
  function changePublishEvent(uint _app, bool _publish) external;
  function changePriceEvent(uint _app, uint _price) external;
  function buyAppEvent(address _user, address _dev, uint _app, address _node, uint _price) external;
  
  //ICO App events 
  function addAppICOEvent(uint _app, string hash, uint32 hashType) external;
  function changeHashICOEvent(uint _app, string hash, uint32 hashType) external;
  
  //Developer events 
  function addDevEvent(address _dev, bytes32 name, bytes32 info) external;
  function changeNameDevEvent(address _dev, bytes32 name, bytes32 info) external;
  function setStoreBlockedDevEvent(address _dev, bool _state) external;
  
  //Node events  
  function addNodeEvent(address _node, uint32 _hashType, bytes24 _reserv, string _hash, string _ip, string _coordinates) external;
  function confirmationNodeEvent(address _node, bool value) external;
  function changeInfoNodeEvent(address _node,  string _hash, uint32 _hashType, string _ip, string _coordinates) external;
  
  //Reviews events
  function feedbackRatingEvent(address voter, uint _app, uint vote, string description, bytes32 txIndex, uint blocktimestamp) external;


  //ICO events  
  //function releaseICOEvent(address adrDev, uint _app, bool release, address ICO) external;
  //function newContractEvent(string name, string symbol, address adrDev, uint _app) external;
}