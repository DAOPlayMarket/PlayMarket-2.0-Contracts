pragma solidity ^0.4.24;

import './common/SafeMath.sol';
import './common/AgentStorage.sol';
import './common/Rate.sol';
import './common/RateI.sol';
import './exchange/PEX.sol';
import './exchange/PEXI.sol';
import './fund/PMFund.sol';
import './fund/PMFundI.sol';
import './DAO/DAO.sol';
import './DAO/DAORepository.sol';
import './DAO/DAORepositoryI.sol';
import './platform/PlayMarket.sol';
import './platform/ICO/ICOList.sol';
import './platform/ICO/ICOListI.sol';
import './platform/ICO/CrowdSaleI.sol';
import './platform/ICO/AppTokenBuild.sol';
import './platform/ICO/CrowdSaleBuild.sol';
import './platform/storage/appStorage.sol';
import './platform/storage/appStorageI.sol';
import './platform/storage/devStorage.sol';
import './platform/storage/devStorageI.sol';
import './platform/storage/logStorage.sol';
import './platform/storage/logStorageI.sol';
import './platform/storage/nodeStorage.sol';
import './platform/storage/nodeStorageI.sol';

contract deploy {
    address _PMT = address(0xC1322D8aE3B0e2E437e0AE36388D0CFD2C02f1c9);
    address _RateContract;
    address _CrowdSaleBuild;
    address _AppTokenBuild;
    address _appStorage;
    address _devStorage;
    address _logStorage;
    address _nodeStorage;
    address _DAO;
    address _DAORepository;
    address _PMFund;
    address _PEX;
    address _ICOList;
    address _PlayMarket;

    address _feeAccount = address(0x6551d4eb508c59002cb486e1ac2d341262d5bfe2);
    uint _feeMake = 1;
    uint _feeTake = 1;

    uint32  public Store  = 1;
    address public Agent  = address(0x6551d4eb508c59002cb486e1ac2d341262d5bfe2);
    uint ID = 1;

    string _name            = "DAO PlayMarket 2.0 TOKEN"; 
    string _symbol          = "PMTEST";    
    address _multisigWallet = address(0x6551d4eb508c59002cb486e1ac2d341262d5bfe2);
    uint _decimals          = 4;

    event step1done();
    function step1 () public {
      _RateContract = new RateContract();
      _AppTokenBuild = new AppTokenBuild();
      _CrowdSaleBuild = new CrowdSaleBuild(_RateContract);
      emit step1done();
    }

    event step2done();
    function step2 () public {
      _appStorage = new AppStorage();
      _devStorage = new DevStorage();
      _logStorage = new LogStorage();
      _nodeStorage = new NodeStorage(_PMT);
      emit step2done();
    }

    event step3done();    
    function step3 () public {
      _PEX = new PEX(_feeAccount, _feeMake, _feeTake);
      _DAORepository = new DAORepository(_PMT);
      emit step3done();
    }

    event step4done();
    function step4 () public {
      _PMFund = new PMFund(_DAORepository);
      _ICOList = new ICOList(_PMFund, _PEX);
      ICOListI(_ICOList).setAppTokenContract(ID, _AppTokenBuild);
      ICOListI(_ICOList).setCrowdSaleContract(ID, _CrowdSaleBuild);
      emit step4done();
    }

    event step5done();
    function step5 () public {
      _PlayMarket = new PlayMarket(_appStorage, _devStorage, _nodeStorage, _logStorage, _ICOList);
      AppStorageI(_appStorage).updateAgentStorage(_PlayMarket, Store, true);
      DevStorageI(_devStorage).updateAgentStorage(_PlayMarket, Store, true);
      NodeStorageI(_nodeStorage).updateAgentStorage(_PlayMarket, Store, true);
      LogStorageI(_logStorage).updateAgentStorage(_PlayMarket, Store, true);
      ICOListI(_ICOList).updateAgentStorage(_PlayMarket, Store, true);
      emit step5done();
    }
}