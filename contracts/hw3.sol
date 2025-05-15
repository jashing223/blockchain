// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract hw3{
    address user;
    uint256 hashedPassword;
    uint256 balance;

    // password related thing
    function setPassword(uint256 rawPassword) private returns (uint256) {
        hashedPassword = hash(rawPassword);
        return hashedPassword;
    }
    function hash(uint256 input) public pure returns (uint256) {
        return uint256(sha256(abi.encode(input)));
    }
    function getHashedPassword() private view returns (uint256) {
        return hashedPassword;
    }
    function isValid(uint256 rawPassword) private view returns(bool) {
        return hash(rawPassword) == getHashedPassword();
    }

    // deposit and set the withdraw password without manually hashing it
    function deposit(address to, uint256 rawPassword) public payable {
        user = to;
        hashedPassword = hash(rawPassword);
        balance += msg.value;
    }
    function withdraw(uint256 rawPassword) public {
        if (isValid(rawPassword) && user == msg.sender){
            payable(msg.sender).transfer(balance);
            balance = 0;
        }
    }
    function getBlance() public  view returns (uint256) {
        return balance;
    }
}