// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {StorageSlot} from "../../StorageSlot.sol";
import {BitSlot} from "../../../libraries/udvts/Types.sol";

abstract contract DelegateGuard is StorageSlot {
    error AlreadyInitialized();
    error CallTypeRestricted();

    uint256 internal constant _ORIGINAL_BIT_INDEX = 96;
    uint256 internal constant _INITIALIZED_BIT_INDEX = 95;

    modifier restrictDelegate(bool useDelegate) virtual {
        _restrictDelegate(useDelegate);
        _;
    }

    function _setOriginal() internal virtual {
        BitSlot slot = BitSlot.wrap(_slot());

        if (slot.get(uint8(_INITIALIZED_BIT_INDEX)))
            revert AlreadyInitialized();

        assembly {
            sstore(
                slot,
                or(
                    sload(slot),
                    or(
                        shl(_ORIGINAL_BIT_INDEX, address()),
                        shl(_INITIALIZED_BIT_INDEX, 1)
                    )
                )
            )
        }
    }

    function _restrictDelegate(bool useDelegate_) internal view virtual {
        bytes32 slot = _slot();

        bytes4 callTypeRestricted = CallTypeRestricted.selector;

        assembly {
            let original := and(
                shr(_ORIGINAL_BIT_INDEX, sload(slot)),
                0xffffffffffffffffffffffffffffffffffffffff
            )

            if iszero(xor(eq(original, address()), useDelegate_)) {
                mstore(0x00, callTypeRestricted)
                revert(0x1c, 0x04)
            }
        }
    }
}
