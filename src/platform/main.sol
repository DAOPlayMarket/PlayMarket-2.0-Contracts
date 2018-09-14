pragma solidity ^0.4.24;

import '../common/Agent.sol';
import '../common/SafeMath.sol';
//import './common/appI.sol';
//import './common/devI.sol';
//import './common/nodeI.sol';
import './common/logsI.sol';
import '../tokensale/tokensale.sol';

/**
 * @title PlayMarket contract - basic contract DAO PlayMarket 2.0
 */
contract PlayMarket is Application, Developer, Agent, SafeMath {
  
  DeveloperI public DeveloperContract;
  ApplicationI public ApplicationContract;
  NodeI public NodeContract;
  TokenSale public adrICOContract;
  LogsI public LogsContract;
  
  uint256 public percDev = 99;
  uint256 public percNode = 1;
  uint256 public deposit = 100*10**18;
  
  //setting up smart contract addresses
  event setDeveloperAdrEvent(address adrDev);
  event setApplicationAdrEvent(address adrApp);
  event setNodeAdrEvent(address adrNode);
  event setICOAdrEvent(address adrICO);
  event setLogsAdrEvent(address adrLogs);
  
  constructor (address _DeveloperContract, address _ApplicationContract, address _NodeContract, address _adrICOContract, address _LogsContract) public {
    require(_DeveloperContract != address(0));
    require(_ApplicationContract != address(0));
    require(_NodeContract != address(0));
    require(_adrICOContract != address(0));
    require(_LogsContract != address(0));
    
    DeveloperContract = DeveloperI(_DeveloperContract);
    ApplicationContract = ApplicationI(_ApplicationContract);
    NodeContract = NodeI(_NodeContract);
    adrICOContract = TokenSale(_adrICOContract);
    LogsContract = LogsI(_LogsContract);
  }
  
  function setDeveloperContract(address _DeveloperContract) public onlyOwner {
    DeveloperContract = DeveloperI(_DeveloperContract);
    emit setDeveloperAdrEvent(_DeveloperContract);
  }
  
  function setApplicationContract(address _ApplicationContract) public onlyOwner {
    ApplicationContract = ApplicationI(_ApplicationContract);
    emit setApplicationAdrEvent(_ApplicationContract);
  }
  
  function setNodeContract(address _NodeContract) public onlyOwner {
    NodeContract = NodeI(_NodeContract);
    emit setNodeAdrEvent(_NodeContract);
  }
  
  function setICOAdr(address _adrICOContract) public onlyOwner {
    adrICOContract = TokenSale(_adrICOContract);
    emit setICOAdrEvent(_adrICOContract);
  }
  
  function setLogsContract(address _LogsContract) public onlyOwner {
    LogsContract = LogsI(_LogsContract);
    emit setLogsAdrEvent(_LogsContract);
  }
  
  function buyApp(uint _app, address _node, uint256 _price) public payable {
    
    require(checkBuy(_app,msg.sender) == false);
    address _dev = ApplicationContract.getDeveloper(_app);
    require(DeveloperContract.checkConfirmation(_dev));

    NodeContract.buyApp(_node, safePerc(msg.value, percNode));
    DeveloperContract.buyApp(_dev, safePerc(msg.value, percDev));    
    ApplicationContract.buyApp(_app, msg.sender, _price);

    LogsContract.buyAppEvent_(msg.sender, _dev, _app, _node, msg.value);
  }
  
  function registrationApplication(string _hash, string _hashTag, bool _publish, uint256 _price, uint _kind) public {
    require(DeveloperContract.checkConfirmation(msg.sender));
    uint256 _app = ApplicationContract.registrationApplication(_hash, _hashTag, _publish, _price, msg.sender, _kind);
    LogsContract.registrationApplicationEvent_(_app, _hash, _hashTag, _publish, _price, msg.sender);
  }

  function confirmationApplication(uint _app, bool _status) public onlyAgent {
    //require(DeveloperContract.checkConfirmation(msg.sender));
    ApplicationContract.confirmationApplication(_app, _status);
    LogsContract.confirmationApplicationEvent_(_app, _status, msg.sender);
  }  
  
  function registrationApplicationICO(uint _app, string _hash, string _hashTag) public {
    require(DeveloperContract.checkConfirmation(msg.sender));
    ApplicationContract.registrationApplicationICO(_app, _hash, _hashTag, msg.sender);
    LogsContract.registrationApplicationICOEvent_(_app, _hash, _hashTag);
  }  
  
  function changeHash(uint _app, string _hash, string _hashTag) public {
    require(DeveloperContract.checkConfirmation(msg.sender));
    ApplicationContract.changeHash(_app, _hash, _hashTag, msg.sender);
    LogsContract.changeHashEvent_(_app, _hash, _hashTag);
  }
  
  function changeIcoHash(uint _app, string _hash, string _hashTag) public {
    require(DeveloperContract.checkConfirmation(msg.sender));
    ApplicationContract.changeIcoHash( _app, _hash, _hashTag, msg.sender);
    LogsContract.changeIcoHashEvent_(_app, _hash, _hashTag);
  }
  
  function changePublish(uint _app, bool _publish) public {
    require(DeveloperContract.checkConfirmation(msg.sender));
    ApplicationContract.changePublish(_app, _publish, msg.sender);
    LogsContract.changePublishEvent_(_app, _publish);
  }
  
  function changePrice(uint _app, uint256 _price) public {
    require(DeveloperContract.checkConfirmation(msg.sender));
    ApplicationContract.changePrice(_app, _price, msg.sender);
    LogsContract.changePriceEvent_(_app, _price);
  }
  
  function changePublishOwner(uint _app, bool _publish, address _dev) public onlyOwner {
    ApplicationContract.changePublish(_app, _publish, _dev);
    LogsContract.changePublishEvent_(_app, _publish);
  }
  
  function registrationDeveloper(bytes32 _name, bytes32 _info) public {
    DeveloperContract.registrationDeveloper(msg.sender, _name,_info);
    LogsContract.registrationDeveloperEvent_(msg.sender, _name, _info);	
  }
	
  function changeDeveloperInfo(bytes32 _name, bytes32 _info) public {
    DeveloperContract.changeDeveloperInfo(msg.sender, _name,_info);
    LogsContract.changeDeveloperInfoEvent_(msg.sender, _name, _info);	
  }

  function registrationNode(string _hash, string _hashTag, string _ip, string _coordinates) public payable {
    require(msg.value == deposit);
    require(NodeContract.getDeposit(msg.sender) == 0);
    NodeContract.registrationNode(msg.sender, _hash, _hashTag, msg.value, _ip, _coordinates);
    LogsContract.registrationNodeEvent_(msg.sender, false, _hash, _hashTag, msg.value, _ip, _coordinates);	
  }
  
  function changeInfoNode(string _hash, string _hashTag, string _ip, string _coordinates) public {
    NodeContract.changeInfoNode(msg.sender, _hash, _hashTag, _ip, _coordinates);
    LogsContract.changeInfoNodeEvent_(msg.sender, _hash, _hashTag, _ip, _coordinates);	
  }
  
  function makeDeposit() public payable {
    NodeContract.makeDeposit(msg.sender, msg.value);
    LogsContract.makeDepositEvent_(msg.sender, msg.value);
  }
  
  function takeDeposit(address _node) public onlyOwner {
    require(_node != address(0));
    uint256 depositNode = NodeContract.getDeposit(_node);
    NodeContract.takeDeposit(_node, depositNode);
    NodeContract.confirmationNode(_node, false);
    _node.transfer(depositNode);
    LogsContract.confirmationNodeEvent_(_node, false);
    LogsContract.takeDepositEvent_(_node, depositNode);
  }
  
  function confirmationNode(address _node, bool _value) public onlyOwner {
    NodeContract.confirmationNode(_node,_value);
    LogsContract.confirmationNodeEvent_(_node, _value);
  }
  
  function confirmationDeveloper(address _developer, bool _value) public onlyOwner {
    DeveloperContract.confirmationDeveloper(_developer,_value);
    LogsContract.confirmationDeveloperEvent_(_developer, _value);
  }

  function collectNode() public {
    uint256 amount = NodeContract.getRevenue(msg.sender);
    assert(amount > 0);
    NodeContract.collectNode(msg.sender);
    msg.sender.transfer(amount);
  }
  
  function collectDeveloper() public {
    uint256 amount = DeveloperContract.getRevenue(msg.sender);
    assert(amount > 0);
    ApplicationContract.collectDeveloper(msg.sender);
    msg.sender.transfer(amount);
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
      return ApplicationContract.checkBuy(_app, _user);
  }
  
  function setRelease(address _adrDev, uint _app, bool _release ) public onlyOwner {
    address newContract  = adrICOContract.setRelease(_adrDev, _app, _release);
    LogsContract.releaseICOEvent_(_adrDev, _app, _release, newContract);
  }
  
  function getTokensContract(string _name, string _symbol, address _multisigWallet, uint _startsAt, uint _totalInUSD, uint _app) public {
    address adrDev = ApplicationContract.getDeveloper(_app);
    require(msg.sender == adrDev);
    adrICOContract.getTokensContract(_name, _symbol,_multisigWallet, _startsAt, _totalInUSD, _app, msg.sender);
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