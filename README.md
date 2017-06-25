# Smart Contracts for lokkit

On a fresh blockchain the following contracts can be deployed using truffe
```
Rentable 1: 0x58b5e51386b46d018dcd0a3db91a6c69fed20ea8
Rentable 2: 0xde93b2965af6a49161f597604c600af9ea07883a
Rentable 3: 0x75105e510adf9fa0b1b1a5d35f9d8594ad36d8ed
```

### Install required packages
```
npm install -g truffle

# for fast testing
npm install -g ethereumjs-testrpc
```

### Start testrpc
This will start a test node (listening on localhost:8545).
```
testrpc
```

### Build contracts
```
truffle build
```

### Run tests
```
truffle test
```

### Deploy contracts to localhost
```
truffle deploy
```
If no account address is specified in `truffle.js` then it will take the first account.
You need to make sure, that this account is unlocked before deploying with truffle.

### Interact with the contract
Here is an example how you can create a new contract instance
and then use it to call any functions on it.
```
truffle console
truffle(development)> Rentable.new('mydesci', 'myloco', 4, 300).then(function(instance) {console.log(instance.address)});
0xe53bd1ed244c8bde94a8853b3576eba5df640b80
truffle(development)> c = Rentable.at('0xe53bd1ed244c8bde94a8853b3576eba5df640b80');
truffle(development)> c.getDescription.call().then(function(ret){console.log(ret);})
```
