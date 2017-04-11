var Rentable = artifacts.require("./Rentable.sol");

module.exports = function(deployer) {
  deployer.deploy(Rentable, 'leDescription', 'leLocation', 7, 500);
};
