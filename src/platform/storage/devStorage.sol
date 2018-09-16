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
    bool confirmation;  
    uint32 store;      // default 1
    bytes26 reserv;
  }

  mapping (address => _Dev) private Devs;
  mapping (uint32 => mapping (address => int256)) private DevsRating;
  mapping (address => uint256) private DevsRevenue;

  function addDev(address _dev, bytes32 _name, bytes32 _info, bool _confirmation, bytes26 _reserv) external onlyAgentDev(_dev) {
    assert(!Devs[_dev].state);
    Devs[_dev]=_Dev({
      name: _name,
      info: _info,
      state: true,
      confirmation: _confirmation,      
      store: Agents[msg.sender].store,
      reserv: _reserv
    });
  }

  function changeName(address _dev, bytes32 _name, bytes32 _info) external onlyAgentDev(_dev) {
    Devs[_dev].name = _name;
    Devs[_dev].info = _info;
  }

  function buyObject(address _dev) payable external onlyAgentDev(_dev) {
    assert(Devs[_dev].state);
    assert(msg.value > 0);
    DevsRevenue[_dev] = safeAdd(DevsRevenue[_dev], msg.value);
  }

  // collect the accumulated amount
  function collect(address _dev) external onlyAgentDev(_dev) {
    uint256 amount = DevsRevenue[_dev];
    assert(amount > 0);
    DevsRevenue[_dev] = 0;
    _dev.transfer(amount);
  }

  /************************************************************************* 
  // Devs getters
  **************************************************************************/
  function getName(address _dev) external view onlyAgentDev(_dev) returns (bytes32) {
    return Devs[_dev].name;
  }

  function getInfo(address _dev) external view onlyAgentDev(_dev) returns (bytes32) {
    return Devs[_dev].info;
  }

  function getState(address _dev) external view onlyAgentDev(_dev) returns (bool) {
    return Devs[_dev].state;
  }

  function getConfirmation(address _dev) external view onlyAgentDev(_dev) returns (bool) {
    return Devs[_dev].confirmation;
  }

  function getStore(address _dev) external view onlyAgentDev(_dev) returns (uint32) {
    return Devs[_dev].store;
  }

  function getRating(address _dev) external view onlyAgentDev(_dev) returns (int256) {
    return DevsRating[Agents[msg.sender].store][_dev];
  }

  function getRevenue(address _dev) external view onlyAgentDev(_dev) returns (uint256) {
    return DevsRevenue[_dev];
  }

  /************************************************************************* 
  // Devs setters
  **************************************************************************/
  function setName(address _dev, bytes32 _name) external onlyAgentDev(_dev) {
    Devs[_dev].name = _name;
  }

  function setInfo(address _dev, bytes32 _info) external onlyAgentDev(_dev) {
    Devs[_dev].info = _info;
  }

  function setConfirmation(address _dev, bool _state) external onlyAgentDev(_dev) {
    assert(Agents[msg.sender].store == Devs[_dev].store); //not sure...
    Devs[_dev].confirmation = _state;
  }

  function setStore(address _dev, uint32 _store) external onlyOwner {
    Devs[_dev].store = _store;
  }

  function setRating(address _dev, int _rating) external onlyAgentDev(_dev) {
    DevsRating[Agents[msg.sender].store][_dev] = _rating;
  }
}