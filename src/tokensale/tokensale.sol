pragma solidity ^0.4.24;

import '../common/SafeMath.sol';
import '../common/Agent.sol';
import '../common/RateI.sol';
import '../exchange/PEX.sol';
import './crowdsale.sol';

/**
 * @title 
 */
contract TokenSale is Agent, SafeMath{
  
  struct _contractAdd {
    string name;
    string symbol;
    uint256 decimals;
    address contractAddress;
    uint256 startsAt;
    uint256 totalInUSD;
    bool release;
  }

  PEX public adrPEXContract;
  RateContractI public RateContract;
  address public DAOPlayMarket;  
  uint256 public initialSupply = 10000000000000000;
  uint256 public decimals_ = 8; 
  uint256 public endsAt = 90 days;
  
  mapping (address => mapping (uint =>  _contractAdd)) public contractAdd;
  
  event setPEXAdrEvent(address adrPEX);
  
  constructor (address _DAOPlayMarket, address _RateContract, address _adrPEXContract ) public{
    DAOPlayMarket = _DAOPlayMarket;
    RateContract = RateContractI(_RateContract);
    adrPEXContract = PEX(_adrPEXContract);
  }
  
  /**
   * @dev getTokensContract 
   */
  function getTokensContract(string _name, string _symbol,address _multisigWallet, uint _startsAt, uint _totalInUSD, uint _idApp, address _adrDev) public onlyAgent {
    require(contractAdd[_adrDev][_idApp].release == false);
    CrowdSale contractAddress = new CrowdSale(initialSupply, decimals_, _name, _symbol, _multisigWallet, _startsAt, _totalInUSD, DAOPlayMarket, RateContract, _adrDev);
    contractAdd[_adrDev][_idApp].name = _name;
    contractAdd[_adrDev][_idApp].symbol = _symbol;
    contractAdd[_adrDev][_idApp].decimals = decimals_;
    contractAdd[_adrDev][_idApp].contractAddress = address(contractAddress);
    contractAdd[_adrDev][_idApp].startsAt = _startsAt;
    contractAdd[_adrDev][_idApp].totalInUSD = _totalInUSD;
    contractAdd[_adrDev][_idApp].release = false;
    
    uint amount = safeDiv(safeMul(initialSupply,85),100);
    contractAddress.mint(address(contractAddress), amount);
  }

  /**
   * @dev 
   * @param _initialSupply how many tokens will be released
   * @param _decimals decimals Tokens
   */
  function setInfo(uint256 _initialSupply, uint256 _decimals, uint256 _endsAt) public onlyOwner {
    initialSupply = _initialSupply;
    decimals_ = _decimals;
    endsAt = _endsAt;
  }
  
  /**
   * @dev 
   * @param _DAOPlayMarket platform address
   */
  function setAddressDAOPlayMarket(address _DAOPlayMarket) public onlyOwner {
    DAOPlayMarket = _DAOPlayMarket;
  }
  
  /**
   * @dev set RateContract address
   * @param _contract rate contract address
   */
  function setRateContract(address _contract) public onlyOwner {
    RateContract = RateContractI(_contract);    
  }
  
  /**
   * @dev 
   * @param _adrPEXContract current PEX address
   */
  function setPEXAdr(address _adrPEXContract) public onlyOwner {
    adrPEXContract = PEX(_adrPEXContract);
  }
  
  /**
   * @dev 
   * @param _adrDev address developer
   * @param _idApp id app
   * @param _release release
   */
  function setRelease(address _adrDev, uint _idApp, bool _release) public onlyAgent returns (address){
    require(contractAdd[_adrDev][_idApp].contractAddress != address(0));
    contractAdd[_adrDev][_idApp].release = _release;
    adrPEXContract.setWhitelistTokens(contractAdd[_adrDev][_idApp].contractAddress, _release, contractAdd[_adrDev][_idApp].startsAt+endsAt);
    return contractAdd[_adrDev][_idApp].contractAddress;
  } 
}