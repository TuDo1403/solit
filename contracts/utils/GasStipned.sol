// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract GasStipned {
    function _gasStipned() internal pure virtual returns (uint256) {
        return 50_000;
    }
}
