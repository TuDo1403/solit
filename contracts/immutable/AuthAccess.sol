// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAuthority, AuthAccessCore} from "../core/auth/AuthAccessCore.sol";

abstract contract AuthAccess is AuthAccessCore {
    constructor(address owner_, IAuthority authority_) payable {
        _setAuthority(authority_);
        _transferOwnership(owner_);
    }
}
