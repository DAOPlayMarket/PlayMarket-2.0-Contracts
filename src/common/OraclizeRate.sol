pragma solidity ^0.4.24;

import './Ownable.sol';
import './Agent.sol';
import './OraclizeAPI.sol';
import './RateContractI.sol';

/**
 * @title OraclizeRateContract  
 */
contract OraclizeRateContract is Agent, usingOraclize {

    RateContractI RateContract;
    bytes32 oraclize_id;
    string  oraclize_url;
    bytes32 oraclize_curr;
    uint    decimals = 2;

    event oraclizeQueryEvent(bool _status, string _comment);
    event oraclizeUpdateURLEvent(string _URL);
    event oraclizeUpdateCurrEvent(bytes32 _curr);
    event oraclizeUpdateRateContractAddressEvent(address _contract);

    constructor() public {
        oraclize_url = "json(https://api.coinmarketcap.com/v2/ticker/1027/).data.quotes.USD.price";
        oraclize_curr = "ETH";
    }

    // set RateContract address
    function setRateContract(address _contract) public onlyAgent {
        RateContract = RateContractI(_contract);
        emit oraclizeUpdateRateContractAddressEvent(_contract);
    }

    // oraclize callback function
    function __callback(bytes32 _id, string _result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        if (oraclize_id != _id) revert();

        uint _rate = parseInt(_result, decimals);
        RateContract.updateRate(oraclize_curr, _rate);        
    }
    
    // oraclize query function
    function updateRateByOraclize() public payable {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit oraclizeQueryEvent(false, "Query was NOT sent, check balance");
        } else {            
            oraclize_id = oraclize_query(300, "URL", oraclize_url);
            emit oraclizeQueryEvent(true, "Query was sent, wait");
        }
    }

    // oraclize update URL
    function updateURLOraclize(string _URL) public onlyAgent {
        oraclize_url = _URL;
        emit oraclizeUpdateURLEvent(_URL);
    }

    // oraclize update Currency
    function updateCurrOraclize(bytes32 _curr) public onlyAgent {
        oraclize_curr = _curr;
        emit oraclizeUpdateCurrEvent(_curr);
    }

    // oraclize update Currency and URL
    function updateParamsOraclize(string _URL, bytes32 _curr) public onlyAgent {        
        oraclize_url = _URL;
        oraclize_curr = _curr;
        emit oraclizeUpdateURLEvent(_URL);
        emit oraclizeUpdateCurrEvent(_curr);
    }

    // execute function by owner if ERC20 token get stuck in this contract
    function execute(address _to, uint _value, bytes _data) external onlyOwner {
        require(_to.call.value(_value)(_data));        
    }
}