pragma solidity ^0.4.21;

/**
 * @title Feedback Rating 
 * @dev 
 */
contract FeedbackRating {
  
  event newRating(address voter , uint idApp, uint vote, string description, bytes32 txIndex);
  /**
   * @dev 
   * @param idApp voice application identifier
   * @param vote voter rating
   * @param description voted opinion
   * @param txIndex identifier for the answer
   */
  function pushFeedbackRating(uint idApp, uint vote, string description, bytes32 txIndex) public {
    require( vote > 0 && vote <= 5);
    emit newRating(msg.sender, idApp, vote, description, txIndex);
  }
}