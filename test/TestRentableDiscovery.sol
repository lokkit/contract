pragma solidity ^0.4.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
//import "../contracts/Rentable.sol";
import "../contracts/RentableDiscovery.sol";

contract TestRentableDiscovery {

  function testInitialCostPerSecondOfDeployedContract() {
    RentableDiscovery discovery = RentableDiscovery(DeployedAddresses.RentableDiscovery());
	  var rentables = discovery.all();
    var expected = new address[];
    //Assert.equal(rentables, expected, "'all' rentables should yield 0 results.");
  }

}
