pragma solidity ^0.4.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Rentable.sol";

contract TestRentable {

  function testInitialCostPerSecondOfDeployedContract() {
    Rentable c = Rentable(DeployedAddresses.Rentable());

    uint expected = 7;
    Assert.equal(c.costPerSecond(), expected, "CostPerSecond should initially be 7");
  }

}
