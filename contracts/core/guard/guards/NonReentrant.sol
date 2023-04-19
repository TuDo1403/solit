// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {GuardSlot} from "./GuardSlot.sol";
import {BitSlot} from "../../../libraries/structs/BitSlot.sol";

abstract contract NonReentrant is GuardSlot {
    using BitSlot for bytes32;

    error NonReentrancy();

    uint256 internal constant _ENTER_BIT_INDEX = 1;

    modifier nonReentrant() {
        bytes32 slot = _slot();
        uint8 bitIndex = uint8(_ENTER_BIT_INDEX);

        __beforeReentrant(slot, bitIndex);
        _;
        __afterReentrant(slot, bitIndex);
    }

    function __beforeReentrant(bytes32 slot_, uint8 bitIndex_) private {
        if (slot_.get(bitIndex_)) revert NonReentrancy();

        slot_.set({index: bitIndex_, isSet: true});
    }

    function __afterReentrant(bytes32 slot_, uint8 bitIndex_) private {
        slot_.set({index: bitIndex_, isSet: false});
    }
}
