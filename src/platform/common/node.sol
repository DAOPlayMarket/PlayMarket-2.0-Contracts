pragma solidity ^0.4.24;

import '../../common/Agent.sol';
import '../../common/SafeMath.sol';
import '../storage/nodeStorageI.sol';

/**
 * @title Node contract - basic contract for working with nodes
 */
contract Node is Agent, SafeMath {

  NodeStorageI public NodeStorage;

  event setStorageContractEvent(address _contract);

  function setStorageContract(address _contract) external onlyOwner {
    NodeStorage = NodeStorageI(_contract);
    emit setStorageContractEvent(_contract);
  }

  /**
   * @dev 
   * @param _adrNode The address of the node through which the transaction passes
   * @param _value application fee
   */
  function buyApp(address _adrNode, uint _value) public onlyAgent {
    //require(nodes[_adrNode].confirmation == true);    
  }

  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _deposit deposit
   * @param _ip ip
   * @param _coordinates coordinates
   */
  function registrationNode(address _adrNode, string _hash, string _hashTag, uint256 _deposit, string _ip, string _coordinates) external onlyAgent {
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _ip ip
   * @param _coordinates coordinates
   */
  function changeInfoNode(address _adrNode, string _hash, string _hashTag, string _ip, string _coordinates) external onlyAgent {
    //assert(nodes[_adrNode].isSet);
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @return amount deposit
   */
  function getDeposit(address _adrNode) public constant onlyAgent returns (uint256) {
    //return nodes[_adrNode].deposit;
  }

  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @return amount revenue
   */
  function getRevenue(address _adrNode) external constant onlyAgent returns (uint256) {
    //return nodeRevenue[_adrNode];
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value deposit amount
   */
  function makeDeposit(address _adrNode, uint256 _value) public onlyAgent {
    require(_value > 0);    
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value deposit amount
   */
  function takeDeposit(address _adrNode, uint256 _value) public onlyAgent {
    //require(nodes[_adrNode].deposit >= _value);    
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   */
  function collectNode(address _adrNode) public onlyAgent{
    
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value value
   */
  function confirmationNode(address _adrNode, bool _value) public onlyAgent{
    //assert(nodes[_adrNode].isSet);    
  }
}
