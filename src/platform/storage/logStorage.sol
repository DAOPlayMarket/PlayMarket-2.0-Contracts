pragma solidity ^0.4.24;

import '../../common/AgentStorage.sol';
import './logStorageI.sol';

/**
 * @title Logs contract - basic contract for working with logs (only events)
 */
contract LogStorage is LogStorageI, AgentStorage {

  //App events 
  event AddAppEvent(uint32 indexed store, uint indexed app, uint32 hashType, uint32 indexed appType, uint price, bool publish, address dev, string hash);
  event SetConfirmationAppEvent(uint32 indexed store, uint indexed app, bool state, address moderator, uint32 hashType, string hash);
  event ChangeHashAppEvent(uint32 indexed store, uint indexed app, string hash, uint32 hashType);
  event ChangePublishEvent(uint32 indexed store, uint indexed app, bool state);
  event SetPriceEvent(uint32 indexed store, uint indexed app, uint obj, uint price);
  event BuyAppEvent(uint32 indexed store, address indexed user, address indexed dev, uint app, uint obj, address node, uint price);
  
  //Ico App events
  event AddAppICOEvent(uint32 indexed store, uint app, string hash, uint32 hashType);
  event ChangeHashAppICOEvent(uint32 indexed store, uint indexed app, string hash, uint32 hashType);

  //ICO events 
  event ICOCreateEvent(uint32 indexed store, address dev, uint app, string name, string symbol, address crowdsale, address token, string hash, uint32 hashType);
  event ICODeleteEvent(uint32 indexed store, address dev, uint app, string name, string symbol, address crowdsale, address token, string hash, uint32 hashType);
  event ICOConfirmationEvent(uint32 indexed store, address dev, uint app, bool state);  
  
  //Developer events 
  event AddDevEvent(uint32 indexed store, address indexed dev, bytes32 name, bytes32 desc);
  event ChangeNameDevEvent(uint32 indexed store, address indexed dev, bytes32 name, bytes32 desc);
  event SetStoreBlockedDevEvent(uint32 indexed store, address indexed dev, bool state);
  event SetRatingDevEvent(uint32 indexed store, address indexed dev, int rating);
  
  //Node events  
  event AddNodeEvent(uint32 indexed store, address indexed node, uint32 hashType, string hash, string ip, string coordinates);
  event ChangeInfoNodeEvent(uint32 indexed store, address node, string hash, uint32 hashType, string ip, string coordinates);
  event RequestCollectNodeEvent(uint32 indexed store, address node);
  event CollectNodeEvent(uint32 indexed store, address node, uint amount);
  event MakeDepositNodeEvent(uint32 indexed store, address from, address node, uint ETH, uint PMT);
  event MakeDepositETHNodeEvent(uint32 indexed store, address from, address node, uint value);
  event MakeDepositPMTNodeEvent(uint32 indexed store, address from, address node, uint value);
  event RequestRefundNodeEvent(uint32 indexed store, address node, uint refundTime);
  event RefundNodeEvent(uint32 indexed store, address node);
  event SetConfirmationNodeEvent(uint32 indexed store, address indexed node, bool state, address moderator);
  event SetDepositLimitsNodeEvent(uint32 indexed store, address node, uint ETH, uint PMT, address moderator);
  
  //Reviews events  
  event FeedbackRatingEvent(uint32 indexed store, address voter, uint indexed app, uint vote, string description, bytes32 txIndex, uint blocktimestamp);
  
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
    emit SetPriceEvent(Agents[msg.sender].store, _app, _obj, _price);
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
  
  function changeHashAppICOEvent(uint _app, string _hash, uint32 _hashType) external onlyAgentStorage() {
    emit ChangeHashAppICOEvent(Agents[msg.sender].store, _app, _hash, _hashType);
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
  function icoCreateEvent(address _dev, uint _app, string _name, string _symbol, address _crowdsale, address _token, string _hash, uint32 _hashType) external onlyAgentStorage() {
    emit ICOCreateEvent(Agents[msg.sender].store, _dev, _app, _name, _symbol, _crowdsale, _token, _hash, _hashType);
  }
  
  function icoDeleteEvent(address _dev, uint _app, string _name, string _symbol, address _crowdsale, address _token, string _hash, uint32 _hashType) external onlyAgentStorage() {
    emit ICODeleteEvent(Agents[msg.sender].store, _dev, _app, _name, _symbol, _crowdsale, _token, _hash, _hashType);
  }
  
  function icoConfirmationEvent(address _dev, uint _app, bool _state) external onlyAgentStorage() {
    emit ICOConfirmationEvent(Agents[msg.sender].store, _dev, _app, _state);
  }  
  
  /** 
  ** Feedback Rating event
  **/
  function feedbackRatingEvent(address _voter, uint _app, uint _vote, string _description, bytes32 _txIndex, uint _blocktimestamp) external onlyAgentStorage() {
    emit FeedbackRatingEvent(Agents[msg.sender].store, _voter, _app, _vote, _description, _txIndex, _blocktimestamp);
  }
}
