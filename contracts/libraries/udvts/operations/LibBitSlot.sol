// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {BitSlot} from "../Types.sol";

library LibBitSlot {
    function get(BitSlot slot, uint8 index) internal view returns (bool isSet) {
        assembly {
            isSet := and(shr(index, sload(slot)), 1)
        }
    }

    function set(BitSlot slot, uint8 index, bool isSet) internal {
        assembly {
            let value := sload(slot)
            let shift := and(index, 0xff)
            // Isolate the bit at `shift`.
            let bit := and(shr(shift, value), 1)
            // Xor it with `shouldSet`. Results in 1 if both are different, else 0.
            bit := xor(bit, isSet)
            // Shifts the bit back. Then, xor with value.
            // Only the bit at `shift` will be flipped if they differ.
            // Every other bit will stay the same, as they are xor'ed with zeroes.
            sstore(slot, xor(value, shl(shift, bit)))
        }
    }
}
