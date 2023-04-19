// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library BitSlot {
    function get(bytes32 slot, uint8 index) internal view returns (bool isSet) {
        assembly {
            isSet := and(shr(index, sload(slot)), 1)
        }
    }

    function set(bytes32 slot, uint8 index, bool isSet) internal {
        assembly {
            let value := sload(slot)

            if isSet {
                sstore(slot, or(value, shl(index, 1)))
            }

            if iszero(isSet) {
                sstore(slot, and(value, not(shl(index, 1))))
            }
        }
    }
}
