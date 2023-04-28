// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {StorageSlot} from "../../StorageSlot.sol";

import {IPausable} from "./interfaces/IPausable.sol";

import {BitSlot} from "../../../libraries/udvts/Types.sol";

abstract contract Pausable is StorageSlot, IPausable {
    uint256 internal constant _STATUS_BIT_INDEX = 2;

    modifier requiresStatus(bool paused_) virtual {
        _requiresStatus(paused_);
        _;
    }

    function status() public view virtual returns (bool paused) {
        paused = BitSlot.wrap(_slot()).get(uint8(_STATUS_BIT_INDEX));
    }

    function _requiresStatus(bool paused_) internal view virtual {
        if (status() != paused_) revert StatusNotMet(paused_);
    }

    function _toggle(bool paused_) internal virtual {
        _requiresStatus(!paused_);

        BitSlot.wrap(_slot()).set({
            index: uint8(_STATUS_BIT_INDEX),
            isSet: paused_
        });

        emit StatusUpdated(paused_);
    }
}
