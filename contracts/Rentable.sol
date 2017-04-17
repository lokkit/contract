pragma solidity ^0.4.8;

contract Rentable {

  struct Reservation {
    uint start;
    uint end;
    address renter;
  }

  address public owner;
  string public description;
  string public location;
  uint public pricePerTime;
  uint public deposit;
  bool public locked = false;

  Reservation[] reservations;
  event OnReserve(uint start, uint end, address renter);

  function Rentable(string pdescription, string plocation, uint ppricePerTime, uint pdeposit) public {
    owner = msg.sender;
    description = pdescription;
    location = plocation;
    pricePerTime = ppricePerTime;
    deposit = pdeposit;
    reservations.length = 0;
  }

  modifier ownerOnly {
    if (owner != msg.sender) {
      throw;
    }
    _;
  }

  modifier currentReserverOnly {
    var (isReserved, reservation) = currentReservation();
    if (!isReserved
        || reservation.renter != msg.sender){
      throw;
    }
    _;
  }

  function allReservations() public constant returns (uint[3][]){
    uint[3][] memory data = new uint[3][](reservations.length);
    for (uint i = 0; i < reservations.length; i++){
      Reservation r = reservations[i];
      data[i] = [r.start, r.end, r.renter == msg.sender ? 1 : 0];
    }
    return data;
  }

  function currentReservation() private constant returns (bool isReserved, Reservation reservation){
    uint time = now;
    for (uint i = 0; i < reservations.length; i++){
      Reservation res = reservations[i];
      if (res.start <= time
          && res.end >= time){
        return (true, res);
      }

    }
    return (false, Reservation(0,0,0));
  }

  function occupiedAt(uint time) public constant returns (bool) {
    for (uint i = 0; i < reservations.length; i++){
      Reservation reservation = reservations[i];
      if (time >= reservation.start && time <= reservation.end){
        return true;
      }
    }
    return false;
  }

  function occupiedBetween(uint start, uint end) public constant returns (bool) {
    if (start >= end){
      throw;
    }

    for (uint i = 0; i < reservations.length; i++){
      Reservation reservation = reservations[i];
      if (reservation.start <= start && start <= reservation.end
          || reservation.start <= end && end <= reservation.end
          || start <= reservation.start && end >= reservation.end){
        return true;
      }
    }
    return false;
  }

  function rent(uint start, uint end) /*payable*/ public {
    if (start < now){
      throw;
    }
    if (start >= end){
      throw;
    }
    if (locked){
      throw;
    }
    if (occupiedBetween(start, end)){
      throw;
    }
    if (msg.sender.balance < (end - start) * pricePerTime){
      throw;
    }

    reservations.push(Reservation({start:start, end:end, renter:msg.sender}));
    OnReserve(start, end, msg.sender);
  }

  function transferOwnership(address newOwner) public ownerOnly {
    if (newOwner.balance <= 0){
      throw;
    }
    owner = newOwner;
  }

  function currentRenter() public constant returns (address) {
    var (isReserved, reservation) = currentReservation();
    if (!isReserved){
      return owner;
    } else {
      return reservation.renter;
    }
  }
}
contract RentableDiscovery {  Rentable[] public rentables;    event OnRegister(Rentable rentable);  event OnUnregister(Rentable rentable);  function RentableDiscovery() {    rentables.length = 0;  }      function registerNew(string pdescription, string plocation, uint ppricePerTime, uint pdeposit) returns (address) {    Rentable r = new Rentable(pdescription, plocation, ppricePerTime, pdeposit);    r.transferOwnership(msg.sender);	rentables.push(r);	OnRegister(r);	return r;  }      function registerExisting(Rentable rentable) returns (bool) {      if (exists(rentable)){          return false;      }      rentables.push(rentable);      OnRegister(rentable);      return true;  }      function removeAt(uint index) private {      if(index >= rentables.length){          return;      }      if (rentables[index].owner() != msg.sender){          throw;       }      for (uint k = index; k < rentables.length-1; k++) {        rentables[k] = rentables[k+1];      }      delete rentables[rentables.length-1];      rentables.length--;  }      function unregister(Rentable rentable) {    for (uint i = 0; i < rentables.length; i++) {        if (rentables[i] == rentable) {            removeAt(i);            OnUnregister(rentable);            return;        }    }  }      function indexOf(Rentable rentable) private constant returns (bool found, uint index) {    for (uint i = 0; i < rentables.length; i++) {        if (rentables[i] == rentable) {            return (true, i);        }    }    return (false, 0);  }      function exists(Rentable rentable) constant returns (bool) {      var (found, index) = indexOf(rentable);      return found;  }      function all() constant returns (Rentable[]) {      return rentables;  }  }