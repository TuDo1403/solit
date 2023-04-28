// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {
    Initializable
} from "./external/@openzeppelin/proxy/utils/Initializable.sol";

import {IAuthority, AuthAccessCore} from "../core/auth/AuthAccessCore.sol";

abstract contract AuthAccessUpgradeable is Initializable, AuthAccessCore {
    function __AuthAccess_init_unchained(
        address owner_,
        IAuthority authority_
    ) internal onlyInitializing {
        _setAuthority(authority_);
        _transferOwnership(owner_);
    }
}
