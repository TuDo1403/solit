// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IOwnable, OwnableCore} from "./OwnableCore.sol";

import {IAuthority, IAuthAccess} from "./interfaces/IAuthAccess.sol";

abstract contract AuthAccessCore is IAuthAccess, OwnableCore {
    /// @dev value is equal to keccak256("AuthAccess.AUTHORITY_SLOT) - 1
    bytes32 internal constant _AUTHORITY_SLOT =
        0x84b22b40126a5d2d10aeb2adf5f1589503ea5d04fc8cfe833bd93811a543ac37;

    modifier requiresAuth() virtual {
        _requireAuth(msg.sender, msg.sig);
        _;
    }

    modifier nonZeroAddress(address addr_) virtual {
        _nonZeroAddress(addr_);
        _;
    }

    function setAuthority(IAuthority authority_) external {
        IAuthority _authority = authority();

        if (
            !(msg.sender == owner() ||
                (address(_authority) != address(0) &&
                    authority().canCall(msg.sender, address(this), msg.sig)))
        ) revert Unauthorized();

        _setAuthority(authority_);
    }

    function authority() public view returns (IAuthority _authority) {
        assembly {
            _authority := sload(_AUTHORITY_SLOT)
        }
    }

    function isAuthorized(
        address sender_,
        bytes4 fnSig_
    ) public view virtual returns (bool) {
        IAuthority _authority = authority();

        return
            (address(_authority) != address(0) &&
                _authority.canCall(sender_, address(this), fnSig_)) ||
            sender_ == owner();
    }

    function _setAuthority(
        IAuthority authority_
    ) internal nonZeroAddress(address(authority_)) {
        assembly {
            log4(
                0x00,
                0x00,
                /// @dev value is equal to keccak256("AuthorityUpdated(address,address,address)")
                0x6751992d0b63f06bf00f0e1b96ce6fa79f41ca798b8fbcb60458b69f50a90227,
                caller(),
                sload(_AUTHORITY_SLOT),
                authority_
            )

            sstore(_AUTHORITY_SLOT, authority_)
        }
    }

    function _requireAuth(
        address sender_,
        bytes4 fnSig_
    ) internal view virtual {
        if (!isAuthorized(sender_, fnSig_)) revert Unauthorized();
    }

    function _nonZeroAddress(address address_) internal pure {
        assembly {
            if iszero(address_) {
                mstore(0x00, 0xcdf31543)
                revert(0x1c, 0x04)
            }
        }
    }
}
