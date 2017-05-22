pragma solidity ^0.4.8;

// An object that can be rented.
contract Rentable {
  
  // Contains information to the period during which a Rentable was rented.
  struct Reservation {
    // unix timestamp when the reservation starts
    uint start;
    // unix timestamp when the reservation ends
    uint end;
    // ethereum address of the entity renting the object
    address renter;
    // wehter the deposit was refunded
    bool refunded;
    // the amount of ether (in wei) that was paid to rent (excluding deposit)
    uint cost;
    // the deposit at the time of reservation
    uint deposit;
  }

  // Current owner of the rentable. Can be changed by the owner by calling transferOwnership.
  address public owner; 
  // Any text
  string public description;
  // Any text
  string public location;
   // The amount of wei that the rentable costs each second.
  uint public costPerSecond;
  // The amount of wei that is kept as a deposit in the smart contract.
  // Will be refunded to the renter when the owner calls completeReservation.
  uint public deposit;
  // All reservations stored in the blockchain.
  Reservation[] reservations;
  // The amount of wei that an address can claim by calling withdrawRefundedDepsoits.
  mapping (address => uint) pendingRefunds;

  // Is raised when someone rents the Rentable.
  event OnRent(uint start, uint end, address renter);

  // Creates a new rentable.
  function Rentable(string pdescription, string plocation, uint pcostPerSecond, uint pdeposit) public {
    owner = msg.sender;
    description = pdescription;
    location = plocation;
    costPerSecond = pcostPerSecond;
    deposit = pdeposit;
    reservations.length = 0;
  }

  // Modifier for the owner.
  modifier ownerOnly {
    if (owner != msg.sender) {
      throw;
    }
    _;
  }

  // Modifier for the current renter.
  modifier currentRenterOnly {
    var (isReserved, reservation) = currentReservation();
    if (!isReserved || reservation.renter != msg.sender){
      throw;
    }
    _;
  }

  // returns all reservations stored in the reservations array.
  // Format: [start-time, end-time, caller-is-renter].
  // caller-is-renter is either 1 or 0, where 1 means the caller
  // is the renter.
  function allReservations() public constant returns (uint[3][]) {
    uint[3][] memory data = new uint[3][](reservations.length);
    for (uint i = 0; i < reservations.length; i++){
      Reservation r = reservations[i];
      data[i] = [r.start, r.end, r.renter == msg.sender ? 1 : 0];
    }
    return data;
  }

  // Returns the reservation from the reservations array at the now time.
  function currentReservation() private constant returns (bool isReserved, Reservation reservation) {
    uint time = now;
    for (uint i = 0; i < reservations.length; i++){
      Reservation res = reservations[i];
      if (res.start <= time
          && res.end >= time){
        return (true, res);
      }
    }
    return (false, Reservation(0,0,0,false,0,0));
  }

  // Returns whether the Rentable is reserved at the given time.
  function reservedAt(uint time) public constant returns (bool) {
    for (uint i = 0; i < reservations.length; i++){
      Reservation reservation = reservations[i];
      if (time >= reservation.start && time <= reservation.end){
        return true;
      }
    }
    return false;
  }

  // Returns whether the Rentable is reserved between two times.
  function reservedBetween(uint start, uint end) public constant returns (bool) {
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

  // Returns the address of the current Reservation.
  // This address is permitted to send commands to the Rentable.
  function currentRenter() public constant returns (address) {
    var (isReserved, reservation) = currentReservation();
    if (!isReserved){
      return owner;
    } else {
      return reservation.renter;
    }
  }

  // Calculates the cost in wei for a given period.
  // Can be called with 0 and 60 to calculate the cost for a minute.
  // This is the amount of wei to be sent to "rent" as "value" of the transaction.
  function costInWei(uint start, uint end) public constant returns (uint) {
    return ((end - start) * costPerSecond) + deposit;
  }

  // Returns the amount of wei that is pending to be withdrawn with withdrawRefund.
  function myPendingRefund() public constant returns (uint) {
    return pendingRefunds[msg.sender];
  }

  // Transfers the ownership to another address.
  function transferOwnership(address newOwner) public ownerOnly {
    if (newOwner.balance <= 0){
      throw;
    }
    owner = newOwner;
  }

  // Lets an address rent the Rentable for a given period.
  function rent(uint start, uint end) payable public {
    if (start >= end){
      throw; // invalid input. Start cannot be bigger than end.
    }
    if (start < now){
      throw; // invlaid input. Cannot rent in the past.
    }
    if (reservedBetween(start, end)) {
      throw; // invalid input. Rentable is occuppied in desired timeframe.
    }

    uint cost = costInWei(start, end);
    OnRent(cost, msg.value, msg.sender);
    if (msg.value < cost) {
      throw; // not enough money sent by renter
    }
    pendingRefunds[msg.sender] += msg.value - cost; // add excess value sent to refunds
    OnRent(pendingRefunds[msg.sender], 0, msg.sender);
    reservations.push(Reservation({start:start, end:end, renter:msg.sender, refunded:false, cost:cost, deposit:deposit})); // add the reservation to the internal state (in blockchain)
    OnRent(start, end, msg.sender);
  }

  // todo: remove utility before release
  function rentNowUntil(uint end) payable public {
    rent(now, end);
  }

  // todo: remove utility before release
  function rentNowForMinutes(uint mins) payable public {
    rent (now, (now + mins * 60));
  }

  // Ends the current Reservation to end now.
  // Refunds half the paid amount to the renter and owner each.
  // Calling completeReservation will pay the owner and refund the deposit to the renter.
  function finishEarly () public currentRenterOnly {
    var (isReserved, reservation) = currentReservation();
    if (!isReserved){
      return;
    }
    uint timeDelta = reservation.end - now;
    uint totalTime = reservation.end - reservation.start;
    // refund is: 
    // the amount of ether paid for the period (cost - deposit)
    // in ratio to the amount of time the rentable was returned early (timeDelta / totalTime)
    uint earlyReturnRefund = (reservation.cost - reservation.deposit) * timeDelta / totalTime;
    pendingRefunds[msg.sender] += earlyReturnRefund / 2;
    pendingRefunds[owner] += earlyReturnRefund / 2;
    
    reservation.end = now; // change current reservation to end now.
    reservation.cost -= earlyReturnRefund;
  }

  // Refunds deposit to renter and sends the owner the paid ether.
  function completeReservation(uint start, uint end) public ownerOnly {
    for (uint i = 0; i < reservations.length; i++){
      Reservation r = reservations[i];
      if (r.start == start && r.end == end){
        r.refunded = true;
        pendingRefunds[owner] += r.cost - r.deposit;
        pendingRefunds[r.renter] += r.deposit;
      }
    }
  }

  // Withdraw all my refunds.
  function withdrawRefunds() public returns (bool) {
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