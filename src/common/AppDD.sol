pragma solidity ^0.4.25;

import './Ownable.sol';
import './ERC20.03.sol';

/**
 * @title Dividend Distribution Contract for AppDAO
 */
contract AppDD is ERC20, Ownable {

  address source; // contract application
  bytes code;     // profit interface

  uint256[] public dividends;
  mapping (address => uint256) public ownersbal;  
  mapping (uint256 => mapping (address => bool)) public AlreadyReceived;
  uint private multiplier = 100000; // precision to ten thousandth percent (0.001%)

  // Take profit for dividends from source contract
  function TakeProfit() external {
    require(source.call.value(0)(code));
  }

  // Link to source contract
  function Link(address _contract, bytes _code) external onlyOwner {
    source = _contract;
    code = _code;
  }  

  // PayDividends to owners
  function PayDividends(uint offset, uint limit) external {  
    require (address(this).balance > 0);
    require (limit <= owners.length);
    require (offset < limit);

    uint256 N = (block.timestamp - start) / period; // current - 1
    uint256 date = N * period - 1;

    if (dividends[N] == 0) {
      dividends[N] = address(this).balance;
    }

    uint share = 0;
    uint k = 0;
    for (k = offset; k < limit; k++) {
      if (!AlreadyReceived[N][owners[k]]) {
        share = safeMul(balanceOf(owners[k], date), multiplier);
        share = safeDiv(safeMul(share, 100), totalSupply_); // calc the percentage of the totalSupply_ (from 100%)

        share = safePerc(dividends[N], share);
        share = safeDiv(share, safeDiv(multiplier, 100));  // safeDiv(multiplier, 100) - convert to hundredths
        
        ownersbal[owners[k]] = safeAdd(ownersbal[owners[k]], share);
      }
    }
  }

  // PayDividends individuals to msg.sender
  function PayDividends() external {
    require (address(this).balance > 0);

    uint256 N = (block.timestamp - start) / period; // current - 1
    uint256 date = N * period - 1;

    if (dividends[N] == 0) {
      dividends[N] = address(this).balance;
    }
    
    if (!AlreadyReceived[N][msg.sender]) {      
      uint share = safeMul(balanceOf(msg.sender, date), multiplier);
      share = safeDiv(safeMul(share, 100), totalSupply_); // calc the percentage of the totalSupply_ (from 100%)

      share = safePerc(dividends[N], share);
      share = safeDiv(share, safeDiv(multiplier, 100));  // safeDiv(multiplier, 100) - convert to hundredths
        
      ownersbal[msg.sender] = safeAdd(ownersbal[msg.sender], share);
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