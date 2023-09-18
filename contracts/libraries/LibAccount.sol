// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library LibAccount {
    /// @dev see: https://eips.ethereum.org/EIPS/eip-1052
    bytes32 internal constant EMPTY_ACCOUNT_HASH = 0x00;
    /// @dev value is equal to keccak256(abi.encode())
    bytes32 internal constant CREATED_ACCOUNT_HASH =
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    function isEmpty(address account) internal view returns (bool yes) {
        // assembly ("memory-safe") {
        //   yes := eq(extcodehash(account), EMPTY_ACCOUNT_HASH)
        // }
        yes = account.codehash == EMPTY_ACCOUNT_HASH;
    }

    function isContract(address account) internal view returns (bool yes) {
        // assembly ("memory-safe") {
        //   yes := iszero(iszero(extcodesize(account), 0))
        // }
        yes = account.code.length != 0;
    }

    function isCreatedEOA(address account) internal view returns (bool yes) {
        // assembly ("memory-safe") {
        //   yes := eq(extcodehash(account), CREATED_ACCOUNT_HASH)
        // }
        yes = account.codehash == CREATED_ACCOUNT_HASH;
    }
}
