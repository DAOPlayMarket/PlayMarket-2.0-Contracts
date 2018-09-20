pragma solidity ^0.4.24;

import '../common/Agent.sol';
import '../common/SafeMath.sol';
import './common/app.sol';
import './common/dev.sol';
import './common/node.sol';
import './ICO/ICOListI.sol';

/**
 * @title PlayMarket contract - basic contract DAO PlayMarket 2.0
 */
contract PlayMarket is App, Dev, Node {
  
  ICOListI public ICOList;  
  
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

  // buy object without check price
  function buyAppObj(uint _app, address _node, uint _obj) public payable {

    address _dev = AppStorage.getDeveloper(_app);
    require(!DevStorage.getStoreBlocked(_dev));

    AppStorage.buyObject(_app, msg.sender, _obj, true);
    require(address(NodeStorage).call.value(safePerc(msg.value, percNode))(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safePerc(msg.value, percDev))(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _obj, _node, msg.value);
  }

  // buy object with check price
  function buyAppObj(uint _app, address _node, uint _obj, uint _price) public payable {
    
    address _dev = AppStorage.getDeveloper(_app);
    require(!DevStorage.getStoreBlocked(_dev));

    AppStorage.buyObject(_app, msg.sender, _obj, true, _price);
    require(address(NodeStorage).call.value(safePerc(msg.value, percNode))(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safePerc(msg.value, percDev))(abi.encodeWithSignature("buyObject(address)", _dev)));

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
    require(address(NodeStorage).call.value(safePerc(msg.value, percNode))(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safePerc(msg.value, percDev))(abi.encodeWithSignature("buyObject(address)", _dev)));

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
    require(address(NodeStorage).call.value(safePerc(msg.value, percNode))(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safePerc(msg.value, percDev))(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _obj, _node, msg.value);
  }
  
  function buy(uint _app, address _node, uint _obj) public payable {
    address _dev = AppStorage.getDeveloper(_app);
    require(!DevStorage.getStoreBlocked(_dev));

    require(address(NodeStorage).call.value(safePerc(msg.value, percNode))(abi.encodeWithSignature("buyObject(address)", _node)));
    require(address(DevStorage).call.value(safePerc(msg.value, percDev))(abi.encodeWithSignature("buyObject(address)", _dev)));

    LogStorage.buyAppEvent(msg.sender, _dev, _app, _obj, _node, msg.value);
  }
  /** 
  // Application ICO function
  **/ 

  function addAppICO(uint _app, string _hash, uint32 _hashTag) external onlyAgent {
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

}