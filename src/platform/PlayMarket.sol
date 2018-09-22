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

  bytes32 public version = "1.0.0";
  
  uint32 public percDev = 99;
  uint32 public percNode = 1;
  
  constructor (address _app, address _dev, address _node, address _log, address _ICO) public {
    require(_app  != address(0));
    require(_dev  != address(0));
    require(_log  != address(0));
    require(_node != address(0));
    require(_ICO  != address(0));
    
    setAppStorageContract(_app);
    setDevStorageContract(_dev);
    setLogStorageContract(_log);
    setNodeStorageContract(_node);
    setICOListContract(_ICO);
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


  /************************************************************************* 
  // ICO functional
  **************************************************************************/

  ICOListI public ICOList;  
  
  event setICOListContractEvent(address _ICO);   

  struct _ICO {
    string name;
    string symbol;
    uint decimals;    
    uint startsAt;
    uint duration;
    uint targetInUSD;
    address token;
    address crowdsale;
    bool confirmation;
  }

  mapping (uint => _ICO) public ICOs;

  // link to ICOList contract
  function setICOListContract(address _contract) public onlyOwner {
    ICOList = ICOListI(_contract);
    emit setICOListContractEvent(_contract);
  }

  function addAppICOInfo(uint _app, string _name, string _symbol, uint _decimals, uint _startsAt, uint _duration, uint _targetInUSD, string _hash, uint32 _hashType) external {
    address _dev = AppStorage.getDeveloper(_app);
    require(msg.sender == _dev);
    require(!DevStorage.getStoreBlocked(_dev));

    _ICO storage ico = ICOs[_app];
    
    ico.name = _name;
    ico.symbol = _symbol;
    ico.decimals = _decimals;
    ico.startsAt = _startsAt;
    ico.duration = _duration;
    ico.targetInUSD = _targetInUSD;
    
    AppStorage.addAppICO(_app, _hash, _hashType);
  }

  function addAppICOContracts(uint _app, address _multisigWallet, uint _CSID, uint _ATID) external {
    address _dev = AppStorage.getDeveloper(_app);
    require(msg.sender == _dev);
    require(!DevStorage.getStoreBlocked(_dev));

    _ICO storage ico = ICOs[_app];

    // create CrowdSale contract from CrowdSale Build contract
    ico.crowdsale = ICOList.CreateCrowdSale(_multisigWallet, ico.startsAt, ico.targetInUSD, _CSID, _app, _dev);
    // create AppToken contract from AppToken Build contract
    ico.token = ICOList.CreateAppToken(ico.name, ico.symbol, ico.crowdsale, _ATID, _app, _dev);
    // create ICO
    ICOList.CreateICO(ico.name, ico.symbol, ico.decimals, ico.startsAt, ico.duration, ico.targetInUSD, ico.crowdsale, ico.token, _app, _dev);
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