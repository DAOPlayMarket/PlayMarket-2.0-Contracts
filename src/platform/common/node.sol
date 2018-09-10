pragma solidity ^0.4.24;

import '/src/common/Agent.sol';
import '/src/common/SafeMath.sol';

/**
 * @title Node contract - basic contract for working with nodes
 */
contract Node is Agent, SafeMath {

  struct _Node {
    bool confirmation;
    string hash;
    string hashTag;
    uint256 deposit;
    string ip;
    string coordinates;
    bool isSet;
  }
  
  mapping (address => uint256) public nodeRevenue;
  mapping (address => _Node) public nodes;
	
  /**
   * @dev 
   * @param _adrNode The address of the node through which the transaction passes
   * @param _value application fee
   */
  function buyApp(address _adrNode, uint _value) public onlyAgent {
    require(nodes[_adrNode].confirmation == true);
    nodeRevenue[_adrNode] = safeAdd(nodeRevenue[_adrNode], _value);
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
  function registrationNode(address _adrNode, string _hash, string _hashTag, uint256 _deposit, string _ip, string _coordinates) public onlyAgent {
    nodes[_adrNode] = _Node({
      confirmation: false,
      hash: _hash,
      hashTag: _hashTag,
      deposit: _deposit,
      ip: _ip,
      coordinates: _coordinates,
      isSet: true
    });
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _ip ip
   * @param _coordinates coordinates
   */
  function changeInfoNode(address _adrNode, string _hash, string _hashTag, string _ip, string _coordinates) public onlyAgent {
    assert(nodes[_adrNode].isSet);
    nodes[_adrNode].hash = _hash;
    nodes[_adrNode].hashTag = _hashTag;
    nodes[_adrNode].ip = _ip;
    nodes[_adrNode].coordinates = _coordinates;
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @return amount deposit
   */
  function getDeposit(address _adrNode) public constant onlyAgent returns (uint256) {
    return nodes[_adrNode].deposit;
  }

  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @return amount revenue
   */
  function getRevenue(address _adrNode) external constant onlyAgent returns (uint256) {
    return nodeRevenue[_adrNode];
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value deposit amount
   */
  function makeDeposit(address _adrNode, uint256 _value) public onlyAgent {
    require(_value > 0);
    nodes[_adrNode].deposit = safeAdd(nodes[_adrNode].deposit, _value);
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value deposit amount
   */
  function takeDeposit(address _adrNode, uint256 _value) public onlyAgent {
    require(nodes[_adrNode].deposit >= _value);
    nodes[_adrNode].deposit = safeSub(nodes[_adrNode].deposit, _value);
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   */
  function collectNode(address _adrNode) public onlyAgent{
    nodeRevenue[_adrNode] = 0;
  }
  
  /**
   * @dev 
   * @param _adrNode The address of the node 
   * @param _value value
   */
  function confirmationNode(address _adrNode, bool _value) public onlyAgent{
    assert(nodes[_adrNode].isSet);
    nodes[_adrNode].confirmation = _value;
  }
}
