pragma solidity ^0.4.24;

import './SafeMath.sol';
import './Ownable.sol';
import './Agent.sol';

/**
 * @title RateContract 
 * @dev Letter values of currencies according to the standard ISO4217.
 * @dev ETH alfa-3 code as it's and contains the rate to USD. Example: rate["ETH"] = 227$.
 * @dev PMC (DAO PlayMarket 2.0 Currency) is the virtual units (like conventional units). At this moment: 1PMC = 1$.
 * @dev rate[alfa-3 field of currency in ISO4217] contains rate to PMC. Example: rate["USD"] = 1, rate["EUR"] = 0.86, rate["RUB"] = 68.25
 */
contract RateContract is Agent, SafeMath {

    struct ISO4217 {
        string name;        
        uint number3;
        uint decimal;
        uint timeadd;
        uint timeupdate;
    }
    
    mapping(bytes8 => ISO4217) public currency;
    mapping(bytes8 => uint) public rate;
    
    event addCurrencyEvent(bytes8 _code, string _name, uint _number3, uint _decimal, uint _timeadd);
    event updateCurrencyEvent(bytes8 _code, string _name, uint _number3, uint _decimal, uint _timeupdate);
    event updateRateEvent(bytes8 _code, uint _value);
    event donationEvent(address _from, uint _value);
    event oraclizeQueryEvent(bool _status, string _comment);
    event oraclizeUpdateURLEvent(string _URL);
    event oraclizeUpdateCurrEvent(bytes8 _curr);

    constructor() public {
        addCurrency("ETH", "Ethereum", 0, 0);
        addCurrency("RUB", "Russian Ruble", 643, 2);
        addCurrency("CNY", "Yuan Renminbi", 156, 2);
        addCurrency("USD", "US Dollar", 840, 2);
        //addCurrency("EUR", "Euro", 978, 2);
        //addCurrency("INR", "Indian Rupee", 356, 2);        
        //addCurrency("JPY", "Yen", 392, 0);
        //addCurrency("KRW", "Won", 410, 0);       
    }

    // returns the Currency
    function getCurrency(bytes8 _code) public view returns (string, uint, uint, uint, uint) {
        return (currency[_code].name, currency[_code].number3, currency[_code].decimal, currency[_code].timeadd, currency[_code].timeupdate);
    }

    // returns Rate of coin to PMC (with the exception of rate["ETH"])
    function getRate(bytes8 _code) public view returns (uint) {
        return rate[_code];
    }

    // returns Price of Object in the specified currency (local user currency)
    // _code - specified currency
    // _amount - price of object in PMC
    function getLocalPrice(bytes8 _code, uint _amount) public view returns (uint) {
        return safeMul(rate[_code], _amount);
    }

    // returns Price of Object in the crypto currency (ETH)    
    // _amount - price of object in PMC
    function getCryptoPrice(uint _amount) public view returns (uint) {
        return safeDiv(safeMul(_amount, 1 ether), rate["ETH"]);
    }

    // update rates for a specific coin
    function updateRate(bytes8 _code, uint _pmc) public onlyAgent {
        rate[_code] = _pmc;
        emit updateRateEvent(_code, _pmc);
    }

    // Add new Currency
    function addCurrency(bytes8 _code, string _name, uint _number3, uint _decimal) public onlyAgent {        
        currency[_code] = ISO4217(_name, _number3, _decimal, block.timestamp, 0);
        emit addCurrencyEvent(_code, _name, _number3, _decimal, block.timestamp);
    }

    // update Currency 
    function updateCurrency(bytes8 _code, string _name, uint _number3, uint _decimal) public onlyAgent {        
        currency[_code] = ISO4217(_name, _number3, _decimal, currency[_code].timeadd, block.timestamp);
        emit updateCurrencyEvent(_code, _name, _number3, _decimal, block.timestamp);
    }

    // default function that get forwarded to the updater address 
    function() public payable {
        defAgent.transfer(msg.value);
    }

    // execute function for creator if ERC20's get stuck in this wallet
    function execute(address _to, uint _value, bytes _data) external onlyOwner returns (bytes32) {
        require(_to.call.value(_value)(_data));
        return 0;
    }

    // donation function that get forwarded to the contract updater
    function donate() external payable {
        require(msg.value >= 0);
        defAgent.transfer(msg.value);
        emit donationEvent(msg.sender, msg.value);
    }
}