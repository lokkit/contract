var Rentable = artifacts.require("./Rentable.sol");

module.exports = function(deployer) {
  deployer.deploy(Rentable, 'Locker 1', 'Top',   10000000000000000, 3000000000000000000);
  deployer.deploy(Rentable, 'Locker 2', 'Middle', 5000000000000000, 2000000000000000000);
  deployer.deploy(Rentable, 'Locker 3', 'Bottom', 3500000000000000, 1250000000000000000);
};
