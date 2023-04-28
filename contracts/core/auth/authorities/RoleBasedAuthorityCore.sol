// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AuthAccessCore} from "../AuthAccessCore.sol";

import {IRoleBasedAuthority} from "./interfaces/IRoleBasedAuthority.sol";

abstract contract RoleBasedAuthorityCore is
    AuthAccessCore,
    IRoleBasedAuthority
{
    /// @dev value is equal to keccak256("RoleBasedAuthority.USER_ROLES_SLOT") - 1
    bytes32 internal constant _USER_ROLES_SLOT =
        0x4ded14d7e7bdedd1ed3741df68a63160b283d35de885193dd7bc1ae3f2337278;
    /// @dev value is equal to keccak256("RoleBasedAuthority.ROLE_ACCESS_SLOT") - 1
    bytes32 internal constant _ROLE_ACCESS_SLOT =
        0x0951eaf92075d89614975d6940ed2f478f8d8fc53d4a274b1f968db6b3cf9ab5;
    /// @dev value is equal to keccak256("RoleBasedAuthority.PUBLIC_ACCESS_SLOT") - 1
    bytes32 internal constant _PUBLIC_ACCESS_SLOT =
        0x1899b4b82a71bb755b0b6c9175914e90c03e09e8df6ec5f9aca122570f753635;

    function setPublicAccess(
        address target_,
        bytes4 fnSig_,
        bool enabled_
    ) public virtual requiresAuth {
        _setPublicAccess(target_, fnSig_, enabled_);
    }

    function setUserRole(
        address account_,
        uint8 role_,
        bool enabled_
    ) public virtual requiresAuth {
        _setUserRole(account_, role_, enabled_);
    }

    function setUserMultiRole(
        address account_,
        uint256 roles_,
        bool enabled_
    ) public virtual requiresAuth {
        _setUserMultiRole(account_, roles_, enabled_);
    }

    function canCall(
        address account_,
        address target_,
        bytes4 fnSig_
    ) public view virtual override returns (bool yes) {
        return
            isPublicAccess(target_, fnSig_) ||
            viewAccountRoles(account_) & viewAccessibleRoles(target_, fnSig_) !=
            0;
    }

    function viewAccessibleRoles(
        address target_,
        bytes4 fnSig_
    ) public view virtual returns (bytes32 roleAccessBitmap) {
        assembly {
            mstore(0x00, target_)
            mstore(0x20, _ROLE_ACCESS_SLOT)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, fnSig_)

            roleAccessBitmap := sload(keccak256(0x00, 0x40))
        }
    }

    function viewAccountRoles(
        address account_
    ) public view virtual returns (bytes32 roleBitMap) {
        assembly {
            mstore(0x00, account_)
            mstore(0x20, _USER_ROLES_SLOT)

            roleBitMap := sload(keccak256(0x00, 0x40))
        }
    }

    function isPublicAccess(
        address target_,
        bytes4 fnSig_
    ) public view virtual returns (bool yes) {
        assembly {
            mstore(0x00, target_)
            mstore(0x20, _PUBLIC_ACCESS_SLOT)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, fnSig_)
            yes := and(sload(keccak256(0x00, 0x40)), 0xff)
        }
    }

    function doesRoleHaveAccess(
        address target_,
        bytes4 fnSig_,
        uint8 role_
    ) public view virtual returns (bool yes) {
        assembly {
            mstore(0x00, target_)
            mstore(0x20, _ROLE_ACCESS_SLOT)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, fnSig_)
            yes := iszero(
                iszero(and(1, shr(role_, sload(keccak256(0x00, 0x40)))))
            )
        }
    }

    function doesAccountHaveRole(
        address account_,
        uint8 role_
    ) public view returns (bool yes) {
        assembly {
            mstore(0x00, account_)
            mstore(0x20, _USER_ROLES_SLOT)

            yes := iszero(
                iszero(and(1, shr(role_, sload(keccak256(0x00, 0x40)))))
            )
        }
    }

    function _setRoleAccess(
        uint8 role_,
        address target_,
        bytes4 fnSig_,
        bool enabled_
    ) internal virtual {
        bytes32 roleAccessUpdated = RoleAccessUpdated.selector;

        assembly {
            mstore(0x00, target_)
            mstore(0x20, _ROLE_ACCESS_SLOT)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, fnSig_)

            let key := keccak256(0x00, 0x40)
            let roleAccessBitmap := sload(key)

            let bit := and(shr(role_, roleAccessBitmap), 1)
            bit := xor(bit, enabled_)
            sstore(key, xor(shl(role_, bit), roleAccessBitmap))

            mstore(0x00, enabled_)
            log4(0x00, 0x20, roleAccessUpdated, role_, target_, fnSig_)
        }
    }

    function _setPublicAccess(
        address target_,
        bytes4 fnSig_,
        bool enabled_
    ) internal virtual {
        bytes32 publicAccessUpdated = PublicAccessUpdated.selector;

        assembly {
            mstore(0x00, target_)
            mstore(0x20, _PUBLIC_ACCESS_SLOT)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, fnSig_)
            sstore(keccak256(0x00, 0x40), enabled_)

            mstore(0x00, enabled_)
            log3(0x00, 0x20, publicAccessUpdated, target_, fnSig_)
        }
    }

    function _setUserRole(
        address account_,
        uint8 role_,
        bool enabled_
    ) internal virtual {
        bytes32 userRoleUpdated = UserRoleUpdated.selector;

        assembly {
            mstore(0x00, account_)
            mstore(0x20, _USER_ROLES_SLOT)

            let key := keccak256(0x00, 0x40)
            let roleBitMap := sload(key)
            let bit := and(shr(role_, roleBitMap), 1)
            bit := xor(bit, enabled_)
            sstore(key, xor(shl(role_, bit), roleBitMap))

            mstore(0x00, enabled_)
            log3(0x00, 0x20, userRoleUpdated, account_, role_)
        }
    }

    function _setUserMultiRole(
        address account_,
        uint256 roles_,
        bool enable_
    ) internal virtual {
        bytes32 userRoleUpdate = UserRoleUpdated.selector;

        assembly {
            mstore(0x00, account_)
            mstore(0x20, _USER_ROLES_SLOT)

            let key := keccak256(0x00, 0x40)
            sstore(key, roles_)

            mstore(0x00, enable_)
            log3(0x00, 0x20, userRoleUpdate, account_, roles_)
        }
    }
}
