// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAuthority} from "../../interfaces/IAuthority.sol";
import {IRoleBasedAuthority} from "./IRoleBasedAuthority.sol";

interface IMultiRoleBasedAuthority is IRoleBasedAuthority {
    event TargetCustomAuthorityUpdated(
        address indexed target,
        IAuthority authority
    );

    function setTargetCustomAuthority(
        address target_,
        IAuthority authority_
    ) external;
}
