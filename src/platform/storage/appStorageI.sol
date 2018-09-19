pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Application storage contract interface
 */
interface AppStorageI {
  
  function addApp(uint32 _hashType, uint32 _appType, uint _price, bool _publish, address _dev, string _hash) external returns (uint);
  function addAppICO(uint _app, string _hash, uint32 _hashType) external;
  function changeHashApp(uint _app,  string _hash, uint32 _hashType) external;
  function changeHashAppICO(uint _app, string _hash, uint32 _hashType) external;
  // _obj = 0 - application
  // _state: true - buy, false - cancel buy
  function buyObject(uint _app, address _user, uint _obj, bool _state) external;
  // _obj = 0 - application
  // _state: true - buy, false - cancel buy
  // _price: price if object with ID = _obj
  function buyObject(uint _app, address _user, uint _obj, bool _state, uint _price) external;
  function buySubscription(uint _app, address _user, uint _obj, uint _endTime) external;
  function buySubscription(uint _app, address _user, uint _obj, uint _endTime, uint _price) external;
  // _obj = 0 - application
  // _state: true - buy, false - yet not buyed or cancel buy
  function getBuyObject(uint _app, address _user, uint _obj) external view returns (bool _state);
  function getTimeSubscription(uint _app, address _user, uint _obj) external view  returns (uint _endTime);
  /************************************************************************* 
  // Apps getters
  **************************************************************************/
  function getHashType(uint _app) external view returns (uint32);
  function getAppType(uint _app) external view returns (uint32);
  // return price object 
  function getPrice(uint _app, uint _obj) external view returns (uint);
  function getDuration(uint _app, uint _obj) external view returns (uint);
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
  function setPrice(uint _app, uint _obj, uint _price) external;
  function setPrice(uint _app, uint[] _arrObj, uint[] _arrPrice) external;
  function setPrice(uint _app, uint[] _arrObj, uint _price) external;
  
  // set subscription duration 
  function setDuration(uint _app, uint _obj, uint _duration) external;
  function setDuration(uint _app, uint[] _arrObj, uint[] _arrDuration) external;
  function setDuration(uint _app, uint[] _arrObj, uint _duration) external;
  
  function setPublish(uint _app, bool _state) external;
  function setConfirmation(uint _app, bool _state) external;
  function setDeveloper(uint _app, address _developer) external;
  function setHash(uint _app, string _hash) external;
  // AppsICO setters
  function setHashTypeICO(uint _app, uint32 _hashType) external;
  function setConfirmationICO(uint _app, bool _state) external;
  function setHashICO(uint _app, string _hash) external;
}