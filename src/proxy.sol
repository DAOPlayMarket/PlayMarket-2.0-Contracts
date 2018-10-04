pragma solidity ^0.4.24;
import './common/Agent.sol';
 
contract Proxy is Agent {
    struct Version {
        // DAO PlayMarket 2.0 platform contract address
        address PlayMarket;
        // DAO PlayMarket 2.0 platform ICO contract address
        address ICO;        
        // version PM 2.0
        bytes32 version;
        //support end time (0 - indefinite)
        uint256 endTime;
    }
    
    Version[] public versions;
    
    event addVersionLog(address PlayMarket, address ICO, bytes32 version, uint256 endTime, uint256 i);
    event changeVersionLog(address PlayMarket, address ICO, bytes32 version, uint256 endTime, uint256 i);
    event lastVersionLog(bytes32 version, uint256 i);
    
    constructor(address _PlayMarket, address _ICO, bytes32 _version, uint256 _endTime) public {
        require(_PlayMarket != address(0) && _ICO != address(0));
        versions.push(Version( _PlayMarket, _ICO, _version, _endTime));
        emit addVersionLog(_PlayMarket, _ICO, _version, _endTime, versions.length);
        emit lastVersionLog(_version, versions.length);
    }

     function addVersion(address _PlayMarket, address _ICO, bytes32 _version, uint256 _endTime) public onlyAgent {
        require(_PlayMarket != address(0) && _ICO != address(0));
        versions.push(Version( _PlayMarket, _ICO, _version, _endTime));
        emit addVersionLog(_PlayMarket, _ICO, _version, _endTime, versions.length);
        emit lastVersionLog(_version, versions.length);
    }

     function changeVersion(address _PlayMarket, address _ICO, bytes32 _version, uint256 _endTime, uint256 _i) public onlyAgent {
        require(_PlayMarket != address(0) && _ICO != address(0));
        versions[_i] = (Version( _PlayMarket, _ICO, _version, _endTime));
        emit changeVersionLog(_PlayMarket, _ICO, _version, _endTime, _i);
    }
    
    function getLastVersion() public view returns (address PlayMarket, address ICO, bytes32 version, uint256 endTime, uint256 number){
        for(uint i = versions.length-1; i > 0; i--) {
            if(versions[i].endTime == 0 || versions[i].endTime > block.timestamp){
                return (versions[i].PlayMarket, versions[i].ICO, versions[i].version, versions[i].endTime, i);
            }
        }
        return (versions[0].PlayMarket, versions[0].ICO, versions[0].version, versions[0].endTime, 0);
    }
    
    function getVersion(bytes32 _version) public view returns  (address PlayMarket, address ICO, bytes32 version, uint256 endTime, uint256 number){
        if(versions[0].version == _version) {
             return (versions[0].PlayMarket, versions[0].ICO, versions[0].version, versions[0].endTime, 0);
        }
        for(uint i = versions.length-1; i > 0; i--) {
            if(versions[i].version == _version) {
                return (versions[i].PlayMarket, versions[i].ICO, versions[i].version, versions[i].endTime, i);
            }
        }
    }
}
