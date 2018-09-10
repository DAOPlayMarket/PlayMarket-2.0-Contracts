pragma solidity ^0.4.24;

/**
 * @title DAO Playmarket 2.0 Node contract interface 
 */
interface NodeI {	
  /**
   * @dev 
   * @param _adrNode The address of the node through which the transaction passes
   * @param _value application fee
   */
  function buyApp(address _adrNode, uint _value) external;

  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _deposit deposit
   * @param _ip ip
   * @param _coordinates coordinates
   */
  function registrationNode(address _adrNode, string _hash, string _hashTag, uint256 _deposit, string _ip, string _coordinates) external;
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _ip ip
   * @param _coordinates coordinates
   */
  function changeInfoNode(address _adrNode, string _hash, string _hashTag, string _ip, string _coordinates) external;
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @return amount deposit
   */
  function getDeposit(address _adrNode) external constant returns (uint256);
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @return amount revenue
   */
  function getRevenue(address _adrNode) external constant returns (uint256);

  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value deposit amount
   */
  function makeDeposit(address _adrNode, uint256 _value) external;
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value deposit amount
   */
  function takeDeposit(address _adrNode, uint256 _value) external;
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   */
  function collectNode(address _adrNode) external;
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value value
   */
  function confirmationNode(address _adrNode, bool _value) external;
}
