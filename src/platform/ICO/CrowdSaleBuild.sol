pragma solidity ^0.4.24;

import '../../common/Ownable.sol';
import './CrowdSale.sol';

/**
 * @title CrowdSale build contract (for apps ICO)
 */
contract CrowdSaleBuild is Ownable {
  
  address public RateContract;

  uint public emission = 10000000000000000;
  uint public decimals = 8;
  uint public duration = 90 days;

  constructor (address _RateContract) public {
    RateContract = _RateContract;
  }

   /**
   * @dev 
   * @param _emission how many tokens will be released
   * @param _decimals decimals Tokens
   */
  function setInfo(uint _emission, uint _decimals, uint _duration) external onlyOwner {
    emission = _emission;
    decimals = _decimals;
    duration = _duration;
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
  function CreateCrowdSaleContract(address _multisigWallet, uint _startsAt, uint _targetInUSD, address _dev) external returns (address) {
    CrowdSale _contract = new CrowdSale(emission, decimals, _multisigWallet, _startsAt, _targetInUSD, RateContract, _dev);
    return address(_contract);
  }
}