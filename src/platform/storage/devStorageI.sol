pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Developer storage contract interface
 */
interface DevStorageI {

  function addDev(address _dev, bytes32 _name, bytes32 _info) external;  
  function changeName(address _dev, bytes32 _name, bytes32 _info) external;
  // _obj = 0 - application
  // _value: developer revenue
  function buyObject(address _dev) payable external;
    // collect the accumulated amount
  function collect(address _dev) external;

  function updateAgentStorage(address _agent, uint32 _store, bool _state) external;
  /************************************************************************* 
  // Devs getters
  **************************************************************************/
  function getName(address _dev) external view returns (bytes32);
  function getInfo(address _dev) external view returns (bytes32);
  function getState(address _dev) external view returns (bool);
  function getStore(address _dev) external view returns (uint32);
  function getStoreBlocked(address _dev) external view returns (bool);
  function getRating(address _dev) external view returns (int256);
  function getRevenue(address _dev) external view returns (uint256);
  /************************************************************************* 
  // Devs setters
  **************************************************************************/
  function setName(address _dev, bytes32 _name) external;
  function setInfo(address _dev, bytes32 _info) external;  
  function setStore(address _dev, uint32 _store) external;
  function setStoreBlocked(address _dev, bool _state) external;
  function setRating(address _dev, int256 _rating) external;  
}