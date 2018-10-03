pragma solidity ^0.4.24;

import '../Base.sol';
import '../common/Agent.sol';
import './ICO/ICOListI.sol';
import './storage/appStorageI.sol';
import './storage/devStorageI.sol';

/**
 * @title PlayMarket contract - basic ICO contract DAO PlayMarket 2.0
 */
contract ICO is Agent, Base {

  bytes32 public version = "1.0.0";

  ICOListI public ICOList;
  AppStorageI public AppStorage;
  DevStorageI public DevStorage;

  event setICOListContractEvent(address _ICOList);       
  event setAppStorageContractEvent(address _contract);  
  event setDevStorageContractEvent(address _contract);

  struct _ICO {
    string name;
    string symbol;
    uint startsAt;
    uint number;
    uint duration;
    uint targetInUSD;
    address token;
    address crowdsale;
    string hash;
    uint32 hashType;
  }

  mapping (uint => _ICO) public ICOs;

  constructor (address _appStorage, address _devStorage, address _logStorage, address _ICOList) public {
    require(_ICOList  != address(0));    
    setICOListContract(_ICOList);
    setAppStorageContract(_appStorage);
    setDevStorageContract(_devStorage);
    setLogStorageContract(_logStorage);
  }

  // link to ICOList contract
  function setICOListContract(address _contract) public onlyOwner {
    ICOList = ICOListI(_contract);
    emit setICOListContractEvent(_contract);
  }

  // link to dev storage
  function setDevStorageContract(address _contract) public onlyOwner {
    DevStorage = DevStorageI(_contract);
    emit setDevStorageContractEvent(_contract);
  }

  // link to app storage
  function setAppStorageContract(address _contract) public onlyOwner {
    AppStorage = AppStorageI(_contract);
    emit setAppStorageContractEvent(_contract);
  }

  function addAppICOInfo(uint _app, string _name, string _symbol, uint _startsAt, uint _numberOfPeriods, uint _durationOfPeriod, uint _targetInUSD, string _hash, uint32 _hashType) external {
    address dev = AppStorage.getDeveloper(_app);
    require(msg.sender == dev);
    require(!DevStorage.getStoreBlocked(dev));

    _ICO storage ico = ICOs[_app];
    
    ico.name = _name;
    ico.symbol = _symbol;
    ico.startsAt = _startsAt;
    ico.number = _numberOfPeriods;
    ico.duration = _durationOfPeriod;
    ico.targetInUSD = _targetInUSD;
    ico.hash = _hash;
    ico.hashType = _hashType;
    
    ICOList.addHashAppICO(_app, dev, _hash, _hashType);
    LogStorage.addAppICOEvent(_app, _hash, _hashType);
  }

  function changeHashAppICO(uint _app, string _hash, uint32 _hashType) external {
    address dev = AppStorage.getDeveloper(_app);
    require(msg.sender == dev);
    require(!DevStorage.getStoreBlocked(dev));
    ICOList.changeHashAppICO(_app, dev, _hash, _hashType);
    LogStorage.changeHashAppICOEvent(_app, _hash, _hashType);
  }

  function addAppICO(uint _app, address _multisigWallet, uint _CSID, uint _ATID) external {
    address _dev = AppStorage.getDeveloper(_app);
    require(msg.sender == _dev);
    require(!DevStorage.getStoreBlocked(_dev));

    _ICO storage ico = ICOs[_app];

    // create CrowdSale contract from CrowdSale Build contract
    ico.crowdsale = ICOList.CreateCrowdSale(_multisigWallet, ico.startsAt, ico.number, ico.duration, ico.targetInUSD, _CSID, _app, _dev);
    // create AppToken contract from AppToken Build contract
    ico.token = ICOList.CreateAppToken(ico.name, ico.symbol, _ATID, _app, _dev);
    // generate event about create contract
    LogStorage.icoCreateEvent(_dev, _app, ico.name, ico.symbol, ico.crowdsale, ico.token, ico.hash, ico.hashType);
  }

  function delAppICO(uint _app) external {
    address _dev = AppStorage.getDeveloper(_app);
    require(msg.sender == _dev);
    require(!DevStorage.getStoreBlocked(_dev));

    _ICO storage ico = ICOs[_app];
    ICOList.DeleteICO(_app, msg.sender);
    LogStorage.icoDeleteEvent(_dev, _app, ico.name, ico.symbol, ico.crowdsale, ico.token, ico.hash, ico.hashType);
  }

  function setConfirmationICO(address _dev, uint _app, bool _state) external onlyAgent() {
    _ICO storage ico = ICOs[_app];
    require(ico.token != address(0));
    require(ico.crowdsale != address(0));
    ICOList.setConfirmation(_dev, _app, _state);
    LogStorage.icoConfirmationEvent(_dev, _app, _state);
  }
}