pragma solidity ^0.4.24;

import '/src/common/SafeMath.sol';
import '/src/common/Agent.sol';
import '/src/platform/common/appI.sol';

/**
 * @title Application contract - basic contract for working with applications
 */
contract Application is ApplicationI, Agent, SafeMath {
	
  struct _Application {
    address developer;
    string hash;
    string hashTag;
    uint price;         // price in virtual units (PMC)
    uint kind;          // default 0 - android application
    bool publish;       // the developer decides whether to publish or not
    bool confirmation;  // decides platform, after verification (Nodes and mobile application only display approved and published applications)
  }

  struct _ApplicationICO {
    string hash;
    string hashTag;
  }

  _Application[] public applications;
  mapping (uint => _ApplicationICO) public applicationsICO;
  mapping (address => mapping (uint => mapping (uint =>  bool))) public purchases;  
  
  /**
   * @dev 
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _publish publish
   * @param _price price App
   * @param _dev Developer address
   * @return number of current applications
   */
  function registrationApplication(string _hash, string _hashTag, bool _publish, uint256 _price, address _dev, uint _kind) external onlyAgent returns (uint256) {
    applications.push(_Application({
      developer: _dev,
      hash: _hash,
      hashTag: _hashTag,
      price: _price,
      kind: _kind,
      publish: _publish,
      confirmation: false
    }));
    return applications.length-1;
  }
  
  /**
   * @dev 
   * @param _app ID application
   * @param _status true/false
   */
  function confirmationApplication(uint _app, bool _status) public onlyAgent {
    applications[_app].confirmation = _status;
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function registrationApplicationICO(uint _app, string _hash, string _hashTag, address _dev) external onlyAgent {
    require(checkDeveloper(_app,_dev));
    applicationsICO[_app].hash =_hash;
    applicationsICO[_app].hashTag =_hashTag;
  }
	
   /**
   * @dev 
   * @param _app ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function changeHash(uint _app,  string _hash, string _hashTag, address _dev) external onlyAgent {  
    require(checkDeveloper(_app,_dev));
    applications[_app].hash =_hash;
    applications[_app].hashTag =_hashTag;
    applications[_app].confirmation = false;
  }
  
  /**
   * @dev 
   * @param _app ID application
   * @param _publish publish
   * @param _dev Developer address
   */
  function changePublish(uint _app, bool _publish, address _dev) public onlyAgent {
    require(checkDeveloper(_app,_dev));
    applications[_app].publish =_publish;
  }
  
  /**
   * @dev 
   * @param _app ID application
   * @param _price new price application
   * @param _dev Developer address
   */
  function changePrice(uint _app, uint256 _price, address _dev) public onlyAgent {
    require(checkDeveloper(_app,_dev));
    applications[_app].price =_price;
  }
  
  /**
   * @dev 
   * @param _app ID application
   * @param _hash hash
   * @param _hashTag hashTag
   * @param _dev Developer address
   */
  function changeIcoHash(uint _app, string _hash, string _hashTag, address _dev) external onlyAgent {
    require(checkDeveloper(_app,_dev));
    applicationsICO[_app].hash =_hash;
    applicationsICO[_app].hashTag =_hashTag;
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _dev Developer address
   * @return boolean
   */  
  function checkDeveloper(uint _app, address _dev) private constant returns (bool success) {
      require(applications[_app].developer == _dev);
      return true;
  }

  /**
   * @dev 
   * @param _app ID application
   * @return developer address
   */  
  function getDeveloper(uint _app) public onlyAgent constant  returns (address) {
    return applications[_app].developer;
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _price price application
   * @return boolean
   */  
  function checkSum(uint _app, uint256 _price) private constant returns (bool success) {
      require(applications[_app].price == _price);
      return true;
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _user user address
   * @param _price price application in virtual units (PMC)
   */  
  function buyApp(uint _app, address _user, uint _price) public onlyAgent {
    require(checkSum(_app,_price));
    purchases[_user][_app][0] = true;    
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _user user address
   * @param _obj ID object in application
   */  
  function buyObject(uint _app, address _user, uint _obj) public onlyAgent {
    purchases[_user][_app][_obj] = true;    
  }

  /**
   * @dev 
   * @param _app ID application
   * @param _user user address
   * @return boolean
   */    
  function checkBuy(uint _app, address _user) public constant returns (bool success) {
      return purchases[_user][_app][0];
  }
}