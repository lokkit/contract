var Rentable = artifacts.require("./Rentable.sol");

contract('Rentable', function (accounts) {
  // vars to keep track of rents on a single rentable
  var globalStart = Math.round(+new Date() / 1000);

  it("rent with exact money", function () {
    var contract;
    var start = globalStart;
    var end = start + 120;
    return Rentable.deployed().then(function (instance) {
      contract = instance;
      return instance.costInWei.call(start, end);
    }).then(function (costInWei) {
      return contract.rent(start, end, { from: accounts[0], value: costInWei });
    }).then(function () {
      return contract.myPendingRefund.call();
    }).then(function (refund) {
      assert.equal(refund.valueOf(), 0);
    });
  });

  it("rent with refund deposit", function () {
    var contract, deposit;
    var start = globalStart + 121;
    var end = start + 1;
    return Rentable.deployed().then(function (instance) {
      contract = instance;
      return contract.costInWei.call(start, end);
    }).then(function (costInWei) {
      return contract.rent(start, end, { from: accounts[1], value: costInWei });
    }).then(function () {
      return contract.deposit.call();
    }).then(function (depo) {
      deposit = depo;
      return contract.refundReservationDeposit(start, end, { from: accounts[0] }); // only owner can refund deposit
    }).then(function () {
      return contract.myPendingRefund.call({ from: accounts[1] });
    }).then(function (pendingRefund) {
      assert.equal(deposit.valueOf(), pendingRefund.valueOf());
      var oldMoney = web3.eth.getBalance(contract.address);
      contract.withdrawRefundedDeposits({ from: accounts[1] }).then(function () {
        var newMoney = web3.eth.getBalance(contract.address);
        assert.equal(oldMoney.valueOf(), newMoney.add(deposit).valueOf(), "check if deposit has been returned sucessfully.");
      });
    });
  });

  it("rent with too much money", function () {
    var contract, costInWei;
    var start = globalStart + 123;
    var end = start + 120;
    return Rentable.deployed().then(function (instance) {
      contract = instance;
      return instance.costInWei.call(start, end);
    }).then(function (cost) {
      costInWei = cost.valueOf();
      return contract.rent(start, end, { from: accounts[0], value: costInWei * 2 });
    }).then(function () {
      return contract.myPendingRefund.call({ from: accounts[0] });
    }).then(function (refund) {
      assert.equal(refund.valueOf(), costInWei); // I sent costInWei*2, so I expect to get costInWei refunded.
    });
  });

  it("rent with too little money", function () {
    var contract;
    var start = globalStart + 244;
    var end = start + 120;
    return Rentable.deployed().then(function (instance) {
      contract = instance;
      return contract.costInWei.call(start, end);
    }).then(function (costInWei) {
      return contract.rent(start, end, { from: accounts[1], value: costInWei - 1 });
    }).then(function () {
      assert.equal(false, true);
    }).catch(function () {
      assert.equal(true, true);// todo: how to pass a test?
    });
  });
});