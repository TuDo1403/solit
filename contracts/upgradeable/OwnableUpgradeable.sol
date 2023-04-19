// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Initializable} from "./external/@openzeppelin/proxy/utils/Initializable.sol";

import {OwnableCore} from "../core/auth/OwnableCore.sol";

abstract contract OwnableUpgradeable is OwnableCore, Initializable {
    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(msg.sender);
    }
}
