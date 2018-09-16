pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Application storage contract interface
 */
interface AppStorageI {
  
  function addApp(uint32 _hashType, uint32 _appType, uint32 _store, uint _price, bool _publish, address _dev, string _hash) external returns (uint);
  function addAppICO(uint _app, string _hash, uint32 _hashType) external;
  function changeHash(uint _app,  string _hash, uint32 _hashType) external;
  function changeHashICO(uint _app, string _hash, uint32 _hashType) external;
  // _obj = 0 - application
  // _state: true - buy, false - cancel buy
  function buyObject(uint _app, address _user, uint _obj, bool _state) external;
  // _obj = 0 - application
  // _state: true - buy, false - cancel buy
  // _price: price if object with ID = _obj
  function buyObject(uint _app, address _user, uint _obj, bool _state, uint _price) external;
  // _obj = 0 - application
  // _state: true - buy, false - yet not buyed or cancel buy
  function checkBuy(uint _app, address _user, uint _obj) external view returns (bool _state);
  /************************************************************************* 
  // Apps getters
  **************************************************************************/
  function getHashType(uint _app) external view returns (uint32);
  function getAppType(uint _app) external view returns (uint32);
  // return application price
  function getPrice(uint _app) external view returns (uint);
  // return price object in application
  function getPrice(uint _app, uint _obj) external view returns (uint);
  function getPublish(uint _app) external view returns (bool);
  function getConfirmation(uint _app) external view returns (bool);
  function getDeveloper(uint _app) external view returns (address);
  function getHash(uint _app) external view returns (string);
  // AppsICO getters
  function getHashTypeICO(uint _app) external view returns (uint32);
  function getConfirmationICO(uint _app) external view returns (bool);
  function getHashICO(uint _app) external view returns (string);
  /************************************************************************* 
  // Apps setters
  **************************************************************************/
  function setHashType(uint _app, uint32 _hashType) external;
  function setAppType(uint _app, uint32 _appType) external;
  // set application price
  function setPrice(uint _app, uint _price) external;
  // set price object in application
  function setPrice(uint _app, uint _obj, uint _price) external;
  function setPrice(uint _app, 
    uint _obj01, uint _price01, 
    uint _obj02, uint _price02) external;
  function setPrice(uint _app, 
    uint _obj01, uint _price01, 
    uint _obj02, uint _price02, 
    uint _obj03, uint _price03) external;
  function setPrice(uint _app, 
    uint _obj01, uint _price01, 
    uint _obj02, uint _price02, 
    uint _obj03, uint _price03, 
    uint _obj04, uint _price04) external;
  function setPrice(uint _app, 
    uint _obj01, uint _price01, 
    uint _obj02, uint _price02, 
    uint _obj03, uint _price03, 
    uint _obj04, uint _price04, 
    uint _obj05, uint _price05) external;
  function setPublish(uint _app, bool _state) external;
  function setConfirmation(uint _app, bool _state) external;
  function setDeveloper(uint _app, address _developer) external;
  function setHash(uint _app, string _hash) external;
  // AppsICO setters
  function setHashTypeICO(uint _app, uint32 _hashType) external;
  function setConfirmationICO(uint _app, bool _state) external;
  function setHashICO(uint _app, string _hash) external;
}