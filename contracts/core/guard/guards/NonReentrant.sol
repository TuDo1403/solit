// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {StorageSlot} from "../../StorageSlot.sol";

import {BitSlot} from "../../../libraries/udvts/Types.sol";

abstract contract NonReentrant is StorageSlot {
    error NonReentrancy();

    uint256 internal constant _ENTER_BIT_INDEX = 1;

    modifier nonReentrant() virtual {
        BitSlot slot = BitSlot.wrap(_slot());
        uint8 bitIndex = uint8(_ENTER_BIT_INDEX);

        __beforeReentrant(slot, bitIndex);
        _;
        __afterReentrant(slot, bitIndex);
    }

    function __beforeReentrant(BitSlot slot_, uint8 bitIndex_) private {
        if (slot_.get(bitIndex_)) revert NonReentrancy();

        slot_.set({index: bitIndex_, isSet: true});
    }

    function __afterReentrant(BitSlot slot_, uint8 bitIndex_) private {
        slot_.set({index: bitIndex_, isSet: false});
    }
}
