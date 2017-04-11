# Smart Contracts for lokkit

### Install required packages
```
npm install -g truffle
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
truffle test
```

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
