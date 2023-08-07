// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largelly inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */
library BitMaps {
    struct BitMap {
        mapping(uint256 => uint256) map;
    }

    // /**
    //  * @dev Returns whether the bit at `index` is set.
    //  */
    // function get(
    //     mapping(uint256 => uint256) storage bitmap,
    //     uint256 index
    // ) internal view returns (bool isSet) {
    //     assembly {
    //         mstore(0x00, shr(8, index))
    //         mstore(0x20, bitmap.slot)
    //         // Assign isSet to whether the value is non zero.
    //         isSet := and(sload(keccak256(0x00, 0x40)), shl(and(index, 0xff), 1))
    //     }
    //     return get(wrap(bitmap), index);
    // }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(
        BitMap storage bitmap,
        uint256 index
    ) internal view returns (bool isSet) {
        assembly {
            mstore(0x00, shr(8, index))
            mstore(0x20, bitmap.slot)
            // Assign isSet to whether the value is non zero.
            isSet := and(sload(keccak256(0x00, 0x40)), shl(and(index, 0xff), 1))
        }
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool shouldSet
    ) internal {
        assembly {
            mstore(0x00, shr(8, index))
            mstore(0x20, bitmap.slot)

            let mapKey := keccak256(0x00, 0x40)
            let value := sload(mapKey)

            // The following sets the bit at `shift` without branching.
            let shift := and(index, 0xff)
            // Isolate the bit at `shift`.
            let x := and(shr(shift, value), 1)
            // Xor it with `shouldSet`. Results in 1 if both are different, else 0.
            x := xor(x, shouldSet)
            // Shifts the bit back. Then, xor with value.
            // Only the bit at `shift` will be flipped if they differ.
            // Every other bit will stay the same, as they are xor'ed with zeroes.
            value := xor(value, shl(shift, x))

            sstore(mapKey, value)
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        assembly {
            mstore(0, shr(8, index))
            mstore(32, bitmap.slot)
            let key := keccak256(0, 64)
            let value := sload(key)
            let mask := shl(and(index, 0xff), 1)
            if iszero(eq(and(value, mask), mask)) {
                value := or(value, mask)
                sstore(key, value)
            }
        }
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        bitmap.map[index >> 8] &= ~(1 << (index & 0xff));
        assembly {
            mstore(0, shr(8, index))
            mstore(32, bitmap.slot)
            let key := keccak256(0, 64)
            let value := sload(key)
            let mask := shl(and(index, 0xff), 1)
            // value & mask != 0
            if iszero(iszero(and(value, mask))) {
                value := or(value, mask)
                sstore(key, value)
            }
        }
    }
}
