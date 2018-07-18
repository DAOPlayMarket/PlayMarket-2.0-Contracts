
# PlayMarket 2.0

![PlayMarket 2.0](https://github.com/CryptonStudio/PlayMarket-2.0-App/blob/master/docs/photo/pm_logo.png)

DAO PlayMarket 2.0 is a decentralized Android App Store that accepts payments in cryptocurrency and is combined with an ICO platform for developers.


Personal freedom is impossible without economic security and independence. Therefore, we created an open, censorship-resistant marketplace using blockchain and smart contracts.


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
