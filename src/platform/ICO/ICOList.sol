pragma solidity ^0.4.24;

import '../../common/SafeMath.sol';
import '../../common/AgentStorage.sol';
import '../../exchange/PEXI.sol';
import '../../fund/PMFundI.sol';
import './ICOListI.sol';
import './CrowdSaleI.sol';
import './AppTokenBuildI.sol';
import './CrowdSaleBuildI.sol';

/**
 * @title List of ICO contract
 */
contract ICOList is ICOListI, AgentStorage, SafeMath {
  
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
    bool confirmation;
  }

  address public PMFund;        // DAO PlayMarket 2.0 Foundation address
  PEXI public PEXContract;      // DAO PlayMarket 2.0 Exchange address

  mapping (uint => mapping (address => mapping (uint => _ICO))) public ICOs; // ICOs[store][dev][app]
  
  mapping (uint => address) public AppTokens;
  mapping (uint => address) public CrowdSales;
  
  event setPEXContractEvent(address _contract);
  event setAppTokenContractEvent(address _contract);
  event setCrowdSaleContractEvent(address _contract);
  
  constructor (address _PMFund, address _PEXContract) public {
    PMFund      = _PMFund;
    PEXContract = PEXI(_PEXContract);
  }

  function addHashAppICO(uint _app, address _dev, string _hash, uint32 _hashType) external onlyAgentStorage() {  
    uint32 store = Agents[msg.sender].store;
    require(!ICOs[store][_dev][_app].confirmation);

    _ICO storage ico = ICOs[store][_dev][_app];
    
    ico.hash = _hash;
    ico.hashType = _hashType;  
    ico.confirmation = false;
  }

  function changeHashAppICO(uint _app, address _dev, string _hash, uint32 _hashType) external onlyAgentStorage() {    
    uint32 store = Agents[msg.sender].store;

    _ICO storage ico = ICOs[store][_dev][_app];
    
    ico.hash = _hash;
    ico.hashType = _hashType;      
  }

  /**
   * @dev Create CrowdSale contract
   * @param _CSID - CrowdSale ID in array CrowdSales;
   */
  function CreateCrowdSale(address _multisigWallet, uint _startsAt, uint _numberOfPeriods, uint _durationOfPeriod, uint _targetInUSD, uint _CSID, uint _app, address _dev) external onlyAgentStorage() returns (address _CrowdSale) {
    require(_CSID > 0);
    require(CrowdSales[_CSID] != address(0));
    require(_multisigWallet != address(0));

    _ICO storage ico = ICOs[Agents[msg.sender].store][_dev][_app];

    require(!ico.confirmation);

    // create CrowdSale contract _CSID type
    address CrowdSale = CrowdSaleBuildI(CrowdSales[_CSID]).CreateCrowdSaleContract(_multisigWallet, _startsAt, _numberOfPeriods, _durationOfPeriod, _targetInUSD, _dev);

    ico.startsAt = _startsAt;
    ico.number = _numberOfPeriods;
    ico.duration = _durationOfPeriod;
    ico.crowdsale = CrowdSale;
    ico.targetInUSD = _targetInUSD;

    return CrowdSale;
  }

  /**
   * @dev Create AppToken contract   
   * @param _ATID - AppToken ID in array AppTokens;
   */
  function CreateAppToken(string _name, string _symbol, uint _ATID, uint _app, address _dev) external onlyAgentStorage() returns (address _AppToken) {
    require(_ATID > 0);
    require(AppTokens[_ATID] != address(0));    

    _ICO storage ico = ICOs[Agents[msg.sender].store][_dev][_app];

    require(!ico.confirmation);
    require(ico.crowdsale != address(0));

    // create AppToken contract _ATID type and set _CrowdSale as owner
    address AppToken = AppTokenBuildI(AppTokens[_ATID]).CreateAppTokenContract(_name, _symbol, ico.crowdsale, PMFund, _dev);
    // inform the fund about new tokens
    PMFundI(PMFund).makeDeposit(address(AppToken));
    // set token contract in crowdsale
    CrowdSaleI(ico.crowdsale).setTokenContract(address(AppToken));
    
    ico.name = _name;
    ico.symbol = _symbol;    
    ico.token = AppToken;

    return AppToken;
  }

  /**
   * @dev DeleteICO 
   */
  function DeleteICO(uint _app, address _dev) external onlyAgentStorage() {
    // ICO must be confirmed
    require(ICOs[Agents[msg.sender].store][_dev][_app].confirmation);
    // and finished
    require(block.timestamp > ICOs[Agents[msg.sender].store][_dev][_app].startsAt + ICOs[Agents[msg.sender].store][_dev][_app].duration);

    ICOs[Agents[msg.sender].store][_dev][_app] = _ICO({
        name: "",
        symbol: "",        
        startsAt: 0,
        number: 0,
        duration: 0,
        targetInUSD: 0,
        token: address(0),
        crowdsale: address(0),
        hash: "",
        hashType: 0,
        confirmation: false
    });    
  }

  function setAppTokenContract(uint _ATID, address _contract) external onlyOwner {
    require(AppTokens[_ATID] == address(0));
    AppTokens[_ATID] = _contract;
    emit setAppTokenContractEvent(_contract);
  }
  
  function setCrowdSaleContract(uint _CSID, address _contract) external onlyOwner {
    require(CrowdSales[_CSID] == address(0));
    CrowdSales[_CSID] = _contract;
    emit setCrowdSaleContractEvent(_contract);
  }

  function setPMFund(address _PMFund) external onlyOwner {
    PMFund = _PMFund;
  }
  
  function setPEXContract(address _contract) external onlyOwner {
    PEXContract = PEXI(_contract);
    emit setPEXContractEvent(_contract);
  }
  
  // confirm ICO and add token to DAO PlayMarket 2.0 Exchange (DAOPEX)
  function setConfirmation(address _dev, uint _app, bool _state) external onlyAgentStorage() returns (address token) {
    uint32 store = Agents[msg.sender].store;

    _ICO storage ico = ICOs[store][_dev][_app];

    require(ico.token != address(0));
    require(ico.crowdsale != address(0));
    require(ico.confirmation != _state);

    ico.confirmation = _state;
    // add to whitelist on DAO PlayMarket 2.0 Exchange (DAOPEX)
    PEXContract.setWhitelistTokens(ico.token, _state, ico.startsAt + (ico.number * ico.duration));
    return ico.token;
  } 
}