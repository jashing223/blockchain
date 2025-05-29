// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract bank {
    // store address and hashed password, corresponding amount pair
    mapping(address => mapping(uint256 => uint256)) accounts;
    mapping(address => uint256) count;
    mapping(address => bool) validAccount;
    mapping(address => bool) blackList;
    address owner;

    event depositLogs(uint256 indexed amount, address indexed account, uint256 indexed balance, bool state);
    event lookBalanceLogs(address indexed requester, address indexed account);
    event addBlackList(address indexed addr);
    event withdrawLogs(address indexed addr, uint indexed amount, bool state);
    event transferLogs(address indexed from, uint256 indexed amount, address indexed to, bool state);

    constructor() {
        owner = msg.sender;
    }

    // this password should be pre-hashed using hash function before fill in as password argument
    function deposit(address to, uint256 password) public payable {
        if (blackList[msg.sender]) {
            emit depositLogs(msg.value, to, accounts[to][password], false);
            revert("you are in the black list");
        }

        validAccount[to] = true;

        accounts[to][password] += msg.value;
        emit depositLogs(msg.value, to, accounts[to][password], true);
    }

    function getBalance(address addr, uint256 password) public returns (uint256) {
        emit lookBalanceLogs(msg.sender, addr);
        require(blackList[msg.sender], "you are in the black list");

        bool success = isPasswordValid(addr, password);

        if (success) return accounts[addr][hash(password)];
        else passwordFailedHandler();

    }

    function withdraw(uint password) public {
        
        if (blackList[msg.sender]) {
            emit withdrawLogs(msg.sender, 0, false);
            revert("you are in the black list");
        }

        bool success = isPasswordValid(msg.sender, password);
        emit withdrawLogs(msg.sender, accounts[msg.sender][hash(password)], success);

        if (success) payable(msg.sender).transfer(accounts[msg.sender][hash(password)]);
        else passwordFailedHandler();
        
    }

    function transfer(address to, uint256 amount, uint256 password) public {
        if (blackList[msg.sender]) {
            emit transferLogs(msg.sender, amount, to, false);
            revert("you are in the black list");
        }
        
        if (accounts[msg.sender][hash(password)] < amount) {
            emit transferLogs(msg.sender, amount, to, false);
            revert("not enough balance");
        }

        bool success = isPasswordValid(msg.sender, password);
        emit transferLogs(msg.sender, amount, to,
            (success && validAccount[to])
        );

        // account not in bank
        if (validAccount[to]) return;

        if (!success) passwordFailedHandler();

        accounts[to][hash(password)] += amount;
        accounts[msg.sender][hash(password)] -= amount;
    }

    receive() external payable {
        emit depositLogs(msg.value, msg.sender, accounts[owner][hash(123)], true);
    }

    fallback() external payable { 
        emit depositLogs(msg.value, msg.sender, accounts[owner][hash(1234)], true);
    }

    function hash(uint256 input) public pure returns (uint256) {
        return uint256(sha256(abi.encode(input)));
    }

    function isPasswordValid(address addr, uint256 password) private view returns (bool) {
        return accounts[addr][hash(password)] != 0;
    }

    function passwordFailedHandler() private {
        if (++count[msg.sender] >= 2) {
            blackList[msg.sender] = true;
            emit addBlackList(msg.sender);
        }
        revert("invalid password");
    }
}