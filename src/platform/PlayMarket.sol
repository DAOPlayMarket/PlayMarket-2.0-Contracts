pragma solidity ^0.4.24;

import './common/app.sol';
import './common/dev.sol';
import './common/node.sol';

/**
 * @title PlayMarket contract - basic contract DAO PlayMarket 2.0
 */
contract PlayMarket is App, Dev, Node {

  bytes32 public version = "1.0.0";

  uint32 public percNode = 1; // all that's left, will go to the developer
  
  constructor (address _appStorage, address _devStorage, address _nodeStorage, address _logStorage) public {
    require(_appStorage  != address(0));
    require(_devStorage  != address(0));    
    require(_nodeStorage != address(0));
    require(_logStorage  != address(0));

    setAppStorageContract(_appStorage);
    setDevStorageContract(_devStorage);    
    setNodeStorageContract(_nodeStorage);
    setLogStorageContract(_logStorage);
  }

  /** 
  // Application function
  **/

  // buy object without check price
  function buyAppObj(uint _app, address _node, uint _obj) public payable {

    address _dev = AppStorage.getDeveloper(_app);
    require(!DevStorage.getStoreBlocked(_dev));

    AppStorage.buyObject(_app, msg.sender, _obj, true);
    uint revNode = safePerc(msg.value, percNode);
    require(address(NodeStorage).call.value(revNode)(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safeSub(msg.value, revNode))(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _obj, _node, msg.value);
  }

  // buy object with check price
  function buyAppObj(uint _app, address _node, uint _obj, uint _price) public payable {
    
    address _dev = AppStorage.getDeveloper(_app);
    require(!DevStorage.getStoreBlocked(_dev));

    AppStorage.buyObject(_app, msg.sender, _obj, true, _price);
    uint revNode = safePerc(msg.value, percNode);
    require(address(NodeStorage).call.value(revNode)(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safeSub(msg.value, revNode))(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _obj, _node, msg.value);
  }

  // buy subscription without check price
  function buyAppSub(uint _app, address _node, uint _obj) public payable {

    address _dev = AppStorage.getDeveloper(_app);
    require(!DevStorage.getStoreBlocked(_dev));
    uint timeEnd = AppStorage.getTimeSubscription(_app, msg.sender, _obj);
    if (timeEnd <= block.timestamp){
      timeEnd = block.timestamp + AppStorage.getDuration(_app, _obj);
    } else {
      timeEnd = timeEnd + AppStorage.getDuration(_app, _obj);
    }
    AppStorage.buySubscription(_app, msg.sender, _obj, timeEnd);
    uint revNode = safePerc(msg.value, percNode);
    require(address(NodeStorage).call.value(revNode)(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safeSub(msg.value, revNode))(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _obj, _node, msg.value);
  }

// buy subscription with check price
  function buyAppSub(uint _app, address _node, uint _obj, uint _price) public payable {

    address _dev = AppStorage.getDeveloper(_app);
    require(!DevStorage.getStoreBlocked(_dev));
    uint timeEnd = AppStorage.getTimeSubscription(_app, msg.sender, _obj);
    if (timeEnd <= block.timestamp){
      timeEnd = block.timestamp + AppStorage.getDuration(_app, _obj);
    } else {
      timeEnd = timeEnd + AppStorage.getDuration(_app, _obj);
    }
    AppStorage.buySubscription(_app, msg.sender, _obj, timeEnd, _price);
    uint revNode = safePerc(msg.value, percNode);
    require(address(NodeStorage).call.value(revNode)(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safeSub(msg.value, revNode))(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _obj, _node, msg.value);
  }
  
  function buy(uint _app, address _node, uint _obj) public payable {
    address _dev = AppStorage.getDeveloper(_app);
    require(!DevStorage.getStoreBlocked(_dev));

    uint revNode = safePerc(msg.value, percNode);
    require(address(NodeStorage).call.value(revNode)(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safeSub(msg.value, revNode))(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _obj, _node, msg.value);
  }
 
  /************************************************************************* 
  // default params setters (onlyOwner => DAO)
  **************************************************************************/
  function setPercNode(uint32 _proc) public onlyOwner {
    percNode = _proc;
  }
}