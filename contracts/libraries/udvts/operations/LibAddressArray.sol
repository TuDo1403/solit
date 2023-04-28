// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AddressArray} from "../Types.sol";

library LibAddressArray {
    function all(
        AddressArray slot
    ) internal view returns (address[] memory values) {
        uint256 length;
        assembly {
            length := sload(slot)
        }

        values = new address[](length);

        assembly {
            mstore(0x00, length)

            let allocation := keccak256(0x00, 0x20)
            let valuesAllocation := add(values, 0x20)

            length := shl(5, length)
            for {
                let i
            } lt(i, length) {
                i := add(i, 0x20)
            } {
                mstore(add(i, valuesAllocation), sload(add(i, allocation)))
            }
        }
    }

    function wrap(
        address[] storage array
    ) internal pure returns (AddressArray slot) {
        assembly {
            slot := array.slot
        }
    }

    function unwrap(
        AddressArray slot
    ) internal pure returns (address[] storage array) {
        assembly {
            array.slot := slot
        }
    }

    function push(AddressArray slot, address[] memory values) internal {
        assembly {
            mstore(0x00, slot)

            let length := sload(slot)
            let tailLocation := add(keccak256(0x00, 0x20), shl(5, length))

            length := add(length, mload(values))
            sstore(slot, length)

            length := mload(values)
            length := shl(5, length)

            let valuesLocation := add(values, 0x20)

            for {
                let i
            } lt(i, length) {
                i := add(i, 0x20)
            } {
                sstore(add(i, tailLocation), mload(add(i, valuesLocation)))
            }
        }
    }
}
