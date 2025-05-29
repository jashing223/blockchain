// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Example02 {
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
        if(!success) revert("Insufficient balance! (message is send from sendWithdraw)");
        return success;
    }

    function transferWithdraw(uint256 amount) public {
        require(balance >= amount ,"Insufficient balance! (message is send from transferWithdraw)");
        admin.transfer(amount);
        balance -= amount;
    }
           
    function getBalance()public view returns(uint256){
        return balance;
    }
}
