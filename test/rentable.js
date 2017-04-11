var Rentable = artifacts.require("./Rentable.sol");

contract('Rentable', function(accounts) {
  it("pricePerTime contract should be 7", function() {
    return Rentable.deployed().then(function(instance) {
      return instance.getPricePerTime.call(accounts[0]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 7, "pricePerTime is not 7");
    });
  });
  it("descrtiption of contract should be 'leDescription'", function() {
    return Rentable.deployed().then(function(instance) {
      return instance.getDescription.call(accounts[0]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), "leDescription", "description is not 'leDescription'");
    });
  });
  it("location of contract should be 'leLocation'", function() {
    return Rentable.deployed().then(function(instance) {
      return instance.getLocation.call(accounts[0]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), "leLocation", "location is not 'leLocation'");
    });
  });
  it("deposit of contract should be 500", function() {
    return Rentable.deployed().then(function(instance) {
      return instance.getDeposit.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 500, "deposit is not 500");
    });
  });
  it("reserve (rent) the rentable", function() {
    var contract;
    var start = Math.round(+new Date()/1000); 
    var end = Math.round(+new Date()/1000) + 120;

    return Rentable.deployed().then(function(instance) {
      contract = instance;
      return instance.rent(start, end, {from: accounts[0]});
    }).then(function() {
      return contract.allReservations.call();
    }).then(function(ret) {
      console.log("got: " + typeof(ret.valueOf()));
      console.log("got: " + typeof(ret));
      console.log(ret.valueOf());
      // TODO: try to implement assert
      //assert.deepEqual(ret.valueOf(), [start, end, 1], "reservation is not correct");
    });
  });
});
