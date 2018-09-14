pragma solidity ^0.4.24;

import '../common/Agent.sol';
import '../common/SafeMath.sol';
import './common/app.sol';
import './common/dev.sol';
import './common/node.sol';
import './common/logsI.sol';
import '../tokensale/tokensale.sol';

/**
 * @title PlayMarket contract - basic contract DAO PlayMarket 2.0
 */
contract PlayMarket is Application, Developer, Node {
  
  TokenSale public ICOContract;
  LogsI public LogsContract;
  
  uint256 public percDev = 99;
  uint256 public percNode = 1;
  uint256 public deposit = 100*10**18;
  
  //setting up smart contract addresses
  event setAppStorageEvent(address adrApp);
  event setDevStorageEvent(address adrDev);  
  event setNodeStorageEvent(address adrNode);
  
  event setICOAdrEvent(address adrICO);
  event setLogsAdrEvent(address adrLogs);
  
  constructor (address _app, address _dev, address _node, address _ICO, address _log) public {
    require(_app  != address(0));
    require(_dev  != address(0));
    require(_node != address(0));
    require(_ICO  != address(0));
    require(_log  != address(0));
    
    // internal call
  }

  function setICOAdr(address _ICOContract) public onlyOwner {
    ICOContract = TokenSale(_ICOContract);
    emit setICOAdrEvent(_ICOContract);
  }
  
  function setLogsContract(address _LogsContract) public onlyOwner {
    LogsContract = LogsI(_LogsContract);
    emit setLogsAdrEvent(_LogsContract);
  }
  
  function buyAppMain(uint _app, address _node, uint256 _price) public payable {
    
    require(checkBuy(_app,msg.sender) == false);
    //address _dev = ApplicationContract.getDeveloper(_app);
    //require(DeveloperContract.checkConfirmation(_dev));

    //NodeContract.buyApp(_node, safePerc(msg.value, percNode));
    //DeveloperContract.buyApp(_dev, safePerc(msg.value, percDev));    
    //ApplicationContract.buyApp(_app, msg.sender, _price);

    //LogsContract.buyAppEvent_(msg.sender, _dev, _app, _node, msg.value);
  }
  
  function registrationApplicationICO(uint _app, string _hash, string _hashTag) public {
    //require(DeveloperContract.checkConfirmation(msg.sender));
    //ApplicationContract.registrationApplicationICO(_app, _hash, _hashTag, msg.sender);
    //LogsContract.registrationApplicationICOEvent_(_app, _hash, _hashTag);
  }  
  
  
  function setpercDev(uint256 _proc) public onlyOwner {
    percDev = _proc;
  }

  function setpercNode(uint256 _proc) public onlyOwner {
    percNode = _proc;
  }
  
  function setDeposit(uint256 _deposit) public onlyOwner {
    deposit = _deposit;
  }
  
  function sendWei(address adr, uint256 sum) public onlyOwner {
    adr.transfer(sum);
  }
  
  function checkBuy(uint _app, address _user) public view returns (bool success) {
      //return ApplicationContract.checkBuy(_app, _user);
  }
  
  function setRelease(address _adrDev, uint _app, bool _release ) public onlyOwner {
    address newContract  = ICOContract.setRelease(_adrDev, _app, _release);
    LogsContract.releaseICOEvent_(_adrDev, _app, _release, newContract);
  }
  
  function getTokensContract(string _name, string _symbol, address _multisigWallet, uint _startsAt, uint _totalInUSD, uint _app) public {
    //address adrDev = ApplicationContract.getDeveloper(_app);
    //require(msg.sender == adrDev);
    ICOContract.getTokensContract(_name, _symbol,_multisigWallet, _startsAt, _totalInUSD, _app, msg.sender);
    LogsContract.newContractEvent_(_name, _symbol, msg.sender, _app);
  }
  
  /**
   * @dev We do not store the data in the contract, but generate the event. This allows you to make feedback as cheap as possible. The event generation costs 8 wei for 1 byte, and data storage in the contract 20,000 wei for 32 bytes
   * @param idApp voice application identifier
   * @param vote voter rating
   * @param description voted opinion
   * @param txIndex identifier for the answer
   */
  function pushFeedbackRating(uint idApp, uint vote, string description, bytes32 txIndex) public {
    require( vote > 0 && vote <= 5);
    LogsContract.newRating_(msg.sender, idApp, vote, description, txIndex, block.timestamp);
  }
}