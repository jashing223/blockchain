// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Example03 {
    address payable admin;
    uint256 balance;
    event transaction(uint256 indexed amount, uint256 indexed balance, address indexed addr, bool success);

    function setAdmin() public {
        admin = payable (msg.sender);
    }

    function deposit() public payable {
        balance += msg.value;
    }

    function sendWithdraw(uint256 amount) public{
        bool success = admin.send(amount);
        if(!success){ 
            emit transaction(amount, balance, msg.sender, success);
        }else{
            emit transaction(amount, balance, msg.sender, success);
        }
        
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
