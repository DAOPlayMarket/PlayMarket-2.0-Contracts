pragma solidity ^0.4.24;

import '../common/Agent.sol';

contract VersionPM is Agent {

    struct Version {
        // main contract address
        address mainAddress;
        // version PM 2.0
        bytes32 version;
        //support end time (0 - indefinite)
        uint256 timeEnd;
    }
    
    Version[] public versions;
    
    event addVersionLog(address mainAddress, bytes32 version, uint256 timeEnd, uint256 i);
    event changeVersionLog(address mainAddress, bytes32 version, uint256 timeEnd, uint256 i);
    event lastVersionLog(bytes32 version, uint256 i);
    
    constructor(address _mainAddress, bytes32 _version, uint256 _timeEnd) public {
        require(_mainAddress != address(0));
        versions.push(Version( _mainAddress, _version, _timeEnd));
        emit addVersionLog(_mainAddress, _version, _timeEnd, versions.length);
        emit lastVersionLog(_version, versions.length);
    }

    function addVersion(address _mainAddress, bytes32 _version, uint256 _timeEnd) external onlyAgent {
        require(_mainAddress != address(0));
        versions.push(Version( _mainAddress, _version, _timeEnd));
        emit addVersionLog(_mainAddress, _version, _timeEnd, versions.length);
        emit lastVersionLog(_version, versions.length);
    }

    function changeVersion(address _mainAddress, bytes32 _version, uint256 _timeEnd, uint256 _i) external onlyAgent {
        require(_mainAddress != address(0));
        versions[_i] = (Version( _mainAddress, _version, _timeEnd));
        emit changeVersionLog(_mainAddress, _version, _timeEnd, _i);
    }
    
    function getLastVersion() external view returns(address, bytes32, uint256, uint256){
        for(uint i = versions.length-1; i > 0; i--) {
            if(versions[i].timeEnd == 0 || versions[i].timeEnd > block.timestamp) {
                return (versions[i].mainAddress, versions[i].version, versions[i].timeEnd, i);
            }
        }
        return (versions[0].mainAddress, versions[0].version, versions[0].timeEnd, 0);
    }
    
    function getVersion(bytes32 _version) external view returns(address, bytes32, uint256, uint256){
        for(uint i = versions.length-1; i > 0; i--) {
            if(versions[i].version == _version) {
                return (versions[i].mainAddress, versions[i].version, versions[i].timeEnd, i);
            }
        }
        if(versions[0].version == _version) {
            return (versions[0].mainAddress, versions[0].version, versions[0].timeEnd, 0);
        }
    }
}