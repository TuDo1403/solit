// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IOwnable} from "./interfaces/IOwnable.sol";

abstract contract OwnableCore is IOwnable {
    /// @dev value is equal to keccak256("Ownable.OWNER_SLOT") - 1
    bytes32 internal constant _OWNER_SLOT =
        0xc11737fa88dc82e46fb4444e4004e044170ea65e56bf0326474fd34525b0be38;

    modifier onlyOwner() virtual {
        _checkOwner(msg.sender);
        _;
    }

    function transferOwnership(address account_) external onlyOwner {
        _transferOwnership(account_);
    }

    function owner() public view returns (address _owner) {
        assembly {
            _owner := sload(_OWNER_SLOT)
        }
    }

    function _transferOwnership(address account_) internal {
        bytes32 ownershipTransferred = OwnershipTransferred.selector;
        assembly {
            sstore(_OWNER_SLOT, account_)

            log3(0x00, 0x00, ownershipTransferred, caller(), account_)
        }
    }

    function _checkOwner(address account_) internal view {
        bytes4 unauthorized = Unauthorized.selector;

        assembly {
            if iszero(eq(sload(_OWNER_SLOT), account_)) {
                mstore(0x00, unauthorized)
                revert(0x1c, 0x04)
            }
        }
    }
}
