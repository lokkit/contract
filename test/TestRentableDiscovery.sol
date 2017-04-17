pragma solidity ^0.4.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RentableDiscovery.sol";

contract TestRentableDiscovery {

  function testInitialPricePerTimeOfDeployedContract() {
    RentableDiscovery c = RentableDiscovery(DeployedAddresses.RentableDiscovery());
	address[] rentables = c.all();

    Assert.equal(rentables, new address[], "'all' rentables should yield 0 results.");
  }

}
