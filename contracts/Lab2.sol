// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Base.sol";
// Uncomment this line to use console.log
import "hardhat/console.sol";

contract CSITToken is Mortal, ERC20 {

    struct Property {
        uint balance;
        bool isUnlocked;
        bool isTraded;
    }

    uint256 public startTime;
    uint256 public endTime;
    mapping (address => Property) usersProperty;

    constructor() ERC20("CSITToken", "CSITT"){
        _mint(msg.sender, 100_000_000 * (10 ** decimals()));
    }

    function setStartTime(uint256 _startTime) public onlyOwner {
        console.log("Set startTime %s", _startTime);
        startTime = _startTime;
    }

    function setEndTime(uint256 _endTime) public onlyOwner {
        console.log("Set endTime %s", _endTime);
        endTime = _endTime;
    }

    modifier onlyBothTimeSet() {
        require(startTime != 0, "startTime is not initialized");
        require(endTime != 0, "endTime is not initialized");
        _;
    }

    // call this function with some amount of ether, then convert it to locked
    // ether in this contract
    function lock() public payable onlyBothTimeSet {
        require(block.timestamp < startTime, "You can't lock, because eth in this contract is locked");
        // prevent unlock at 0 balance but still get reward
        require(block.timestamp < startTime, "You can't lock with zero amount");
        uint256 amountToLock = msg.value;
        usersProperty[msg.sender].balance = amountToLock;
    }

    function unlock() public onlyBothTimeSet {
        require(block.timestamp >= endTime, "You can't unlock yet, because eth in this contract not unlock");
        uint256 senderProperty = usersProperty[msg.sender].balance;
        bool isSenderBalanceTraded = usersProperty[msg.sender].isTraded;
        uint256 rewardTokenAmount = 1000;

        if (!isSenderBalanceTraded && senderProperty < getETH()) {
            payable(address(msg.sender)).transfer(senderProperty);
        } else {
            rewardTokenAmount += senderProperty * 2500;
        }
        usersProperty[msg.sender].isUnlocked = true;
        this.transferFrom(address(this), msg.sender, rewardTokenAmount);
    }

    function tradeUserFunds(address _user) public onlyBothTimeSet onlyOwner {
        console.log("trade someone's money");
        usersProperty[_user].isTraded = true;
        this.transferFrom(address(this), _user, usersProperty[_user].balance);
    }

    function getETH() public view returns (uint) {
        return address(this).balance;
    }
}
