pragma solidity ^0.4.24;

import '../../common/Ownable.sol';
import './CrowdSale.02.sol';

/**
 * @title CrowdSale build contract (for apps ICO)
 */
contract CrowdSaleBuild is Ownable {
  
  address public RateContract;

  uint public emission = 100 * 10**3 * 10**8; // 100 thousand tokens
  uint public decimals = 8;  

  constructor (address _RateContract) public {
    RateContract = _RateContract;
  }

   /**
   * @dev 
   * @param _emission how many tokens will be released
   * @param _decimals decimals Tokens
   */
  function setInfo(uint _emission, uint _decimals) external onlyOwner {
    emission = _emission;
    decimals = _decimals;    
  }

  /**
   * @dev 
   * @param _contract address RateContract
   */
  function setRateContract(address _contract) external onlyOwner {
    RateContract = _contract;
  }
  
  /**
   * @dev CreateCrowdSaleContract - create new CrowdSale contract and return him address
   */   
  function CreateCrowdSaleContract(address _multisigWallet, uint _startsAt, uint _numberOfPeriods, uint _durationOfPeriod, uint _targetInUSD, address _dev) external returns (address) {    
    CrowdSale _contract = new CrowdSale(emission, decimals, _multisigWallet, _startsAt, _numberOfPeriods, _durationOfPeriod, _targetInUSD, RateContract, _dev, msg.sender);
    return address(_contract);
  }
}