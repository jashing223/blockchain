// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Example00 {
    function isSmartContract(address addr) public view returns (bool) {
        if (addr.code.length != 0) {
            return true;
        } else {
            return false;
        }
    }

    function balalnceAddressTest(address addr)public view returns(uint256){
        return addr.balance;
    }

    function codeAddressTest(address addr)public view returns(bytes memory){
        return addr.code;
    }
    
    function codeHashAddressTest(address addr)public view returns(bytes32){
        return addr.codehash;
    }

    function compareCodeHash(address addr,address bddr)public view returns(bool){
        return addr.codehash == bddr.codehash;
    }
}
