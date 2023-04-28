// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAuthority} from "../../core/auth/interfaces/IAuthority.sol";

import {
    RoleBasedAuthorityCore
} from "../../core/auth/authorities/RoleBasedAuthorityCore.sol";

contract RoleBasedAuthority is RoleBasedAuthorityCore {
    constructor(address owner_) payable {
        _transferOwnership(owner_);
        _setAuthority(IAuthority(address(this)));
    }
}
