var Rentable = artifacts.require("./Rentable.sol");
var RentableDiscovery = artifacts.require("./RentableDiscovery.sol");

module.exports = function(deployer) {
  deployer.deploy(Rentable, 'Locker 1', 'Top', 5, 1000);
  deployer.deploy(Rentable, 'Locker 2', 'Middle', 10, 500);
  deployer.deploy(Rentable, 'Locker 3', 'Bottom', 15, 200);
  deployer.link(Rentable, RentableDiscovery);
  deployer.deploy(RentableDiscovery);
};
