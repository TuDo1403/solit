// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {GuardCore} from "../core/guard/GuardCore.sol";

abstract contract Guard is GuardCore {
    constructor() payable {
        _setOriginal();
    }
}
