var Rentable = artifacts.require("./Rentable.sol");
var RentableDiscovery = artifacts.require("./RentableDiscovery.sol");

module.exports = function(deployer) {
  deployer.deploy(Rentable, 'leDescription', 'leLocation', 7, 500);
  deployer.deploy(RentableDiscovery);
};
