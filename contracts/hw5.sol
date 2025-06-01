// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Bank {
    mapping(address => uint256) balances;
    mapping(address => uint256) passwords;
    mapping(address => uint256) count;
    mapping(address => bool) blackList;
    address payable owner;

    event depositLogs(uint256 indexed amount, address indexed account, uint256 indexed balance, bool state);
    event lookBalanceLogs(address indexed requester, address indexed account, bool state);
    event addBlackList(address indexed addr);
    event withdrawLogs(address indexed addr, uint indexed amount, bool state);
    event transferLogs(address indexed from, uint256 indexed amount, address indexed to, bool state);
    event forwardLogs(address indexed from, uint256 indexed amount);

    constructor() {
        owner = payable (msg.sender);
    }

    modifier noContract() {
        if (msg.sender.code.length != 0) {
            emit addBlackList(msg.sender);
            blackList[msg.sender] = true;
        }
        _;
    }

    // this password should be pre-hashed using hash function before fill in as password argument
    function deposit(address to, uint256 password) public payable noContract{
        if (blackList[msg.sender]) {
            emit depositLogs(msg.value, to, balances[to], false);
            revert("you are in the black list");
        }
        bool success = (msg.value > 0); 

        balances[to] += msg.value;
        emit depositLogs(msg.value, to, balances[to], success);

        if (success) passwords[to] = password;
        else revert("not allow 0 amount deposit");
    }

    function getBalance(address addr, uint256 password) public noContract returns (uint256) {
        
        bool success = isPasswordValid(addr, password);
        emit lookBalanceLogs(msg.sender, addr, success && !blackList[msg.sender]);
        require(!blackList[msg.sender], "you are in the black list");

        if (success) return balances[addr];
        else passwordFailedHandler();

        return 0;
    }

    function withdraw(uint256 password) public noContract{
        
        if (blackList[msg.sender]) {
            emit withdrawLogs(msg.sender, 0, false);
            revert("you are in the black list");
        }

        bool success = isPasswordValid(msg.sender, password);
        emit withdrawLogs(msg.sender, balances[msg.sender], success);

        if (success) {
            payable(msg.sender).transfer(balances[msg.sender]);
            balances[msg.sender] = 0;
        }
        else passwordFailedHandler();
        
    }

    function transfer(address to, uint256 amount, uint256 password) public noContract{
        if (blackList[msg.sender]) {
            emit transferLogs(msg.sender, amount, to, false);
            revert("you are in the black list");
        }

        bool success = isPasswordValid(msg.sender, password);
        emit transferLogs(msg.sender, amount, to,
            (success && passwords[to] != 0)
        );

        if (!success) passwordFailedHandler();

        if (balances[msg.sender] < amount) {
            emit transferLogs(msg.sender, amount, to, false);
            revert("not enough balance");
        }

        // account not in bank
        if (passwords[to] == 0) {
            revert("`to` address not in the bank");
        }

        balances[to] += amount;
        balances[msg.sender] -= amount;
    }

    receive() external payable noContract{
        payable(owner).transfer(msg.value);
        emit forwardLogs(msg.sender, msg.value);
        require(!blackList[msg.sender], "you are in the black list");
    }

    fallback() external payable noContract{ 
        payable(owner).transfer(msg.value);
        emit forwardLogs(msg.sender, msg.value);
        require(!blackList[msg.sender], "you are in the black list");
    }

    function hash(uint256 input) public pure returns (uint256) {
        return uint256(sha256(abi.encode(input)));
    }

    function isPasswordValid(address addr, uint256 password) private view returns (bool) {
        return passwords[addr] == hash(password);
    }

    function passwordFailedHandler() private {
        count[msg.sender] += 1;
        if (count[msg.sender] >= 2) {
            blackList[msg.sender] = true;
            emit addBlackList(msg.sender);
        }
    }
}