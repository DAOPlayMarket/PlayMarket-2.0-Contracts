pragma solidity ^0.4.24;

import '../../common/SafeMath.sol';
import '../../common/AgentStorage.sol';
import '../../common/RateI.sol';
import '../../exchange/PEXI.sol';
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
    uint decimals;    
    uint startsAt;
    uint duration;
    uint targetInUSD;
    address token;
    address crowdsale;
    bool confirmation;
  }

  address public PMFund;        // DAO PlayMarket 2.0 Foundation address
  PEXI public PEXContract;      // DAO PlayMarket 2.0 Exchange address

  mapping (uint => mapping (address => mapping (uint => _ICO))) public ICOs;
  
  mapping (uint => address) public AppTokens;
  mapping (uint => address) public CrowdSales;
  
  event setPEXContractEvent(address _contract);
  event setAppTokenContractEvent(address _contract);
  event setCrowdSaleContractEvent(address _contract);
  
  constructor (address _PMFund, address _PEXContract) public {
    PMFund      = _PMFund;
    PEXContract = PEXI(_PEXContract);
  }

  /**
   * @dev Create CrowdSale contract
   * @param _CSID - CrowdSale ID in array CrowdSales;
   */
  function CreateCrowdSale(address _multisigWallet, uint _startsAt, uint _targetInUSD, uint _CSID, uint _app, address _dev) external onlyAgent returns (address) {
    require(_CSID > 0);
    require(CrowdSales[_CSID] != address(0));
    require(_multisigWallet != address(0));
    require(!ICOs[Agents[msg.sender].store][_dev][_app].confirmation);

    // create CrowdSale contract _CSID type
    address CrowdSale = CrowdSaleBuildI(CrowdSales[_CSID]).CreateCrowdSaleContract(_multisigWallet, _startsAt, _targetInUSD, _dev);

    return CrowdSale;
  }

  /**
   * @dev Create AppToken contract   
   * @param _ATID - AppToken ID in array AppTokens;
   */
  function CreateAppToken(string _name, string _symbol, address _crowdsale, uint _ATID, uint _app, address _dev) external onlyAgent returns (address) {
    require(_ATID > 0);
    require(AppTokens[_ATID] != address(0));    
    require(!ICOs[Agents[msg.sender].store][_dev][_app].confirmation);

    // create AppToken contract _ATID type and set _CrowdSale as owner
    address AppToken = AppTokenBuildI(AppTokens[_ATID]).CreateAppTokenContract(_name, _symbol, _crowdsale, PMFund, _dev);

    return AppToken;
  }
  
  /**
   * @dev CreateICO 
   */
  function CreateICO(string _name, string _symbol, uint _decimals, uint _startsAt, uint _duration, uint _targetInUSD, address _crowdsale, address _apptoken, uint _app, address _dev) external onlyAgent {
    require(!ICOs[Agents[msg.sender].store][_dev][_app].confirmation);

    CrowdSaleI(_crowdsale).setTokenContract(address(_apptoken));

    ICOs[Agents[msg.sender].store][_dev][_app] = _ICO({
        name: _name,
        symbol: _symbol,
        decimals: _decimals,        
        startsAt: _startsAt,
        duration: _duration,
        targetInUSD: _targetInUSD,
        token: _apptoken,
        crowdsale: _crowdsale,
        confirmation: false
    });
  }

  /**
   * @dev DeleteICO 
   */
  function DeleteICO(uint _app, address _dev) external onlyAgent {
    // ICO must be confirmed
    require(ICOs[Agents[msg.sender].store][_dev][_app].confirmation);
    // and finished
    require(block.timestamp > ICOs[Agents[msg.sender].store][_dev][_app].startsAt + ICOs[Agents[msg.sender].store][_dev][_app].duration);

    ICOs[Agents[msg.sender].store][_dev][_app] = _ICO({
        name: "",
        symbol: "",
        decimals: 0,
        startsAt: 0,
        duration: 0,
        targetInUSD: 0,
        token: address(0),
        crowdsale: address(0),
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
  function setConfirmation(address _dev, uint _app, bool _state) external onlyAgent returns (address) {
    uint32 store = Agents[msg.sender].store;
    require(ICOs[store][_dev][_app].token != address(0));
    require(ICOs[store][_dev][_app].crowdsale != address(0));
    require(ICOs[store][_dev][_app].confirmation != _state);

    ICOs[store][_dev][_app].confirmation = _state;
    // add to whitelist on DAO PlayMarket 2.0 Exchange (DAOPEX)
    PEXContract.setWhitelistTokens(ICOs[store][_dev][_app].token, _state, ICOs[store][_dev][_app].startsAt + ICOs[store][_dev][_app].duration);
    return ICOs[store][_dev][_app].token;
  } 
}