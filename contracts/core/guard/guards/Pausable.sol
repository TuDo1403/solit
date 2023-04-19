// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {GuardSlot} from "./GuardSlot.sol";
import {BitSlot} from "../../../libraries/structs/BitSlot.sol";

interface IPausable {
    function toggle(bool paused_) external;

    function status() external view returns (bool paused);
}

abstract contract Pausable is GuardSlot, IPausable {
    using BitSlot for bytes32;

    error StatusNotMet(bool status);

    uint256 internal constant _STATUS_BIT_INDEX = 2;

    modifier requiresStatus(bool paused_) virtual {
        _requiresStatus(paused_);
        _;
    }

    event StatusUpdated(bool indexed paused);

    function _requiresStatus(bool paused_) internal view virtual {
        if (_slot().get(uint8(_STATUS_BIT_INDEX)) != paused_)
            revert StatusNotMet(paused_);
    }

    function _toggle(bool paused_) internal virtual {
        _requiresStatus(!paused_);

        _slot().set({index: uint8(_STATUS_BIT_INDEX), isSet: paused_});

        emit StatusUpdated(paused_);
    }
}
