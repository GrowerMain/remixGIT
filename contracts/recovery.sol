// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISimpleToken {
    // Define the destroy function signature
    function destroy(address payable _to) external;
}

contract Recovery {
    // Function to interact with the SimpleToken contract and destroy it
    function destroySimpleToken(address _simpleTokenAddress, address payable _to) public {
        ISimpleToken simpleToken = ISimpleToken(_simpleTokenAddress);
        simpleToken.destroy(_to);
    }
}
