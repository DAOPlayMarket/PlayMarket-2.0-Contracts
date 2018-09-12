pragma solidity ^0.4.24;

import '../common/Agent.sol';

contract VersionPM is Agent {

    struct Version {
        // main contract address
        address mainAddress;
        // version PM 2.0
        bytes32 version;
        //support end time (0 - indefinite)
        uint256 timestamp;
    }
    
    Version[] public versions;
    
    event addVersionLog(address mainAddress, bytes32 version, uint256 timestamp, uint256 i);
    event changeVersionLog(address mainAddress, bytes32 version, uint256 timestamp, uint256 i);
    event lastVersionLog(bytes32 version, uint256 i);
    
    constructor(address _mainAddress, bytes32 _version, uint256 _timestamp) public {
        require(_mainAddress != address(0));
        versions.push(Version( _mainAddress, _version, _timestamp));
        emit addVersionLog(_mainAddress, _version, _timestamp, versions.length);
        emit lastVersionLog(_version, versions.length);
    }

    function addVersion(address _mainAddress, bytes32 _version, uint256 _timestamp) public onlyAgent {
        require(_mainAddress != address(0));
        versions.push(Version( _mainAddress, _version, _timestamp));
        emit addVersionLog(_mainAddress, _version, _timestamp, versions.length);
        emit lastVersionLog(_version, versions.length);
    }

    function changeVersion(address _mainAddress, bytes32 _version, uint256 _timestamp, uint256 _i) public onlyAgent {
        require(_mainAddress != address(0));
        versions[_i] = (Version( _mainAddress, _version, _timestamp));
        emit changeVersionLog(_mainAddress, _version, _timestamp, _i);
    }
    
    function getLastVersion() public view returns(address, bytes32, uint256, uint256){
        for(uint i = versions.length-1; i >0; i--) {
            if(versions[i].timestamp == 0 || versions[i].timestamp> block.timestamp){
                return (versions[i].mainAddress, versions[i].version, versions[i].timestamp, i);
            }
        }
        return (versions[0].mainAddress, versions[0].version, versions[0].timestamp, i);
    }
    
    function getVersion(bytes32 _version) public view returns(address, bytes32, uint256, uint256){
        if(versions[0].version == _version) {
             return (versions[0].mainAddress, versions[0].version, versions[0].timestamp, i);
        }
        for(uint i = versions.length-1; i >0; i--) {
            if(versions[i].version == _version) {
                return (versions[i].mainAddress, versions[i].version, versions[i].timestamp, i);
            }
        }
    }
}