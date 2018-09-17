pragma solidity ^0.4.24;

import '../../common/SafeMath.sol';
import '../../common/AgentStorage.sol';
import '../../common/RateI.sol';
import '../../exchange/PEXI.sol';
import './CrowdSaleI.sol';
import './AppTokenBuildI.sol';
import './CrowdSaleBuildI.sol';

/**
 * @title List of ICO contract
 */
contract ICOList is AgentStorage, SafeMath {
  
  struct _ICO {
    string name;
    string symbol;
    uint decimals;    
    uint startsAt;
    uint duration;
    uint totalInUSD;
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
  
  constructor (address _PMFund, address _PEXContract) public {
    PMFund      = _PMFund;
    PEXContract = PEXI(_PEXContract);
  }
  
  /**
   * @dev CreateICO 
   * @param _CSID - CrowdSale ID in array CrowdSales;
   * @param _ATID - AppToken ID in array AppTokens;
   */
  function CreateICO(string _name, string _symbol, uint _decimals, address _multisigWallet, uint _startsAt, uint _duration, uint _totalInUSD, uint _app, address _dev, uint _CSID, uint _ATID) public onlyAgent returns (address) {
    require(_CSID > 0 && _ATID > 0);
    require(_multisigWallet != address(0));
    require(!ICOs[Agents[msg.sender].store][_dev][_app].confirmation);

    // create CrowdSale contract _CSID type
    address CrowdSale = CrowdSaleBuildI(CrowdSales[_CSID]).CreateCrowdSaleContract(_multisigWallet, _startsAt, _totalInUSD, _dev);
    // create AppToken contract _ATID type and set _CrowdSale as owner
    address AppToken = AppTokenBuildI(CrowdSales[_ATID]).CreateAppTokenContract(_name, _symbol, CrowdSale, PMFund);
    // link Token to CrowdSale    
    CrowdSaleI(CrowdSale).setTokenContract(address(AppToken));

    ICOs[Agents[msg.sender].store][_dev][_app] = _ICO({
        name: _name,
        symbol: _symbol,
        decimals: _decimals,        
        startsAt: _startsAt,
        duration: _duration,
        totalInUSD: _totalInUSD,
        token: AppToken,
        crowdsale: CrowdSale,
        confirmation: false
    });

    return CrowdSale;
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
        totalInUSD: 0,
        token: address(0),
        crowdsale: address(0),
        confirmation: false
    });    
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