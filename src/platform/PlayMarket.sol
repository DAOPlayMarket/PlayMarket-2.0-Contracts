pragma solidity ^0.4.24;

import './common/app.sol';
import './common/dev.sol';
import './common/node.sol';

/**
 * @title PlayMarket contract - basic contract DAO PlayMarket 2.0
 */
contract PlayMarket is App, Dev, Node {

  uint32 public percNode = 100; // 1% (percent to hundredths) - all that's left, will go to the developer
  
  constructor (address _appStorage, address _devStorage, address _nodeStorage, address _logStorage) public {
    setAppStorageContract(_appStorage);
    setDevStorageContract(_devStorage);
    setNodeStorageContract(_nodeStorage);
    setLogStorageContract(_logStorage);
  }

  /** 
  // Application function
  **/
  
  function addApp(uint32 _hashType, uint32 _appType, uint _price, bool _publish, string _hash) external {
    // developer must be registered and not blocked in this store
    require(DevStorage.getState(msg.sender) && !DevStorage.getStoreBlocked(msg.sender));
    uint app = AppStorage.addApp(_hashType, _appType, _price, _publish, msg.sender, _hash);
    LogStorage.addAppEvent(app, _hashType, _appType, _price, _publish, msg.sender, _hash);
  }  

  // buy object without check price
  function buyAppObj(uint _app, address _node, uint _obj) public payable {

    address _dev = AppStorage.getDeveloper(_app);
    require(!DevStorage.getStoreBlocked(_dev));

    AppStorage.buyObject(_app, msg.sender, _obj, true);
    // type of percNode => uint32 and max value 100%. [0-10000]
    // example msg.value = 1000 wei, percNode = 0%: 1000 * 0 / 10000 = 0  => 0 wei to Node, 1000 - 0 = 1000 to Developer
    // example msg.value = 1000 wei, percNode = 1%: 1000 * 100 / 10000 = 10 => 10 wei to Node, 1000 - 10 = 990 to Developer
    // example msg.value = 1000 wei, percNode = 51%: 1000 * 5100 / 10000 = 510 => 510 wei to Node, 1000 - 510 = 410 to Developer
    // example msg.value = 1000 wei, percNode = 100%: 1000 * 10000 / 10000 = 1000 => 1000 wei to Node, 1000 - 1000 = 0 to Developer
    // so can use the usual subtraction (not safeSub)
    uint revNode = safePerc(msg.value, percNode); 
    require(address(NodeStorage).call.value(revNode)(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(msg.value - revNode)(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _obj, _node, msg.value);
  }

  // buy object with check price
  function buyAppObj(uint _app, address _node, uint _obj, uint _price) public payable {
    
    address _dev = AppStorage.getDeveloper(_app);
    require(!DevStorage.getStoreBlocked(_dev));

    AppStorage.buyObject(_app, msg.sender, _obj, true, _price);
    uint revNode = safePerc(msg.value, percNode);
    require(address(NodeStorage).call.value(revNode)(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(msg.value - revNode)(abi.encodeWithSignature("buyObject(address)", _dev)));

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
    require(address(DevStorage).call.value(msg.value - revNode)(abi.encodeWithSignature("buyObject(address)", _dev)));

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
    require(address(DevStorage).call.value(msg.value - revNode)(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _obj, _node, msg.value);
  }
  
  function buy(uint _app, address _node, uint _obj) public payable {
    address _dev = AppStorage.getDeveloper(_app);
    require(!DevStorage.getStoreBlocked(_dev));

    uint revNode = safePerc(msg.value, percNode);
    require(address(NodeStorage).call.value(revNode)(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(msg.value - revNode)(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _obj, _node, msg.value);
  }
 
  /************************************************************************* 
  // default params setters (onlyOwner => DAO)
  **************************************************************************/
  function setPercNode(uint32 _proc) public onlyOwner {
    require(_proc <= 10000);
    percNode = _proc;
  }
}