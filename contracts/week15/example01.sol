// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Example01 {
    address payable admin;
    uint256 balance;

    function setAdmin() public {
        admin = payable (msg.sender);
    }

    function deposit() public payable {
        balance += msg.value;
    }

    function sendWithdraw(uint256 amount) public returns (bool) {
        bool success = admin.send(amount);
        return success;
    }

    function transferWithdraw(uint256 amount) public {
        admin.transfer(amount);
        balance -= amount;
    }
           
    function getBalance()public view returns(uint256){
        return balance;
    }
}
