// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {GuardSlot} from "./GuardSlot.sol";
import {BitSlot} from "../../../libraries/structs/BitSlot.sol";

abstract contract DelegateGuard is GuardSlot {
    using BitSlot for bytes32;

    error AlreadyInitialized();
    error CallTypeRestricted();

    uint256 internal constant _ORIGINAL_BIT_INDEX = 96;
    uint256 internal constant _INITIALIZED_BIT_INDEX = 95;

    modifier restrictDelegate(bool useDelegate_) virtual {
        _restrictDelegate(useDelegate_);
        _;
    }

    function _setOriginal() internal {
        bytes32 slot = _slot();

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

            // externalCall [0] ^ useDelegate_ [0] == [0] => revert
            // externalCall [0] ^ useDelegate_ [1] == [1] => pass
            // externalCall [1] ^ useDelegate_ [0] == [1] => pass
            // externalCall [1] ^ useDelegate_ [1] == [0] => revert
        }
    }
}
