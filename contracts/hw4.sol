// SPDX-License-Identifier: GPL-3.0
// normal function's param is memory (not calldata)

pragma solidity ^0.8.0;

contract Example01 {
    mapping(address => uint256) balance;
    mapping(address => uint256) password;
    address[] accounts;
    struct Wallet{
        address account;
        uint amount;
    }

    function deposit(address to, uint256 hashedPassword) public payable {
        require(msg.value > 0);
        if (!isAccountExist(to)) accounts.push(to);
        password[msg.sender] = hashedPassword;
        balance[to] += msg.value;
    }

    function getBalance(address addr) public view returns (uint256) {
        return balance[addr];
    }

    function withdraw(uint psword) public {
        if (balance[msg.sender] == 0 || 
            password[msg.sender] != hash(psword))
        return;

        payable(msg.sender).transfer(balance[msg.sender]);
        clearAccount(msg.sender);
    }

    function printAllInfo() public view returns (Wallet[] memory) {
        Wallet[] memory wallets = new Wallet[](accounts.length);
        for (uint i = 0; i < accounts.length; i++) {
            wallets[i] = Wallet(accounts[i], balance[accounts[i]]);
        }
        return wallets;
    }

    function transfer(address to, uint256 amount, uint256 psword, uint256 newHashedPassword) public {
        require(amount > 0);
        if (balance[to] == 0 ||
            balance[msg.sender] < amount ||
            hash(psword) != password[msg.sender] )
        return;

        balance[to] += amount;
        balance[msg.sender] -= amount;
        
        if (balance[msg.sender] == 0) clearAccount(msg.sender);
        else password[msg.sender] = newHashedPassword;
    }

    function isAccountExist(address addr) private view returns (bool) {
        // = length: not found, or index
        if (getAccountIndex(addr) == accounts.length) return false;
        return true;
    }

    function getAccountIndex(address addr) private view returns (uint) {
        for (uint i = 0; i < accounts.length; i++) {
            if ((accounts[i] == addr)) return i;
        }
        return accounts.length; // which is greater than accessible index
    }

    function hash(uint256 input) public pure returns (uint256) {
        return uint256(sha256(abi.encode(input)));
    }

    function clearAccount(address account) private {
        // use last one to replace account need to be clear then del last one
        uint256 index = getAccountIndex(account);
        accounts[index] = accounts[accounts.length - 1];
        accounts.pop();
        
        // clear rest thing
        delete (balance[account]);
        delete (password[account]);
    }
}