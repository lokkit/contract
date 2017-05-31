var Rentable = artifacts.require("./Rentable.sol");

contract('Rentable', function (accounts) {
  // vars to keep track of rents on a single rentable
  var globalStart = Math.round(+new Date() / 1000);
  globalStart += 1000;

  it("costPerSecond contract should be 7", function () {
    return Rentable.deployed().then(function (instance) {
      return instance.costPerSecond();
    }).then(function (ret) {
      assert.equal(ret.valueOf(), 7, "costPerSecond is not 7");
    });
  });

  it("descrtiption of contract should be 'leDescription'", function () {
    return Rentable.deployed().then(function (instance) {
      return instance.description();
    }).then(function (ret) {
      assert.equal(ret.valueOf(), "leDescription", "description is not 'leDescription'");
    });
  });

  it("location of contract should be 'leLocation'", function () {
    return Rentable.deployed().then(function (instance) {
      return instance.location();
    }).then(function (ret) {
      assert.equal(ret.valueOf(), "leLocation", "location is not 'leLocation'");
    });
  });

  it("deposit of contract should be 500", function () {
    return Rentable.deployed().then(function (instance) {
      return instance.deposit();
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
      return instance.costInWei(start, end);
    }).then(function (costInWei) {
      return contract.rent(start, end, { from: accounts[0], value: costInWei.valueOf() });
    }).then(function () {
      return contract.allReservations();
    }).then(function (ret) {
      // ret is a string like '123123,12312312,1'
      assert.equal(ret, [start, end, 1].toString(), "reservation is not correct");
    });
  });

  it("rent and check if reserved between", function () {
    var contract;
    var start = globalStart + 122;
    var end = start + 120;
    return Rentable.deployed().then(function (instance) {
      contract = instance;
      return instance.costInWei(start, end);
    }).then(function (costInWei) {
      return contract.rent(start, end, { from: accounts[0], value: costInWei.valueOf() });
    }).then(function () {

      // Test
      var s = start;
      var e = end;
      console.log('Reservation from ' + s + ' to ' + e)
      console.log('Check if reserved between ' + s + ' and ' + e + '\t+----+')
      contract.reservedBetween.call(s, e).then(function (ret) {
        assert(ret, 'reservedBetween should return true to indicate that there is a reservation');
        console.log('Check if reserved between ' + s + ' and ' + e + '\t+----+' + ' -> success')

        // Test
        s = start-5
        e = start+5
        console.log('Check if reserved between ' + s + ' and ' + e + '\t--|->  |')
        return contract.reservedBetween.call(s, e)
      }).then(function (ret) {
        assert(ret, 'reservedBetween should return true to indicate that there is a reservation');
        console.log('Check if reserved between ' + s + ' and ' + e + '\t--|->  |' + ' -> success')

        // Test
        s = end-5
        e = end+5
        console.log('Check if reserved between ' + s + ' and ' + e + '\t|  --|-> ')
        return contract.reservedBetween.call(s, e)
      }).then(function (ret) {
        assert(ret, 'reservedBetween should return true to indicate that there is a reservation');
        console.log('Check if reserved between ' + s + ' and ' + e + '\t|  --|-> ' + ' -> success')

        // Test
        s = start-5
        e = end+5
        console.log('Check if reserved between ' + s + ' and ' + e + '\t--| |--> ')
        return contract.reservedBetween.call(s, e)
      }).then(function (ret) {
        assert(ret, 'reservedBetween should return true to indicate that there is a reservation');
        console.log('Check if reserved between ' + s + ' and ' + e + '\t--| |--> ' + ' -> success')

        // Test: check for no collition
        s = start-5
        e = start-1
        console.log('Check if reserved between ' + s + ' and ' + e + '\t--->|   |')
        return contract.reservedBetween.call(s, e);
      }).then(function (ret) {
        console.log('hasdhfahsdfhasdhfh: ' + ret)
        assert(!ret, 'reservedBetween should return false to indicate that there is no reservation');
        console.log('Check if reserved between ' + s + ' and ' + e + '\t--->|   |' + ' -> success')

        // Test
        s = end+1
        e = end+5
        console.log('Check if reserved between ' + s + ' and ' + e + '\t|   |--->')
        return contract.reservedBetween.call(s, e)
      }).then(function (ret) {
        assert(!ret, 'reservedBetween should return false to indicate that there is no reservation');
        console.log('Check if reserved between ' + s + ' and ' + e + '\t|   |--->' + ' -> success')
      })
    });
  });

});
