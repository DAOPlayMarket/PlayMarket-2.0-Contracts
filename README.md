
# PlayMarket 2.0

![PlayMarket 2.0](https://github.com/CryptonStudio/PlayMarket-2.0-Contracts/blob/master/docs/pm_logo.png)

DAO PlayMarket 2.0 is a decentralized Android App Store that accepts payments in cryptocurrency and is combined with an ICO platform for developers.


Personal freedom is impossible without economic security and independence. Therefore, we created an open, censorship-resistant marketplace using blockchain and smart contracts.

##### Address of the main contract for Rinkeby: 0x857A6198520aFd1B6Cba74a9313A57B6F07743BD, event {fromBlock: 2643525}
##### Interface [abi](https://github.com/CryptonStudio/PlayMarket-2.0-Contracts/blob/master/docs/interface.json)

# Specification
## Methods for the application

### registrationApplication
Registration of the application on the platform. The developer must be registered in the system before calling this method.
#### Parameters
1. String - hash application
2. String - hashtag repository (currently IPFS)
3. Bool - publish the application
4. Uint256 - the cost of the application in WEI

```bash
function registrationApplication(string _hash, string _hashTag, bool _publish, uint256 _price) public;
```
#### Event
registrationApplicationEvent
1. idApp - application identifier in the system
2. hash - hash application
3. hashTag - hashtag repository (currently IPFS)
4. publish - publish the application
5. price - the cost of the application in WEI
6. adrDev - address of the developer who registered the application

```bash
event registrationApplicationEvent(uint idApp, string hash, string hashTag, bool publish, uint256 price, address adrDev);
```

### changeHash
Edit application data.
#### Parameters
1. Uint256 - application identifier in the system
2. String - hash application
3. String - hashtag repository (currently IPFS)

```bash
function changeHash(uint _idApp, string _hash, string _hashTag) public;
```
#### Event
changeHashEvent
1. idApp - application identifier in the system
2. hash - hash application
3. hashTag - hashtag repository (currently IPFS)

```bash
event changeHashEvent(uint idApp, string hash, string hashTag);
```

### changePublish
Change application publishing.
#### Parameters
1. Uint256 - application identifier in the system
2. Bool - publish the application

```bash
function changePublish(uint _idApp, bool _publish) public;
```
#### Event
changePublishEvent
1. idApp - application identifier in the system
2. publish - publish the application

```bash
event changePublishEvent(uint idApp, bool publish);
```

### changePrice
Change the price of the application.
#### Parameters
1. Uint256 - application identifier in the system
2. Uint256 - the cost of the application in WEI

```bash
function changePublish(uint _idApp, bool _publish) public;
```
#### Event
changePriceEvent
1. idApp - application identifier in the system
2. price - the cost of the application in WEI

```bash
event changePriceEvent(uint idApp, uint256 price);
```

### buyApp
Purchase an application.
#### Parameters
1. Uint256 - application identifier in the system
2. Address - the address of the node through which the transaction passed

```bash
 function buyApp(uint _idApp, address _adrNode) public payable;
```
#### Event
buyAppEvent
1. user - the user who made the purchase
2. developer - application Owner
3. idApp - application identifier in the system
4. adrNode - the address of the node through which the transaction passed
4. price - the cost of the application in WEI

```bash
event buyAppEvent(address indexed user, address indexed developer, uint idApp, address indexed adrNode, uint256 price);
```


## Methods for App ICO

### registrationApplicationICO
Adding information about the ICO app. Public information.
#### Parameters
1. Uint256 - application identifier in the system
2. String - hash ICO application
3. String - hashtag ICO repository (currently IPFS)

```bash
function registrationApplicationICO(uint _idApp, string _hash, string _hashTag) public;
```
#### Event
registrationApplicationICOEvent
1. idApp - application identifier in the system
2. hash - hash ICO application
3. hashTag - hashtag ICO repository (currently IPFS)

```bash
event registrationApplicationICOEvent(uint idApp, string hash, string hashTag);
```

### changeIcoHash
Change information about the ICO app. Public Information.
#### Parameters
1. Uint256 - application identifier in the system
2. String - hash ICO application
3. String - hashtag ICO repository (currently IPFS)

```bash
function changeIcoHash(uint _idApp, string _hash, string _hashTag) publicж
```
#### Event
changeIcoHashEvent
1. idApp - application identifier in the system
2. hash - hash ICO application
3. hashTag - hashtag ICO repository (currently IPFS)

```bash
event changeIcoHashEvent(uint idApp, string hash, string hashTag);
```


## Methods for Developer

### registrationDeveloper
Adding information about developer. Public information.
#### Parameters
1. Bytes32 - developer name
2. Bytes32 - additional Information

```bash
function registrationDeveloper(bytes32 _name, bytes32 _info) public;
```
#### Event
registrationDeveloperEvent
1. developer - developer address
2. name - developer name
3. info - additional Information

```bash
event registrationDeveloperEvent(address indexed developer, bytes32 name, bytes32 info);
```

### changeDeveloperInfo
Change information about developer. Public information.
#### Parameters
1. Bytes32 - developer name
2. Bytes32 - additional Information

```bash
function changeDeveloperInfo(bytes32 _name, bytes32 _info) public;
```
#### Event
changeDeveloperInfoEvent
1. developer - developer address
2. name - developer name
3. info - additional Information

```bash
event changeDeveloperInfoEvent(address indexed developer, bytes32 name, bytes32 info);
```


## Methods for working with app reviews

### pushFeedbackRating
Add a new review about the app or respond to a review about the app. The block number is calculated as the time of the new response.
We do not store the data in the contract, but generate the event. This allows you to make feedback as cheap as possible. The event generation costs 8 wei for 1 byte, and data storage in the contract 20,000 wei for 32 bytes
#### Parameters
1. Uint256 - application identifier in the system
2. Uint256 - feedback rating (1 to 5)
3. String - review of the app
4. Bytes32 - TX transactions if this is a response to a specific feedback about the application

```bash
function pushFeedbackRating(uint idApp, uint vote, string description, bytes32 txIndex) public;
```
#### Event
newRating
1. voter - user address who left feedback
2. idApp - application identifier in the system
3. vote - feedback rating (1 to 5)
4. description - review of the app
5. txIndex - TX transactions if this is a response to a specific feedback about the application

```bash
event newRating(address voter , uint idApp, uint vote, string description, bytes32 txIndex);
  
```

## Methods for Node

### registrationNode
Adding information about node. Public information. It is necessary to transfer the primary fee for registration.
#### Parameters
1. String - hash Node
2. String - hashtag repository (currently IPFS)
3. String - host IP Address
4. String - coordinates of the node, to find the nearest location

```bash
function registrationNode( string _hash, string _hashTag, string _ip, string _coordinates) public payable;
```
#### Event
registrationNodeEvent
1. adrNode - node address
2. confirmation - confirmation of registration
3. hash - hash Node
4. hashTag - hashtag repository (currently IPFS)
5. deposit - amount of deposit
6. ip - host IP Address
7. coordinates - coordinates of the node, to find the nearest location

```bash
event registrationNodeEvent(address indexed adrNode, bool confirmation, string hash, string hashTag, uint256 deposit, string ip, string coordinates);
```

### makeDeposit
Send a deposit.
#### Parameters
Without parameters

```bash
function makeDeposit() public payable;
```
#### Event
makeDepositEvent
1. adrNode - node address
2. deposit - amount of deposit

```bash
event makeDepositEvent(address indexed adrNode, uint256 deposit);
```

### takeDeposit
Make a deposit refund
#### Parameters
Without parameters

```bash
function takeDeposit() public;
```
#### Event
takeDepositEvent
1. adrNode - node address
2. deposit - amount of deposit

```bash
event takeDepositEvent(address indexed adrNode, uint256 deposit);
```

### changeInfoNode
Change information about node. Public information.
#### Parameters
1. String - hash Node
2. String - hashtag repository (currently IPFS)
3. String - host IP Address
4. String - coordinates of the node, to find the nearest location

```bash
function changeInfoNode(string _hash, string _hashTag, string _ip, string _coordinates) public;
```
#### Event
changeInfoNodeEvent
1. adrNode - node address
2. hash - hash Node
3. hashTag - hashtag repository (currently IPFS)
4. ip - host IP Address
5. coordinates - coordinates of the node, to find the nearest location

```bash
event changeInfoNodeEvent(address adrNode, string hash, string hashTag, string ip, string coordinates);
```
