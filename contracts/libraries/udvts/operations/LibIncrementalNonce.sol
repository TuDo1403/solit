// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IncrementalNonce} from "../Types.sol";

library LibIncrementalNonce {
    bytes32 private constant STORAGE_SLOT =
        0xb2ed93ede06b0051a7999c53e97a135e0dcf82f3536ba81e8c4b3f3012c242bc;

    function increment(
        IncrementalNonce slot,
        bytes32 key
    ) internal returns (uint256 current) {
        assembly {
            mstore(0x00, key)
            mstore(0x20, xor(slot, STORAGE_SLOT))
            let internalKey := keccak256(0x00, 0x40)
            current := sload(internalKey)
            sstore(internalKey, add(1, current))
        }
    }
}
