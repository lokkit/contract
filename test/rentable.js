var Rentable = artifacts.require("./Rentable.sol");

contract('Rentable', function (accounts) {
  // vars to keep track of rents on a single rentable
  var globalStart = Math.round(+new Date() / 1000);

  it("pricePerTime contract should be 7", function () {
    return Rentable.deployed().then(function (instance) {
      return instance.costPerSecond.call();
    }).then(function (ret) {
      assert.equal(ret.valueOf(), 7, "pricePerTime is not 7");
    });
  });

  it("descrtiption of contract should be 'leDescription'", function () {
    return Rentable.deployed().then(function (instance) {
      return instance.description.call();
    }).then(function (ret) {
      assert.equal(ret.valueOf(), "leDescription", "description is not 'leDescription'");
    });
  });

  it("location of contract should be 'leLocation'", function () {
    return Rentable.deployed().then(function (instance) {
      return instance.location.call();
    }).then(function (ret) {
      assert.equal(ret.valueOf(), "leLocation", "location is not 'leLocation'");
    });
  });

  it("deposit of contract should be 500", function () {
    return Rentable.deployed().then(function (instance) {
      return instance.deposit.call();
    }).then(function (ret) {
      assert.equal(ret.valueOf(), 500, "deposit is not 500");
    });
  });

  it("reserve (rent) the rentable", function () {
    var contract;
    var start = globalStart;
    var end = start + 120;
    return Rentable.deployed().then(function (instance) {
      contract = instance;
      return instance.costInWei.call(start, end);
    }).then(function (costInWei) {
      return contract.rent(start, end, { from: accounts[0], value: costInWei });
    }).then(function () {
      return contract.allReservations.call();
    }).then(function (ret) {
      // ret is a string like '123123,12312312,1'
      assert.equal(ret, [start, end, 1].toString(), "reservation is not correct");
    });
  });
});