pragma solidity ^0.4.8;

import "contracts/Rentable.sol";

contract RentableDiscovery {

  Rentable[] public rentables;
  
  event OnRegister(Rentable rentable);
  event OnUnregister(Rentable rentable);

  function RentableDiscovery() {
    rentables.length = 0;
  }
  
  // creates a new rentable and registers it in the discovery
  function registerNew(string pdescription, string plocation, uint ppricePerTime, uint pdeposit) returns (address) {
    Rentable r = new Rentable(pdescription, plocation, ppricePerTime, pdeposit);
    r.transferOwnership(msg.sender);
	rentables.push(r);
	OnRegister(r);
	return r;
  }
  
  // returns whether or not the rentable is added in the discovery
  function registerExisting(Rentable rentable) returns (bool) {
      if (exists(rentable)){
          return false;
      }
      rentables.push(rentable);
      OnRegister(rentable);
      return true;
  }
  
  // removes the rentable at a given index.
  function removeAt(uint index) private {
      if(index >= rentables.length){
          return;
      }
      if (rentables[index].owner() != msg.sender){
          throw; // only owner can unregister the rentable from the discovery
      }
      for (uint k = index; k < rentables.length-1; k++) {
        rentables[k] = rentables[k+1];
      }
      delete rentables[rentables.length-1];
      rentables.length--;
  }
  
  // removes a rentable from the discovery
  function unregister(Rentable rentable) {
    for (uint i = 0; i < rentables.length; i++) {
        if (rentables[i] == rentable) {
            removeAt(i);
            OnUnregister(rentable);
            return;
        }
    }
  }
  
  // returns the indx of the rentable in the internal array.
  function indexOf(Rentable rentable) private constant returns (bool found, uint index) {
    for (uint i = 0; i < rentables.length; i++) {
        if (rentables[i] == rentable) {
            return (true, i);
        }
    }
    return (false, 0);
  }
  
  // return whether a rentable eixsts in the discovery or not.
  function exists(Rentable rentable) constant returns (bool) {
      var (found, index) = indexOf(rentable);
      return found;
  }
  
  // returns all rentables that are in the discovery
  function all() constant returns (Rentable[]) {
      return rentables;
  }
  
}
