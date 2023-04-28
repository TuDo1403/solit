// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAuthority} from "../../interfaces/IAuthority.sol";

interface IRoleBasedAuthority is IAuthority {
    event UserRoleUpdated(
        address indexed user,
        uint256 indexed role,
        bool enabled
    );

    event PublicAccessUpdated(
        address indexed target,
        bytes4 indexed functionSig,
        bool enabled
    );

    event RoleAccessUpdated(
        uint8 indexed role,
        address indexed target,
        bytes4 indexed functionSig,
        bool enabled
    );

    function setPublicAccess(
        address target_,
        bytes4 fnSig_,
        bool enabled_
    ) external;

    function setUserRole(address account_, uint8 role_, bool enabled_) external;

    function isPublicAccess(
        address target_,
        bytes4 fnSig_
    ) external view returns (bool yes);

    function viewAccessibleRoles(
        address target_,
        bytes4 fnSig_
    ) external view returns (bytes32 roleAccessBitmap);

    function viewAccountRoles(
        address account_
    ) external view returns (bytes32 roleBitMap);

    function doesRoleHaveAccess(
        address target_,
        bytes4 fnSig_,
        uint8 role_
    ) external view returns (bool yes);

    function doesAccountHaveRole(
        address account_,
        uint8 role_
    ) external view returns (bool yes);
}
