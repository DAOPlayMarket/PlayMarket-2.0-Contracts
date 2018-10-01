pragma solidity ^0.4.24;

import '../../common/AgentStorage.sol';
import './logStorageI.sol';

/**
 * @title Logs contract - basic contract for working with logs (only events)
 */
contract LogStorage is LogStorageI, AgentStorage {

  //App events 
  event AddAppEvent(uint32 indexed _store, uint indexed _app, uint32 _hashType, uint32 indexed _appType, uint _price, bool _publish, address _dev, string _hash);
  event SetConfirmationAppEvent(uint32 indexed _store, uint indexed _app, bool _state, address _moderator, uint32 _hashType, string _hash);
  event ChangeHashAppEvent(uint32 indexed _store, uint indexed _app, string _hash, uint32 _hashType);
  event ChangePublishEvent(uint32 indexed _store, uint indexed _app, bool _state);
  event SetPriceEvent(uint32 indexed _store, uint indexed _app, uint _obj, uint _price);
  event BuyAppEvent(uint32 indexed _store, address indexed _user, address indexed _dev, uint _app, uint _obj, address _node, uint price);
  
  //Ico App events
  event AddAppICOEvent(uint32 indexed _store, uint _app, string _hash, uint32 _hashType);
  event ChangeHashAppICOEvent(uint32 indexed _store, uint indexed _app, string hash, uint32 _hashType);

  //ICO events 
  event ICOCreateEvent(uint32 indexed _store, address _dev, uint _app, string _name, string _symbol, uint _decimals, address _crowdsale, string _hash, uint32 _hashType);
  event ICODeleteEvent(uint32 indexed _store, address _dev, uint _app, string _name, string _symbol, uint _decimals, address _crowdsale, string _hash, uint32 _hashType);
  event ICOConfirmationEvent(uint32 indexed _store, address _dev, uint _app, bool _state);  
  
  //Developer events 
  event AddDevEvent(uint32 indexed _store, address indexed _dev, bytes32 _name, bytes32 _desc);
  event ChangeNameDevEvent(uint32 indexed _store, address indexed _dev, bytes32 _name, bytes32 _desc);
  event SetStoreBlockedDevEvent(uint32 indexed _store, address indexed _dev, bool _state);
  event SetRatingDevEvent(uint32 indexed _store, address indexed _dev, int _rating);
  
  //Node events  
  event AddNodeEvent(uint32 indexed _store, address indexed _node, uint32 _hashType, string _hash, string _ip, string _coordinates);
  event ChangeInfoNodeEvent(uint32 indexed _store, address _node, string _hash, uint32 _hashType, string _ip, string _coordinates);
  event RequestCollectNodeEvent(uint32 indexed _store, address _node);
  event CollectNodeEvent(uint32 indexed _store, address _node, uint _amount);
  event MakeDepositNodeEvent(uint32 indexed _store, address _from, address _node, uint _ETH, uint _PMT);
  event MakeDepositETHNodeEvent(uint32 indexed _store, address _from, address _node, uint _value);
  event MakeDepositPMTNodeEvent(uint32 indexed _store, address _from, address _node, uint _value);
  event RequestRefundNodeEvent(uint32 indexed _store, address _node, uint _refundTime);
  event RefundNodeEvent(uint32 indexed _store, address _node);
  event SetConfirmationNodeEvent(uint32 indexed _store, address indexed _node, bool _state, address _moderator);
  event SetDepositLimitsNodeEvent(uint32 indexed _store, address _node, uint _ETH, uint _PMT, address _moderator);
  
  //Reviews events  
  event FeedbackRatingEvent(uint32 indexed _store, address _voter, uint indexed _app, uint vote, string description, bytes32 txIndex, uint blocktimestamp);
  
  /** 
  ** Applications events 
  **/
  function addAppEvent(uint _app, uint32 _hashType, uint32 _appType, uint _price, bool _publish, address _dev, string _hash) external onlyAgentStorage() {
    emit AddAppEvent(Agents[msg.sender].store, _app, _hashType, _appType, _price, _publish, _dev, _hash);
  }

  function setConfirmationAppEvent(uint _app, bool _state, address _moderator, uint32 _hashType, string _hash) external onlyAgentStorage() {
    emit SetConfirmationAppEvent(Agents[msg.sender].store, _app, _state, _moderator, _hashType, _hash);
  }
  
  function changeHashAppEvent(uint _app, string _hash, uint32 _hashType) external onlyAgentStorage() {
    emit ChangeHashAppEvent(Agents[msg.sender].store, _app, _hash, _hashType);
  }
  
  function changePublishEvent(uint _app, bool _publish) external onlyAgentStorage() {
    emit ChangePublishEvent(Agents[msg.sender].store, _app, _publish);
  }
  
  function setPriceEvent(uint _app, uint _obj, uint _price) external onlyAgentStorage() {
    emit SetPriceEvent(Agents[msg.sender].store, _obj, _app, _price);
  }
  
  function buyAppEvent(address _user, address _dev, uint _app, uint _obj, address _node, uint _price) external onlyAgentStorage() {
    emit BuyAppEvent(Agents[msg.sender].store, _user, _dev, _app, _obj, _node, _price);
  }
  
  /** 
  ** Applications ICO events 
  **/
  function addAppICOEvent(uint _app, string _hash, uint32 _hashType) external onlyAgentStorage() {
    emit AddAppICOEvent(Agents[msg.sender].store, _app, _hash, _hashType);
  }
  
  function changeHashAppICOEvent(uint _app, string hash, uint32 hashType) external onlyAgentStorage() {
    emit ChangeHashAppICOEvent(Agents[msg.sender].store, _app, hash, hashType);
  }


  /** 
  ** Developers events 
  **/  
  function addDevEvent(address _dev, bytes32 _name, bytes32 _desc) external onlyAgentStorage() {
    emit AddDevEvent(Agents[msg.sender].store, _dev, _name, _desc);
  }
  
  function changeNameDevEvent(address _dev, bytes32 _name, bytes32 _desc) external onlyAgentStorage() {
    emit ChangeNameDevEvent(Agents[msg.sender].store, _dev, _name, _desc);
  }
  
  function setStoreBlockedDevEvent(address _dev, bool _state) external onlyAgentStorage() {
    emit SetStoreBlockedDevEvent(Agents[msg.sender].store, _dev, _state);
  }
  
  function setRatingDevEvent(address _dev, int _rating) external onlyAgentStorage() {
    emit SetRatingDevEvent(Agents[msg.sender].store, _dev, _rating);
  }
  /** 
  ** Nodes events 
  **/  
  function addNodeEvent(address _node, uint32 _hashType, string _hash, string _ip, string _coordinates) external onlyAgentStorage() {
    emit AddNodeEvent(Agents[msg.sender].store, _node, _hashType, _hash, _ip, _coordinates);
  }
  
  function changeInfoNodeEvent(address _node,  string _hash, uint32 _hashType, string _ip, string _coordinates) external onlyAgentStorage() {
    emit ChangeInfoNodeEvent(Agents[msg.sender].store, _node, _hash, _hashType, _ip, _coordinates);
  }

  function requestCollectNodeEvent(address _node) external onlyAgentStorage() {
    emit RequestCollectNodeEvent(Agents[msg.sender].store, _node);
  }

  function collectNodeEvent(address _node, uint _amount) external onlyAgentStorage() {
    emit CollectNodeEvent(Agents[msg.sender].store, _node, _amount);
  }

  function makeDepositNodeEvent(address _from, address _node, uint _ETH, uint _PMT) external onlyAgentStorage() {
    emit MakeDepositNodeEvent(Agents[msg.sender].store, _from, _node, _ETH, _PMT);
  }

  function makeDepositETHNodeEvent(address _from, address _node, uint _value) external onlyAgentStorage() {
    emit MakeDepositETHNodeEvent(Agents[msg.sender].store, _from, _node, _value);
  }

  function makeDepositPMTNodeEvent(address _from, address _node, uint _value) external onlyAgentStorage() {
    emit MakeDepositPMTNodeEvent(Agents[msg.sender].store, _from, _node, _value);
  }

  function requestRefundNodeEvent(address _node, uint _refundTime) external onlyAgentStorage() {
    emit RequestRefundNodeEvent(Agents[msg.sender].store, _node, _refundTime);
  }

  function refundNodeEvent(address _node) external onlyAgentStorage() {
    emit RefundNodeEvent(Agents[msg.sender].store, _node);
  }

  function setConfirmationNodeEvent(address _node, bool _state, address _moderator) external onlyAgentStorage() {
    emit SetConfirmationNodeEvent(Agents[msg.sender].store, _node, _state, _moderator);
  }

  function setDepositLimitsNodeEvent(address _node, uint _ETH, uint _PMT, address _moderator) external onlyAgentStorage() {
    emit SetDepositLimitsNodeEvent(Agents[msg.sender].store, _node, _ETH, _PMT, _moderator);
  }

  /** 
  ** ICO event
  **/
  function icoCreateEvent(address _dev, uint _app, string _name, string _symbol, uint _decimals, address _crowdsale, string _hash, uint32 _hashType) external onlyAgentStorage() {
    emit ICOCreateEvent(Agents[msg.sender].store, _dev, _app, _name, _symbol, _decimals, _crowdsale, _hash, _hashType);
  }
  
  function icoDeleteEvent(address _dev, uint _app, string _name, string _symbol, uint _decimals, address _crowdsale, string _hash, uint32 _hashType) external onlyAgentStorage() {
    emit ICODeleteEvent(Agents[msg.sender].store, _dev, _app, _name, _symbol, _decimals, _crowdsale, _hash, _hashType);
  }
  
  function icoConfirmationEvent(address _dev, uint _app, bool _state) external onlyAgentStorage() {
    emit ICOConfirmationEvent(Agents[msg.sender].store, _dev, _app, _state);
  }  
  
  /** 
  ** Feedback Rating event
  **/
  function feedbackRatingEvent(address voter, uint _app, uint vote, string description, bytes32 txIndex, uint blocktimestamp) external onlyAgentStorage() {
    emit FeedbackRatingEvent(Agents[msg.sender].store, voter, _app, vote, description, txIndex, blocktimestamp);
  }
}