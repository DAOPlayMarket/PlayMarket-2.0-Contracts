pragma solidity ^0.4.24;

import './Ownable.sol';
import './Agent.sol';

/**
 * @title RateContract Interface
 * @dev 
 */
interface RateContractI {
    // returns the Currency information
    function getCurrency(bytes8 _code) external view returns (string, uint, uint, uint, uint);

    // returns Rate of coin to PMC (with the exception of rate["ETH"]) 
    function getRate(bytes8 _code) external view returns (uint);

    // returns Price of Object in the specified currency (local user currency)
    // _code - specified currency
    // _amount - price of object in PMC
    function getLocalPrice(bytes8 _code, uint _amount) external view returns (uint);

    // returns Price of Object in the crypto currency (ETH)    
    // _amount - price of object in PMC
    function getCryptoPrice(uint _amount) external view returns (uint);

    // update rates for a specific coin
    function updateRate(bytes8 _code, uint _pmc) external;
}