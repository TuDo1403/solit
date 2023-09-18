// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library LibContext {
    function isSelfCall() internal view returns (bool yes) {
        // assembly ("memory-safe") {
        //   yes := eq(caller(), address())
        // }
        yes = msg.sender == address(this);
    }
}
