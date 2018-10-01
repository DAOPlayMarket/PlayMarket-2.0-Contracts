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
    bytes32 desc;      // developer description
    bool state;        // service variable to determine the state of the structure
    uint32 store;      // default 1    
  }

  mapping (address => _Dev) private Devs;
  mapping (uint32 => mapping(address => bool)) private DevsStoreBlocked;
  mapping (uint32 => mapping (address => int256)) private DevsRating;
  mapping (address => uint256) private DevsRevenue;
  
  modifier CheckBlock(address _dev) {
    assert(!DevsStoreBlocked[Agents[msg.sender].store][_dev]);
    _;
  }
  
  function addDev(address _dev, bytes32 _name, bytes32 _desc) external onlyAgentStorage() {
    assert(!Devs[_dev].state);
    Devs[_dev]=_Dev({
      name: _name,
      desc: _desc,
      state: true,
      store: Agents[msg.sender].store      
    });
  }

  function changeName(address _dev, bytes32 _name, bytes32 _desc) external onlyAgentStorage() CheckBlock(_dev) {
    assert(Devs[_dev].state);
    Devs[_dev].name = _name;
    Devs[_dev].desc = _desc;
  }

  function buyObject(address _dev) payable external onlyAgentStorage() CheckBlock(_dev){
    assert(Devs[_dev].state);
    assert(msg.value > 0);
    DevsRevenue[_dev] = safeAdd(DevsRevenue[_dev], msg.value);
  }

  // collect the accumulated amount
  function collect(address _dev) external onlyAgentStorage() CheckBlock(_dev){
    assert(Devs[_dev].state);
    uint256 amount = DevsRevenue[_dev];
    assert(amount > 0);
    DevsRevenue[_dev] = 0;
    _dev.transfer(amount);
  }

  /************************************************************************* 
  // Devs getters
  **************************************************************************/
  function getName(address _dev) external view onlyAgentStorage() returns (bytes32) {
    return Devs[_dev].name;
  }

  function getDesc(address _dev) external view onlyAgentStorage() returns (bytes32) {
    return Devs[_dev].desc;
  }

  function getState(address _dev) external view onlyAgentStorage() returns (bool) {
    return Devs[_dev].state;
  }

  function getStore(address _dev) external view onlyAgentStorage() returns (uint32) {
    return Devs[_dev].store;
  }
  
  function getStoreBlocked(address _dev) external view onlyAgentStorage() returns (bool) {
    return DevsStoreBlocked[Agents[msg.sender].store][_dev];
  }
  
  function getRating(address _dev) external view onlyAgentStorage() returns (int256) {
    return DevsRating[Agents[msg.sender].store][_dev];
  }

  function getRevenue(address _dev) external view onlyAgentStorage() returns (uint256) {
    return DevsRevenue[_dev];
  }

  function getInfo(address _dev) external view onlyAgentStorage() returns (bytes32, bytes32, bool, uint32) {
    return (Devs[_dev].name,      
      Devs[_dev].desc, 
      Devs[_dev].state,
      Devs[_dev].store);
  }

  /************************************************************************* 
  // Devs setters
  **************************************************************************/
  function setName(address _dev, bytes32 _name) external onlyAgentStorage() {
    //require(Devs[_dev].state);
    Devs[_dev].name = _name;
  }

  function setDesc(address _dev, bytes32 _desc) external onlyAgentStorage() {
    //require(Devs[_dev].state);
    Devs[_dev].desc = _desc;
  }

  function setStore(address _dev, uint32 _store) external onlyOwner {
    //require(Devs[_dev].state);
    Devs[_dev].store = _store;
  }

  function setStoreBlocked(address _dev, bool _state) external onlyAgentStorage() {
    //require(Devs[_dev].state);
    DevsStoreBlocked[Agents[msg.sender].store][_dev] = _state;
  }

  function setRating(address _dev, int _rating) external onlyAgentStorage() {
    //require(Devs[_dev].state);
    DevsRating[Agents[msg.sender].store][_dev] = _rating;
  }
}