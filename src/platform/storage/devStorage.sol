pragma solidity ^0.4.24;

import '../../common/SafeMath.sol';
import '../../common/AgentStorage.sol';
import './devStorageI.sol';

/**
 * @title Developer Storage contract - contains info about Devs
 */
contract DevStorage is DevStorageI, AgentStorage, SafeMath {

  struct _Dev {    
    bytes32 name;      // developer name
    bytes32 info;      // developer info
    bool state;        // service variable to determine the state of the structure
    uint32 store;      // default 1
    bytes27 reserv;
  }

  mapping (address => _Dev) private Devs;
  mapping(uint32 => mapping(address => bool)) private DevsStoreBlocked;
  mapping (uint32 => mapping (address => int256)) private DevsRating;
  mapping (address => uint256) private DevsRevenue;
  
  modifier CheckBlock(address _dev) {
    assert(!DevsStoreBlocked[Agents[msg.sender].store][_dev]);
    _;
  }
  
  function addDev(address _dev, bytes32 _name, bytes32 _info, bytes27 _reserv, uint32 _store) external onlyAgentStore(_store) {
    require(!Devs[_dev].state);
    Devs[_dev]=_Dev({
      name: _name,
      info: _info,
      state: true,
      store: _store,
      reserv: _reserv
    });
  }

  function changeName(address _dev, bytes32 _name, bytes32 _info) external onlyAgentDev() CheckBlock(_dev) {
    require(Devs[_dev].state);
    Devs[_dev].name = _name;
    Devs[_dev].info = _info;
  }

  function buyObject(address _dev) payable external onlyAgentDev() CheckBlock(_dev){
    require(Devs[_dev].state);
    require(msg.value > 0);
    DevsRevenue[_dev] = safeAdd(DevsRevenue[_dev], msg.value);
  }

  // collect the accumulated amount
  function collect(address _dev) external onlyAgentDev() CheckBlock(_dev){
    require(Devs[_dev].state);
    uint256 amount = DevsRevenue[_dev];
    require(amount > 0);
    DevsRevenue[_dev] = 0;
    _dev.transfer(amount);
  }

  /************************************************************************* 
  // Devs getters
  **************************************************************************/
  function getName(address _dev) external view onlyAgentDev() returns (bytes32) {
    return Devs[_dev].name;
  }

  function getInfo(address _dev) external view onlyAgentDev() returns (bytes32) {
    return Devs[_dev].info;
  }

  function getState(address _dev) external view onlyAgentDev() returns (bool) {
    return Devs[_dev].state;
  }

  function getStore(address _dev) external view onlyAgentDev() returns (uint32) {
    return Devs[_dev].store;
  }
  
  function getReserv(address _dev) external view onlyAgentDev() returns (bytes27) {
    return Devs[_dev].reserv;
  }

  function getStoreBlocked(address _dev) external view onlyAgentDev() returns (bool) {
    return DevsStoreBlocked[Agents[msg.sender].store][_dev];
  }
  
  function getRating(address _dev) external view onlyAgentDev() returns (int256) {
    return DevsRating[Agents[msg.sender].store][_dev];
  }

  function getRevenue(address _dev) external view onlyAgentDev() returns (uint256) {
    return DevsRevenue[_dev];
  }

  /************************************************************************* 
  // Devs setters
  **************************************************************************/
  function setName(address _dev, bytes32 _name) external onlyAgentDev() {
    //require(Devs[_dev].state);
    Devs[_dev].name = _name;
  }

  function setInfo(address _dev, bytes32 _info) external onlyAgentDev() {
    //require(Devs[_dev].state);
    Devs[_dev].info = _info;
  }

  function setStore(address _dev, uint32 _store) external onlyOwner {
    //require(Devs[_dev].state);
    Devs[_dev].store = _store;
  }

  function setReserv(address _dev, bytes27 _reserv) external onlyAgentDev() {
   //require(Devs[_dev].state);
    Devs[_dev].reserv = _reserv;
  }
  
  function setStoreBlocked(address _dev, bool _state) external onlyAgentDev() {
    //require(Devs[_dev].state);
    DevsStoreBlocked[Agents[msg.sender].store][_dev] = _state;
  }

  function setRating(address _dev, int _rating) external onlyAgentDev() {
    //require(Devs[_dev].state);
    DevsRating[Agents[msg.sender].store][_dev] = _rating;
  }
}