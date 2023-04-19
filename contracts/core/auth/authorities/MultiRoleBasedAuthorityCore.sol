// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {RoleBasedAuthorityCore} from "./RoleBasedAuthorityCore.sol";

import {IAuthority, IRoleBasedAuthority, IMultiRoleBasedAuthority} from "./interfaces/IMultiRoleBasedAuthority.sol";

abstract contract MultiRoleBasedAuthorityCore is
    RoleBasedAuthorityCore,
    IMultiRoleBasedAuthority
{
    /// @dev value is equal to keccak256("MultiRoleBasedAuthority.AUTHORITIES_SLOT") - 1
    bytes32 internal constant _AUTHORITIES_SLOT =
        0x567903700b728b7d1481661007750909eb5423c42ae18f42c492fd33cf1d233b;

    function setTargetCustomAuthority(
        address target_,
        IAuthority authority_
    ) public virtual requiresAuth {
        _setTargetCustomAuthority(target_, authority_);
    }

    function canCall(
        address account_,
        address target_,
        bytes4 fnSig_
    )
        public
        view
        virtual
        override(IAuthority, RoleBasedAuthorityCore)
        returns (bool yes)
    {
        IAuthority customAuthority = viewTargetCustomAuthority(target_);

        if (address(customAuthority) != address(0))
            return customAuthority.canCall(account_, target_, fnSig_);

        return
            isPublicAccess(target_, fnSig_) ||
            viewAccountRoles(account_) & viewAccessibleRoles(target_, fnSig_) !=
            0;
    }

    function isPublicAccess(
        address,
        bytes4 fnSig_
    )
        public
        view
        virtual
        override(IRoleBasedAuthority, RoleBasedAuthorityCore)
        returns (bool yes)
    {
        assembly {
            mstore(0x00, fnSig_)
            mstore(0x20, _PUBLIC_ACCESS_SLOT)
            yes := and(sload(keccak256(0x00, 0x40)), 0xff)
        }
    }

    function viewTargetCustomAuthority(
        address target_
    ) public view virtual returns (IAuthority authority_) {
        assembly {
            mstore(0x00, target_)
            mstore(0x20, _AUTHORITIES_SLOT)

            authority_ := sload(keccak256(0x00, 0x40))
        }
    }

    function _setTargetCustomAuthority(
        address target_,
        IAuthority authority_
    ) internal {
        assembly {
            mstore(0x00, target_)
            mstore(0x20, _AUTHORITIES_SLOT)
            sstore(keccak256(0x00, 0x40), authority_)

            mstore(0x00, authority_)
            log2(
                0x00,
                0x20,
                0xa4908e11a5f895b13d51526c331ac93cdd30e59772361c5d07874eb36bff2065,
                target_
            )
        }
    }

    function _setPublicAccess(
        address target_,
        bytes4 fnSig_,
        bool enabled_
    ) internal virtual override {
        assembly {
            mstore(0x00, fnSig_)
            mstore(0x20, _PUBLIC_ACCESS_SLOT)
            sstore(keccak256(0x00, 0x40), enabled_)

            mstore(0x00, enabled_)
            log3(
                0x00,
                0x20,
                0xee8f874469bf0d6a975e6085f54b97c7f91e9230c3cfaa31f881cb5585c02d9b,
                target_,
                fnSig_
            )
        }
    }

    function _setRoleAccess(
        uint8 role_,
        address target_,
        bytes4 fnSig_,
        bool enabled_
    ) internal virtual override {
        assembly {
            mstore(0x00, fnSig_)
            mstore(0x20, _ROLE_ACCESS_SLOT)

            let key := keccak256(0x00, 0x40)
            let roleAccessBitmap := sload(key)

            if enabled_ {
                sstore(key, or(roleAccessBitmap, shl(role_, 1)))
            }

            if iszero(enabled_) {
                sstore(key, and(roleAccessBitmap, not(shl(role_, 1))))
            }

            mstore(0x00, enabled_)
            log4(
                0x00,
                0x20,
                0x302ddbd388fbb265296d4bcef3ef65012f6bdc349a36660eb3e330c6e18d055a,
                role_,
                target_,
                fnSig_
            )
        }
    }
}
