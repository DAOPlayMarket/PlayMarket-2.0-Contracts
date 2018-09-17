pragma solidity ^0.4.24;

import '../common/Agent.sol';
import '../common/SafeMath.sol';
import './common/app.sol';
import './common/dev.sol';
import './common/log.sol';
import './common/node.sol';
import './ICO/ICOListI.sol';

/**
 * @title PlayMarket contract - basic contract DAO PlayMarket 2.0
 */
contract PlayMarket is App, Dev, Log, Node {
  
  ICOListI public ICOList;  
  LogStorageI public LogStorage;
  
  uint32 public store = 1;
  uint32 public percDev = 99;
  uint32 public percNode = 1;
  
  event setICOListEvent(address _ICO);  
  
  constructor (address _app, address _dev, address _node, address _ICO, address _log) public {
    require(_app  != address(0));
    require(_dev  != address(0));
    require(_log  != address(0));
    require(_node != address(0));
    require(_ICO  != address(0));
    
    setAppStorageContract(_app);
    setDevStorageContract(_dev);
    setLogStorageContract(_log);
    setNodeStorageContract(_node);    
  }

  /** 
  // Application function
  **/

  // add/register new application
  function addApp(uint32 _hashType, uint32 _appType, uint _price, bool _publish, string _hash) external returns (uint) {
    uint app = AppStorage.addApp(_hashType, _appType, store, _price, _publish, msg.sender, _hash);
    LogStorage.addAppEvent(app, _hashType, _appType, store, _price, _publish, msg.sender, _hash);
    return app;
  }

  // buy app without check price
  function buyApp(uint _app, address _node) public payable {
    
    require(!AppStorage.checkBuy(_app, msg.sender, 0));
    address _dev = AppStorage.getDeveloper(_app);
    require(DevStorage.getConfirmation(_dev));

    require(address(NodeStorage).call.value(safePerc(msg.value, percNode))(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safePerc(msg.value, percDev))(abi.encodeWithSignature("buyObject(address)", _dev)));
    AppStorage.buyObject(_app, msg.sender, 0, true);

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _node, msg.value);
  }

  // buy app with check price
  function buyApp(uint _app, address _node, uint _price) public payable {
    
    require(!AppStorage.checkBuy(_app, msg.sender, 0));
    address _dev = AppStorage.getDeveloper(_app);
    require(DevStorage.getConfirmation(_dev));

    AppStorage.buyObject(_app, msg.sender, 0, true, _price);
    require(address(NodeStorage).call.value(safePerc(msg.value, percNode))(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safePerc(msg.value, percDev))(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _node, msg.value);
  }

  // buy object without check price
  function buyAppObj(uint _app, address _node, uint _obj) public payable {
    
    require(!AppStorage.checkBuy(_app, msg.sender, _obj));
    address _dev = AppStorage.getDeveloper(_app);
    require(DevStorage.getConfirmation(_dev));

    require(address(NodeStorage).call.value(safePerc(msg.value, percNode))(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safePerc(msg.value, percDev))(abi.encodeWithSignature("buyObject(address)", _dev)));
    AppStorage.buyObject(_app, msg.sender, _obj, true);

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _node, msg.value);
  }

  // buy object with check price
  function buyAppObj(uint _app, address _node, uint _obj, uint _price) public payable {
    
    require(!AppStorage.checkBuy(_app, msg.sender, _obj));
    address _dev = AppStorage.getDeveloper(_app);
    require(DevStorage.getConfirmation(_dev));

    AppStorage.buyObject(_app, msg.sender, _obj, true, _price);
    require(address(NodeStorage).call.value(safePerc(msg.value, percNode))(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safePerc(msg.value, percDev))(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _node, msg.value);
  }

  /**
   * @dev We do not store the data in the contract, but generate the event. This allows you to make feedback as cheap as possible. The event generation costs 8 wei for 1 byte, and data storage in the contract 20,000 wei for 32 bytes
   * @param _app voice application identifier
   * @param vote voter rating
   * @param description voted opinion
   * @param txIndex identifier for the answer
   */
  function feedbackRating(uint _app, uint vote, string description, bytes32 txIndex) external {
    require( vote > 0 && vote <= 10);
    LogStorage.feedbackRatingEvent(msg.sender, _app, vote, description, txIndex, block.timestamp);
  }

  /** 
  // Application ICO function
  **/ 

  function addAppICO(uint _app, string _hash, uint32 _hashTag, address _dev) external onlyAgent {
    //require(checkDeveloper(_app,_dev));
    AppStorage.addAppICO(_app, _hash, _hashTag);
    //...
  }
  

  /************************************************************************* 
  // default params setters (onlyOwner => DAO)
  **************************************************************************/
  function setPercDev(uint32 _proc) public onlyOwner {
    percDev = _proc;
  }

  function setPercNode(uint32 _proc) public onlyOwner {
    percNode = _proc;
  }  

  function setStore(uint32 _store) public onlyOwner {
    store = _store;
  }  
}