// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract RegularPayment {

    address public payer;
    address public payee;
    uint256 public amount;
    uint256 public interval;
    uint256 public lastPaymentTime;

    constructor() {
        payer = msg.sender;
        lastPaymentTime = block.timestamp;
    }

    // Modifier to ensure only the payer can initiate payments
    modifier onlyPayer() {
        require(msg.sender == payer, "Only the payer can initiate the payment");
        _;
    }

    // Modifier to ensure enough time has passed between payments
    modifier intervalReached() {
        require(block.timestamp >= lastPaymentTime + interval, "Interval not yet passed");
        _;
    }

    // Function to set the payee, only callable by the payer
    function setPayee(address _payee) public onlyPayer {
        require(_payee != address(0), "Payee cannot be the zero address");
        payee = _payee;
    }

    // Function to set the payment amount, only callable by the payer
    function setAmount(uint256 _amount) public onlyPayer {
        require(_amount > 0, "Amount must be greater than zero");
        amount = _amount;
    }

    // Function to set the payment interval (in seconds), only callable by the payer
    function setInterval(uint256 _interval) public onlyPayer {
        require(_interval > 0, "Interval must be greater than zero");
        interval = _interval;
    }

    // Function to deposit funds into the contract
    function deposit() public payable onlyPayer {
        require(msg.value > 0, "Deposit must be greater than zero");
    }

    // Function to send the payment
    function sendPayment() public onlyPayer intervalReached {
        require(address(this).balance >= amount, "Insufficient contract balance");
        require(payee != address(0), "Payee is not set");

        lastPaymentTime = block.timestamp;
        payable(payee).transfer(amount);
    }

    // Check the balance of the contract
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Allow payer to withdraw the remaining funds (if needed)
    function withdraw(uint256 _amount) public onlyPayer {
        require(address(this).balance >= _amount, "Insufficient funds");
        payable(payer).transfer(_amount);
    }

    // Function to check how much time is left until the next payment can be made
    function timeUntilNextPayment() public view returns (uint256) {
        if (block.timestamp >= lastPaymentTime + interval) {
            return 0;  // Time has passed, payment is allowed
        } else {
            return (lastPaymentTime + interval) - block.timestamp;  // Time left in seconds
        }
    }
}
