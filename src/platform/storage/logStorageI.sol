pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Log Storage contract interface 
 */
interface LogStorageI { 
  
  //App events 
  function addAppEvent(uint _app, uint32 _hashType, uint32 _appType, uint _price, bool _publish, address _dev, string _hash) external;
  function setConfirmationAppEvent(uint _app, bool _state, address _moderator, uint32 _hashType, string _hash) external;
  function changeHashAppEvent(uint _app, string _hash, uint32 _hashType) external;
  function changePublishEvent(uint _app, bool _publish) external;
  function setPriceEvent(uint _app, uint _obj, uint _price) external;
  function buyAppEvent(address _user, address _dev, uint _app, uint _obj, address _node, uint _price) external;
  
  //ICO App events   
  function addAppICOEvent(uint _app, string _hash, uint32 _hashType) external;
  function changeHashAppICOEvent(uint _app, string _hash, uint32 _hashType) external;
  
  //Developer events 
  function addDevEvent(address _dev, bytes32 name, bytes32 info) external;
  function changeNameDevEvent(address _dev, bytes32 name, bytes32 info) external;
  function setStoreBlockedDevEvent(address _dev, bool _state) external;
  function setRatingDevEvent(address _dev, int _rating) external;
  
  //Node events  
  function addNodeEvent(address _node, uint32 _hashType, string _hash, string _ip, string _coordinates) external;
  function changeInfoNodeEvent(address _node,  string _hash, uint32 _hashType, string _ip, string _coordinates) external;
  function requestCollectNodeEvent(address _node) external;
  function collectNodeEvent(address _node, uint _amount) external;
  function makeDepositNodeEvent(address _from, address _node, uint _ETH, uint _PMT) external;
  function makeDepositETHNodeEvent(address _from, address _node, uint _value) external;
  function makeDepositPMTNodeEvent(address _from, address _node, uint _value) external;
  function requestRefundNodeEvent(address _node, uint _refundTime) external;
  function refundNodeEvent(address _node) external;
  function setConfirmationNodeEvent(address _node, bool _state, address _moderator) external;
  function setDepositLimitsNodeEvent(address _node, uint _ETH, uint _PMT, address _moderator) external;
  
  //Reviews events
  function feedbackRatingEvent(address voter, uint _app, uint vote, string description, bytes32 txIndex, uint blocktimestamp) external;

  function updateAgentStorage(address _agent, uint32 _store, bool _state) external;
  
  //ICO events  
  function icoCreateEvent(address _dev, uint _app, string _name, string _symbol, uint _decimals, address _crowdsale, string hash, uint32 hashType) external;
  function icoDeleteEvent(address _dev, uint _app, string _name, string _symbol, uint _decimals, address _crowdsale, string _hash, uint32 _hashType) external;
  function icoConfirmationEvent(address _dev, uint _app, bool _state) external;
}