// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract GuardSlot {
    function _slot() internal pure virtual returns (bytes32);
}
