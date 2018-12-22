pragma solidity ^0.4.25;

import './Ownable.sol';
import './ERC20.03.sol';

/**
 * @title Dividend Distribution Contract for AppDAO
 */
contract AppDD is ERC20, Ownable {

  mapping (uint256 => uint256) public dividends;
  mapping (address => uint256) public ownersbal;  
  mapping (uint256 => mapping (address => bool)) public AlreadyReceived;
  uint public multiplier = 100000; // precision to ten thousandth percent (0.001%)

  address public source; // contract application
  bytes public code;     // profit interface

  event Payment(address indexed sender, uint amount);
   
  // Take profit for dividends from source contract
  function TakeProfit() external returns (uint256) {
    uint256 N = (block.timestamp - start) / period;
    if(dividends[N] > 0 ) {
        return dividends[N];
    } else {
        uint prevBalance = address(this).balance;
        require(source.call.value(0)(code));
        dividends[N] = safeSub(address(this).balance, prevBalance);
        return dividends[N];
    }
  }

  // Link to source contract and setting the start date STO
  // in linking contract must be function setStart(uint256)
  function Link(address _contract, bytes _code) external onlyOwner {
    source = _contract;
    code = _code;

    require(address(source).call.value(0)(abi.encodeWithSignature("acceptOwnership()")));
    require(address(source).call.value(0)(abi.encodeWithSignature("setStart(uint256)", start)));
    require(address(source).call.value(0)(abi.encodeWithSignature("setPeriod(uint256)", period)));
  }  

  function () public payable {
      emit Payment(msg.sender, msg.value);
  }
  
  // PayDividends to owners
  function PayDividends(uint offset, uint limit) external {
    require (address(this).balance > 0);
    require (limit <= owners.length);
    require (offset < limit);

    uint256 N = (block.timestamp - start) / period; // current - 1
    uint256 date = start + N * period - 1;
    
    require(dividends[N] > 0);

    uint share = 0;
    uint k = 0;
    for (k = offset; k < limit; k++) {
      if (!AlreadyReceived[N][owners[k]]) {
        share = safeMul(balanceOf(owners[k], date), multiplier);
        share = safeDiv(safeMul(share, 100), totalSupply_); // calc the percentage of the totalSupply_ (from 100%)

        share = safePerc(dividends[N], share);
        share = safeDiv(share, safeDiv(multiplier, 100));  // safeDiv(multiplier, 100) - convert to hundredths
        
        ownersbal[owners[k]] = safeAdd(ownersbal[owners[k]], share);
        AlreadyReceived[N][owners[k]] = true;
      }
    }
  }

  // PayDividends individuals to msg.sender
  function PayDividends() external {
    require (address(this).balance > 0);

    uint256 N = (block.timestamp - start) / period; // current - 1
    uint256 date = start + N * period - 1;

    require(dividends[N] > 0);
    //if (dividends[N] == 0) {
    //  dividends[N] = address(this).balance;
    //}
    
    if (!AlreadyReceived[N][msg.sender]) {      
      uint share = safeMul(balanceOf(msg.sender, date), multiplier);
      share = safeDiv(safeMul(share, 100), totalSupply_); // calc the percentage of the totalSupply_ (from 100%)

      share = safePerc(dividends[N], share);
      share = safeDiv(share, safeDiv(multiplier, 100));  // safeDiv(multiplier, 100) - convert to hundredths
        
      ownersbal[msg.sender] = safeAdd(ownersbal[msg.sender], share);
      AlreadyReceived[N][msg.sender] = true;
    }
  }

  // withdraw dividends
  function withdraw(uint _value) external {    
    require(ownersbal[msg.sender] >= _value);
    ownersbal[msg.sender] = safeSub(ownersbal[msg.sender], _value);
    msg.sender.transfer(_value);
  }

  function setMultiplier(uint _value) external onlyOwner {
    require(_value > 0);
    multiplier = _value;
  }
  
  function getMultiplier() external view returns (uint ) {
    return multiplier;
  }  
}