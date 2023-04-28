// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Pausable} from "./guards/Pausable.sol";
import {CallGuard} from "./guards/CallGuard.sol";
import {NonReentrant} from "./guards/NonReentrant.sol";
import {DelegateGuard} from "./guards/DelegateGuard.sol";

abstract contract GuardCore is
    Pausable,
    CallGuard,
    NonReentrant,
    DelegateGuard
{
    function _slot() internal pure virtual override returns (bytes32) {
        /// @dev value is equal to keccak256("Guard.GUARD_SLOT") - 1
        return
            0x9bc15c61845ecb6bf3ba3152360068d446405b2ec4f69134bae259e9bb9e676a;
    }
}
