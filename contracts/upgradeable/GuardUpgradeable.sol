// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {
    Initializable
} from "./external/@openzeppelin/proxy/utils/Initializable.sol";

import {GuardCore} from "../core/guard/GuardCore.sol";

abstract contract GuardUpgradeable is GuardCore, Initializable {
    function __Guard_init_unchained() internal onlyInitializing {
        _setOriginal();
    }
}
