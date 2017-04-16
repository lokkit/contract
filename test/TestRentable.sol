pragma solidity ^0.4.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Rentable.sol";

contract TestRentable {

  function testInitialPricePerTimeOfDeployedContract() {
    Rentable c = Rentable(DeployedAddresses.Rentable());

    uint expected = 7;
    Assert.equal(c.pricePerTime(), expected, "PricePerTime should initially be 7");
  }

}
