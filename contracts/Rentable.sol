pragma solidity ^0.4.8;

contract Rentable {

  struct Reservation {
    uint start;
    uint end;
    address renter;
    bool refunded;
  }

  address public owner; // owner of the rentable
  string public description; // any text
  string public location; // any text
  uint public costPerSecond; // amount of wei that the rentable costs each minute
  uint public deposit; // amount of wei that is kept as a deposit in the smart contract. Will be refunded to the renter
  Reservation[] reservations;

  mapping (address => uint) pendingRefunds; // the amount of wei that an address can claim by calling withdrawRefundedDepsoits

  event OnReserve(uint start, uint end, address renter);

  function Rentable(string pdescription, string plocation, uint pcostPerSecond, uint pdeposit) public {
    owner = msg.sender;
    description = pdescription;
    location = plocation;
    costPerSecond = pcostPerSecond;
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

  function allReservations() public constant returns (uint[3][]) {
    uint[3][] memory data = new uint[3][](reservations.length);
    for (uint i = 0; i < reservations.length; i++){
      Reservation r = reservations[i];
      data[i] = [r.start, r.end, r.renter == msg.sender ? 1 : 0];
    }
    return data;
  }

  function currentReservation() private constant returns (bool isReserved, Reservation reservation) {
    uint time = now;
    for (uint i = 0; i < reservations.length; i++){
      Reservation res = reservations[i];
      if (res.start <= time
          && res.end >= time){
        return (true, res);
      }
    }
    return (false, Reservation(0,0,0,false));
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

  function currentRenter() public constant returns (address) {
    var (isReserved, reservation) = currentReservation();
    if (!isReserved){
      return owner;
    } else {
      return reservation.renter;
    }
  }

  function costInWei(uint start, uint end) public constant returns (uint) {
    return ((end - start) * costPerSecond) + deposit;
  }

  function myPendingRefund() public constant returns (uint) {
    return pendingRefunds[msg.sender];
  }

  function transferOwnership(address newOwner) public ownerOnly {
    if (newOwner.balance <= 0){
      throw;
    }
    owner = newOwner;
  }

  function rent(uint start, uint end) payable public {
    if (start >= end){
      throw; // invalid input. Start cannot be bigger than end.
    }
    if (start < now){
      throw; // invlaid input. Cannot rent in the past.
    }
    if (occupiedBetween(start, end)) {
      throw; // invalid input. Rentable is occuppied in desired timeframe.
    }

    uint cost = costInWei(start, end);
    if (msg.value < cost) {
      throw; // not enough money sent by renter
    }
    pendingRefunds[msg.sender] += msg.value - cost; // add excess value sent to refunds
    reservations.push(Reservation({start:start, end:end, renter:msg.sender, refunded:false}));
    OnReserve(start, end, msg.sender);
  }

  // todo: should the contract know this?
  function rentNowUntil(uint end) payable public {
    rent(now, end);
  }

  // todo: should the contract know this?
  function rentNowForMinutes(uint mins) payable public {
    rent (now, (now + mins * 60));
  }

  function refundReservationDeposit(uint start, uint end) public ownerOnly {
    for (uint i = 0; i < reservations.length; i++){
      Reservation r = reservations[i];
      if (r.start == start && r.end == end){
        pendingRefunds[r.renter] += deposit;
        r.refunded = true;
      }
    }
  }

  // withdraw all my refunds.
  // see http://solidity.readthedocs.io/en/develop/common-patterns.html#withdrawal-from-contracts why do complicated.
  function withdrawRefundedDeposits() public returns (bool) {
    uint refund = pendingRefunds[msg.sender];
    pendingRefunds[msg.sender] = 0;
    if (msg.sender.send(refund)) {
        return true;
    } else {
        pendingRefunds[msg.sender] = refund;
        return false;
    }
  }
}
