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
  mapping (uint => mapping (uint => uint)) private AppsOBJ; // AppsOBJ[_app][_obj] = price; (in virtual units (PMC))

  // array of purchases users in Application  
  mapping (uint => mapping (address => mapping (uint => bool))) private AppsPurchases; // AppsPurchases[_app][_user][_obj] = true/false;

  function addApp(uint32 _hashType, uint32 _appType, uint32 _store, uint _price, bool _publish, address _dev, string _hash) external onlyAgentStore(_store) returns (uint) {
    Apps.push(_App({
      hashType: _hashType,
      appType: _appType,
      store: _store,      
      publish: _publish,
      confirmation: false,
      developer: _dev,
      hash: _hash     
    }));

    AppsOBJ[Apps.length-1][0] = _price;

    return Apps.length-1;
  }

  function addAppICO(uint _app, string _hash, uint32 _hashType) external onlyAgentStore(Apps[_app].store) {
    AppsICO[_app].hash =_hash;
    AppsICO[_app].hashType = _hashType;
    AppsICO[_app].confirmation = false;
  }

  function changeHash(uint _app, string _hash, uint32 _hashType) external onlyAgentStore(Apps[_app].store) {
    Apps[_app].hash = _hash;
    Apps[_app].hashType = _hashType;
    Apps[_app].confirmation = false;
  }

  function changeHashICO(uint _app, string _hash, uint32 _hashType) external onlyAgentStore(Apps[_app].store) {
    AppsICO[_app].hash =_hash;
    AppsICO[_app].hashType =_hashType;
    AppsICO[_app].confirmation = false;
  }

  // _obj = 0 - application
  // _state: true - buy, false - cancel buy
  function buyObject(uint _app, address _user, uint _obj, bool _state) external onlyAgentStore(Apps[_app].store) {
    AppsPurchases[_app][_user][_obj] = _state;
  }

  // _obj = 0 - application
  // _state: true - buy, false - cancel buy
  function buyObject(uint _app, address _user, uint _obj, bool _state, uint _price) external onlyAgentStore(Apps[_app].store) {
    require(AppsOBJ[_app][_obj] == _price);
    AppsPurchases[_app][_user][_obj] = _state;
  }

  // _obj = 0 - application
  // _state: true - buy, false - yet not buyed or cancel buy
  function checkBuy(uint _app, address _user, uint _obj) external view onlyAgentStore(Apps[_app].store) returns (bool _state) {
    return AppsPurchases[_app][_user][_obj];
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

  // return application price
  function getPrice(uint _app) external view onlyAgentStore(Apps[_app].store) returns (uint) {
    return AppsOBJ[_app][0];
  }

  // return price object in application
  function getPrice(uint _app, uint _obj) external view onlyAgentStore(Apps[_app].store) returns (uint) {
    return AppsOBJ[_app][_obj];
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

  // set application price
  function setPrice(uint _app, uint _price) external onlyAgentStore(Apps[_app].store) {
    AppsOBJ[_app][0] = _price;
  }

  // set price object in application
  function setPrice(uint _app, uint _obj, uint _price) external onlyAgentStore(Apps[_app].store) {
    AppsOBJ[_app][_obj] = _price;
  }

  // set price object in application
  function setPrice(uint _app, 
    uint _obj01, uint _price01, 
    uint _obj02, uint _price02) external onlyAgentStore(Apps[_app].store) {
    AppsOBJ[_app][_obj01] = _price01;
    AppsOBJ[_app][_obj02] = _price02;    
  }  

  // set price object in application
  function setPrice(uint _app, 
    uint _obj01, uint _price01, 
    uint _obj02, uint _price02, 
    uint _obj03, uint _price03) external onlyAgentStore(Apps[_app].store) {
    AppsOBJ[_app][_obj01] = _price01;
    AppsOBJ[_app][_obj02] = _price02;
    AppsOBJ[_app][_obj03] = _price03;    
  }  

  // set price object in application
  function setPrice(uint _app, 
    uint _obj01, uint _price01, 
    uint _obj02, uint _price02, 
    uint _obj03, uint _price03, 
    uint _obj04, uint _price04) external onlyAgentStore(Apps[_app].store) {
    AppsOBJ[_app][_obj01] = _price01;
    AppsOBJ[_app][_obj02] = _price02;
    AppsOBJ[_app][_obj03] = _price03;
    AppsOBJ[_app][_obj04] = _price04;
  }

  // set price object in application
  function setPrice(uint _app, 
    uint _obj01, uint _price01, 
    uint _obj02, uint _price02, 
    uint _obj03, uint _price03, 
    uint _obj04, uint _price04, 
    uint _obj05, uint _price05) external onlyAgentStore(Apps[_app].store) {
    AppsOBJ[_app][_obj01] = _price01;
    AppsOBJ[_app][_obj02] = _price02;
    AppsOBJ[_app][_obj03] = _price03;
    AppsOBJ[_app][_obj04] = _price04;
    AppsOBJ[_app][_obj05] = _price05;
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