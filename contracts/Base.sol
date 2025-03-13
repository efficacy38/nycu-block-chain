// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Owned {
    address payable owner;

    // Contract constructor: set owner
    constructor() {
        owner = payable(msg.sender);
    }

    // Access control modifier
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }
}

contract Mortal is Owned {
    // Contract destructor
    function destroy() public onlyOwner {
        // TODO: remove this deprecated code
        selfdestruct(owner);

        // return all money back
        // payable(owner).transfer(address(this).balance);
    }
}
