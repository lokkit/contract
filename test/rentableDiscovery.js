var Rentable = artifacts.require("./RentableDiscovery.sol");

contract('RentableDiscovery', function(accounts) {
  it("can create contract using factory method", function() {
    var description = "some desctiption";
    var location = "some location";
    var costPerSecond = 115;
    var deposit = 1000;
    return Rentable.deployed().then(function(instance) {
      return instance.registerNew(description, location, costPerSecond, deposit, {from: accounts[0]});
    }).then(function(rentable) {
      var rentableCostPerSecond = rentable.costPerSecond.call()
      assert.equal(costPerSecond, rentableCostPerSecond, "pricePerTime is not 7");
    });
  });
});
