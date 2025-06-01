// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract sendToContract{
    function deposit() public payable {}

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function SendToContract(address addr, uint amount) public {
        payable(addr).call{value: amount}("");
    }

}