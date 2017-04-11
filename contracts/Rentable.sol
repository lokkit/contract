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
  bool public locked = false;

  Reservation[] reservations;

  event OnReserve(uint start, uint end, address renter);

  modifier ownerOnly {
    if (owner != msg.sender) {
      throw;
    }
    _;

  }

  function getDescription() public returns(string) {
    return description;
  }
  function getLocation() public returns(string) {
    return location;
  }
  function getPricePerTime() public returns(uint) {
    return pricePerTime;
  }

  modifier currentReserverOnly {
    var (isReserved, reservation) = currentReservation();
    if (!isReserved
        || reservation.renter != msg.sender){
      throw;
    }
    _;

  }

  function Rentable(string pdescription, string plocation, uint ppricePerTime, uint deposit) public {
    owner = msg.sender;
    description = pdescription;
    location = plocation;
    pricePerTime = ppricePerTime;
    reservations.length = 0;
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
