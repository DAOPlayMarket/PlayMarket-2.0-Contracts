pragma solidity ^0.4.24;

import '../../common/AgentStorage.sol';
import './logStorageI.sol';

/**
 * @title Logs contract - basic contract for working with logs (only events)
 */
contract LogStorage is LogStorageI, AgentStorage {

  //App events 
  event AddAppEvent(uint32 indexed _store, uint indexed _app, uint32 _hashType, uint32 indexed _appType, uint _price, bool _publish, address _dev, string _hash);
  event SetConfirmationAppEvent(uint32 indexed _store, uint indexed _app, bool _state, address _moderator);
  event ChangeHashEvent(uint32 indexed _store, uint indexed _app, string _hash, uint32 _hashType);
  event ChangePublishEvent(uint32 indexed _store, uint indexed _app, bool publish);
  event ChangePriceEvent(uint32 indexed _store, uint indexed _app, uint price);
  event BuyAppEvent(uint32 indexed _store, address indexed _user, address indexed _dev, uint _app, address _node, uint price);
  
  //Ico App events 
  event AddAppICOEvent(uint32 indexed _store, uint _app, string hash, uint32 _hashType);
  event ChangeICOHashEvent(uint32 indexed _store, uint indexed _app, string hash, uint32 _hashType);
  
  //Developer events 
  event AddDevEvent(uint32 indexed _store, address indexed _dev, bytes32 _name, bytes32 _info);
  event ChangeNameDevEvent(uint32 indexed _store, address indexed _dev, bytes32 _name, bytes32 _info);
  event SetConfirmationDevEvent(uint32 indexed _store, address indexed _dev, bool _state);
  
  //Node events  
  event AddNodeEvent(uint32 indexed _store, address indexed _node, uint32 _hashType, bytes24 _reserv, string _hash, string _ip, string _coordinates);
  event ConfirmationNodeEvent(uint32 indexed _store, address indexed _node, bool _state);
  event ChangeInfoNodeEvent(uint32 indexed _store, address _node, string _hash, uint32 _hashType, string _ip, string _coordinates);
  
  //Reviews events  
  event FeedbackRatingEvent(uint32 indexed store, address voter, uint indexed _app, uint vote, string description, bytes32 txIndex, uint blocktimestamp);
  
  //ICO events 
  event releaseICOEvent(address adrDev, uint _app, bool release, address ICO);
  event newContractEvent(string name, string symbol, address adrDev, uint _app);
  

  /** 
  ** Applications events 
  **/
  function addAppEvent(uint _app, uint32 _hashType, uint32 _appType, uint _price, bool _publish, address _dev, string _hash) external onlyAgentLog {
    emit AddAppEvent(Agents[msg.sender].store, _app, _hashType, _appType, _price, _publish, _dev, _hash);
  }

  function setConfirmationAppEvent(uint _app, bool _state, address _moderator) external onlyAgentLog {
    emit SetConfirmationAppEvent(Agents[msg.sender].store, _app, _state, _moderator);
  }
  
  function changeHashEvent(uint _app, string _hash, uint32 _hashType) external onlyAgentLog {
    emit ChangeHashEvent(Agents[msg.sender].store, _app, _hash, _hashType);
  }
  
  function changePublishEvent(uint _app, bool _publish) external onlyAgentLog {
    emit ChangePublishEvent(Agents[msg.sender].store, _app, _publish);
  }
  
  function changePriceEvent(uint _app, uint _price) external onlyAgentLog {
    emit ChangePriceEvent(Agents[msg.sender].store, _app, _price);
  }
  
  function buyAppEvent(address _user, address _dev, uint _app, address _node, uint _price) external onlyAgentLog {
    emit BuyAppEvent(Agents[msg.sender].store, _user, _dev, _app, _node, _price);
  }
  

  /** 
  ** Applications ICO events 
  **/
  function addAppICOEvent(uint _app, string hash, uint32 hashType) external onlyAgentLog {
    emit AddAppICOEvent(Agents[msg.sender].store, _app, hash, hashType);
  }
  
  function changeHashICOEvent(uint _app, string hash, uint32 hashType) external onlyAgentLog {
    emit ChangeICOHashEvent(Agents[msg.sender].store, _app, hash, hashType);
  }


  /** 
  ** Developers events 
  **/  
  function addDevEvent(address _dev, bytes32 name, bytes32 info) external onlyAgentLog {
    emit AddDevEvent(Agents[msg.sender].store, _dev, name, info);
  }
  
  function changeNameDevEvent(address _dev, bytes32 name, bytes32 info) external onlyAgentLog {
    emit ChangeNameDevEvent(Agents[msg.sender].store, _dev, name, info);
  }
  
  function setConfirmationDevEvent(address _dev, bool _state) external onlyAgentLog {
    emit SetConfirmationDevEvent(Agents[msg.sender].store, _dev, _state);
  }
  

  /** 
  ** Nodes events 
  **/  
  function addNodeEvent(address _node, uint32 _hashType, bytes24 _reserv, string _hash, string _ip, string _coordinates) external onlyAgentLog {
    emit AddNodeEvent(Agents[msg.sender].store, _node, _hashType, _reserv, _hash, _ip, _coordinates);
  }
  
  function confirmationNodeEvent(address _node, bool value) external onlyAgentLog {
    emit ConfirmationNodeEvent(Agents[msg.sender].store, _node, value);
  }

  function changeInfoNodeEvent(address _node,  string _hash, uint32 _hashType, string _ip, string _coordinates) external onlyAgentLog {
    emit ChangeInfoNodeEvent(Agents[msg.sender].store, _node, _hash, _hashType, _ip, _coordinates);
  }

  
  //function releaseICOEvent(address adrDev, uint _app, bool release, address ICO) external onlyAgentLog {
  //  emit releaseICOEvent(adrDev, _app, release, ICO);
  //}  
  
  //function newContractEvent(string name, string symbol, address adrDev, uint _app) external onlyAgentLog {
  //  emit newContractEvent(name, symbol, adrDev, _app);
  //}

  /** 
  ** Feedback Rating event
  **/
  function feedbackRatingEvent(address voter, uint _app, uint vote, string description, bytes32 txIndex, uint blocktimestamp) external onlyAgentLog {
    emit FeedbackRatingEvent(Agents[msg.sender].store, voter, _app, vote, description, txIndex, blocktimestamp);
  }
}