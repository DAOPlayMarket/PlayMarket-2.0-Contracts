pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Application storage contract interface
 */
interface AppStorageI {
    
  function addApp(string _hash, uint16 _hashType, bool _publish, uint176 _price, address _dev, uint16 _appType, uint32 _store) external returns (uint256);
  function addAppICO(uint _app, string _hash, uint16 _hashType) external;
  function changeHash(uint _app,  string _hash, uint16 _hashType) external;
  function changeHashICO(uint _app, string _hash, uint16 _hashType) external;
  // _obj = 0 - application
  // _state: true - buy, false - cancel buy
  function buyObject(uint _app, address _user, uint _obj, bool _state) external;
  // _obj = 0 - application
  // _state: true - buy, false - cancel buy
  // _price: price if object with ID = _obj
  function buyObject(uint _app, address _user, uint _obj, bool _state, uint176 _price) external;
  // _obj = 0 - application
  // _state: true - buy, false - yet not buyed or cancel buy
  function checkBuy(uint _app, address _user, uint _obj) external view returns (bool _state);
  /************************************************************************* 
  // Apps getters
  **************************************************************************/
  function getHashType(uint _app) external view returns (uint16);
  function getAppType(uint _app) external view returns (uint16);
  // return application price
  function getPrice(uint _app) external view returns (uint176);
  // return price object in application
  function getPrice(uint _app, uint _obj) external view returns (uint176);
  function getPublish(uint _app) external view returns (bool);
  function getConfirmation(uint _app) external view returns (bool);
  function getDeveloper(uint _app) external view returns (address);
  function getHash(uint _app) external view returns (string);
  // AppsICO getters
  function getHashTypeICO(uint _app) external view returns (uint16);
  function getConfirmationICO(uint _app) external view returns (bool);
  function getHashICO(uint _app) external view returns (string);
  /************************************************************************* 
  // Apps setters
  **************************************************************************/
  function setHashType(uint _app, uint16 _hashType) external;
  function setAppType(uint _app, uint16 _appType) external;
  // set application price
  function setPrice(uint _app, uint176 _price) external;
  // set price object in application
  function setPrice(uint _app, uint _obj, uint176 _price) external;
  function setPrice(uint _app, 
    uint _obj01, uint176 _price01, 
    uint _obj02, uint176 _price02) external;
  function setPrice(uint _app, 
    uint _obj01, uint176 _price01, 
    uint _obj02, uint176 _price02, 
    uint _obj03, uint176 _price03) external;
  function setPrice(uint _app, 
    uint _obj01, uint176 _price01, 
    uint _obj02, uint176 _price02, 
    uint _obj03, uint176 _price03, 
    uint _obj04, uint176 _price04) external;
  function setPrice(uint _app, 
    uint _obj01, uint176 _price01, 
    uint _obj02, uint176 _price02, 
    uint _obj03, uint176 _price03, 
    uint _obj04, uint176 _price04, 
    uint _obj05, uint176 _price05) external;
  function setPublish(uint _app, bool _state) external;
  function setConfirmation(uint _app, bool _state) external;
  function setDeveloper(uint _app, address _developer) external;
  function setHash(uint _app, string _hash) external;
  // AppsICO setters
  function setHashTypeICO(uint _app, uint16 _hashType) external;
  function setConfirmationICO(uint _app, bool _state) external;
  function setHashICO(uint _app, string _hash) external;
}