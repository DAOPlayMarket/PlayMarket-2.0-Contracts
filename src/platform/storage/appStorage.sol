pragma solidity ^0.4.24;

import '../../common/AgentStorage.sol';
import './appStorageI.sol';

/**
 * @title Application Storage contract - contains info about Apps
 */
contract AppStorage is AppStorageI, AgentStorage {
	
  struct _App {
    uint32  hashType;   // default 0 - IPFS
    uint32  appType;    // default 0 - android application
    uint32  store;      // default 1    
    bool publish;       // the developer decides whether to publish or not
    bool confirmation;  // decides platform, after verification (Nodes and mobile application display only approved and published Apps)
    address developer;  // link to developer
    string hash;        // hash of content in storage system
  }

  struct _AppICO {    
    uint32 hashType;    // default 0 - IPFS
    bool confirmation;  // decides platform, after verification (Nodes and mobile application display only approved and published Apps)
    string hash;        // hash of content in storage system
  }

  // array of Applications
  _App[] private Apps;

  // array of Application ICO's
  mapping (uint => _AppICO) private AppsICO;

  // array of Applications Objects
  mapping (uint => mapping (uint => uint)) private AppsOBJprice; // AppsOBJ[_app][_obj] = price; (in virtual units (PMC))
  mapping (uint => mapping (uint => uint)) private AppsOBJduration;
  // array of purchases users in Application  
  mapping (uint => mapping (address => mapping (uint => bool))) private AppsPurchases; // AppsPurchases[_app][_user][_obj] = true/false;
  mapping (uint => mapping (address => mapping (uint => uint))) private AppsSubscriptions; // AppsSubscription[_app][_user][_obj] = end time subscription;

  function addApp(uint32 _hashType, uint32 _appType, uint _price, bool _publish, address _dev, string _hash) external onlyAgentStorage() returns (uint) {
    Apps.push(_App({
      hashType: _hashType,
      appType: _appType,
      store: Agents[msg.sender].store,      
      publish: _publish,
      confirmation: false,
      developer: _dev,
      hash: _hash     
    }));

    AppsOBJprice[Apps.length-1][0] = _price;
    return Apps.length-1;
  }

  function addAppICO(uint _app, string _hash, uint32 _hashType) external onlyAgentStore(Apps[_app].store) {
    assert(Apps[_app].developer != address(0));
    AppsICO[_app].hash =_hash;
    AppsICO[_app].hashType = _hashType;
    AppsICO[_app].confirmation = false;
  }

  function changeHashApp(uint _app, string _hash, uint32 _hashType) external onlyAgentStore(Apps[_app].store) {
    assert(Apps[_app].developer != address(0));
    Apps[_app].hash = _hash;
    Apps[_app].hashType = _hashType;
    Apps[_app].confirmation = false;
  }

  function changeHashAppICO(uint _app, string _hash, uint32 _hashType) external onlyAgentStore(Apps[_app].store) {
    assert(Apps[_app].developer != address(0));
    AppsICO[_app].hash =_hash;
    AppsICO[_app].hashType =_hashType;
    AppsICO[_app].confirmation = false;
  }

  // _obj = 0 - application
  // _state: true - buy, false - cancel buy
  function buyObject(uint _app, address _user, uint _obj, bool _state) external onlyAgentStore(Apps[_app].store) {
    AppsPurchases[_app][_user][_obj] = _state;
  }

  function buySubscription(uint _app, address _user, uint _obj, uint _endTime) external onlyAgentStore(Apps[_app].store) {
    AppsSubscriptions[_app][_user][_obj] = _endTime;
  }
  // _obj = 0 - application
  // _state: true - buy, false - cancel buy
  function buyObject(uint _app, address _user, uint _obj, bool _state, uint _price) external onlyAgentStore(Apps[_app].store) {
    require(AppsOBJprice[_app][_obj] == _price);
    AppsPurchases[_app][_user][_obj] = _state;
  }

  function buySubscription(uint _app, address _user, uint _obj, uint _endTime, uint _price) external onlyAgentStore(Apps[_app].store) {
    require(AppsOBJprice[_app][_obj] == _price);
    AppsSubscriptions[_app][_user][_obj] = _endTime;
  }
  
  // _obj = 0 - application
  // _state: true - buy, false - yet not buyed or cancel buy
  function getBuyObject(uint _app, address _user, uint _obj) external view onlyAgentStore(Apps[_app].store) returns (bool _state) {
    return AppsPurchases[_app][_user][_obj];
  }

  function getTimeSubscription(uint _app, address _user, uint _obj) external view onlyAgentStore(Apps[_app].store) returns (uint _endTime) {
    return AppsSubscriptions[_app][_user][_obj];
  }
  /************************************************************************* 
  // Apps getters
  **************************************************************************/
  function getHashType(uint _app) external view onlyAgentStore(Apps[_app].store) returns (uint32) {
    return Apps[_app].hashType;
  }

  function getAppType(uint _app) external view onlyAgentStore(Apps[_app].store) returns (uint32) {
    return Apps[_app].appType;
  }

  // return price object
  function getPrice(uint _app, uint _obj) external view onlyAgentStore(Apps[_app].store) returns (uint) {
    return AppsOBJprice[_app][_obj];
  }

  // return price object
  function getDuration(uint _app, uint _obj) external view onlyAgentStore(Apps[_app].store) returns (uint) {
    return AppsOBJduration[_app][_obj];
  }
  
  function getPublish(uint _app) external view onlyAgentStore(Apps[_app].store) returns (bool) {
    return Apps[_app].publish;
  }

  function getConfirmation(uint _app) external view onlyAgentStore(Apps[_app].store) returns (bool) {
    return Apps[_app].confirmation;
  }

  function getDeveloper(uint _app) external view onlyAgentStore(Apps[_app].store) returns (address) {
    return Apps[_app].developer;
  }

  function getHash(uint _app) external view onlyAgentStore(Apps[_app].store) returns (string) {
    return Apps[_app].hash;
  }

  // AppsICO getters
  function getHashTypeICO(uint _app) external view onlyAgentStore(Apps[_app].store) returns (uint32) {
    return AppsICO[_app].hashType;
  }

  function getConfirmationICO(uint _app) external view onlyAgentStore(Apps[_app].store) returns (bool) {
    return AppsICO[_app].confirmation;
  }

  function getHashICO(uint _app) external view onlyAgentStore(Apps[_app].store) returns (string) {
    return AppsICO[_app].hash;
  }

  /************************************************************************* 
  // Apps setters
  **************************************************************************/
  function setHashType(uint _app, uint32 _hashType) external onlyAgentStore(Apps[_app].store) {
    Apps[_app].hashType = _hashType;
  }

  function setAppType(uint _app, uint32 _appType) external onlyAgentStore(Apps[_app].store) {
    Apps[_app].appType = _appType;
  }

  // set price 
  function setPrice(uint _app, uint _obj, uint _price) external onlyAgentStore(Apps[_app].store) {
    AppsOBJprice[_app][_obj] = _price;
  }
  
  function setPrice(uint _app, uint[] _arrObj, uint[] _arrPrice) external onlyAgentStore(Apps[_app].store) {
    require(_arrObj.length == _arrPrice.length);
    for(uint i =0; i < _arrObj.length; i++){
      if(_arrObj[i]!=0)
        AppsOBJprice[_app][_arrObj[i]] = _arrPrice[i];
    }
  }  

  function setPrice(uint _app, uint[] _arrObj, uint _price) external onlyAgentStore(Apps[_app].store) {
    for(uint i =0; i < _arrObj.length; i++){
      if(_arrObj[i]!=0)
        AppsOBJprice[_app][_arrObj[i]] = _price;
    }
  } 
  
  function setDuration(uint _app, uint _obj, uint _duration) external onlyAgentStore(Apps[_app].store) {
   AppsOBJduration[_app][_obj] = _duration;
  }  
  
  function setDuration(uint _app, uint[] _arrObj, uint[] _arrDuration) external onlyAgentStore(Apps[_app].store) {
    require(_arrObj.length == _arrDuration.length);
    for(uint i =0; i < _arrObj.length; i++){
      AppsOBJduration[_app][_arrObj[i]] = _arrDuration[i];
    }
  }  
  
  function setDuration(uint _app, uint[] _arrObj, uint _duration) external onlyAgentStore(Apps[_app].store) {
    for(uint i =0; i < _arrObj.length; i++){
      AppsOBJduration[_app][_arrObj[i]] = _duration;
    }
  }  
  
  function setPublish(uint _app, bool _state) external onlyAgentStore(Apps[_app].store) {
    Apps[_app].publish = _state;
  }

  function setConfirmation(uint _app, bool _state) external onlyAgentStore(Apps[_app].store) {
    Apps[_app].confirmation = _state;
  }

  function setDeveloper(uint _app, address _developer) external onlyAgentStore(Apps[_app].store) {
    Apps[_app].developer = _developer;
  }

  function setHash(uint _app, string _hash) external onlyAgentStore(Apps[_app].store) {
    Apps[_app].hash = _hash;
  }

  // AppsICO setters
  function setHashTypeICO(uint _app, uint32 _hashType) external onlyAgentStore(Apps[_app].store) {
    AppsICO[_app].hashType = _hashType;
  }

  function setConfirmationICO(uint _app, bool _state) external onlyAgentStore(Apps[_app].store) {
    AppsICO[_app].confirmation = _state;
  }

  function setHashICO(uint _app, string _hash) external onlyAgentStore(Apps[_app].store) {
    AppsICO[_app].hash = _hash;
  }    
}