// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.17;

import {ERC20Upgradeable} from "../ERC20Upgradeable.sol";

import {IERC20PermitUpgradeable} from "./IERC20PermitUpgradeable.sol";

import {ECDSAUpgradeable, EIP712Upgradeable} from "../../../utils/cryptography/EIP712Upgradeable.sol";

import {IncrementalNonce} from "../../../../../../libraries/structs/IncrementalNonce.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20PermitUpgradeable is
    ERC20Upgradeable,
    EIP712Upgradeable,
    IERC20PermitUpgradeable
{
    using ECDSAUpgradeable for bytes32;
    using IncrementalNonce for IncrementalNonce.Nonce;

    // solhint-disable-next-line var-name-mixedcase
    /// @dev value is equal to keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
    bytes32 private constant __PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    IncrementalNonce.Nonce private __nonces;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    function __ERC20Permit_init(
        string calldata name_
    ) internal onlyInitializing {
        __EIP712_init_unchained(name_, "1");
    }

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override {
        bytes32 digest;
        bytes32 allowanceKey;
        assembly {
            // if (block.timestamp > deadline) revert ERC20Permit__Expired();
            if gt(timestamp(), deadline) {
                mstore(0x00, 0x614fe41d)
                revert(0x1c, 0x04)
            }
            mstore(0x00, owner)
            mstore(0x20, __nonces.slot)
            let nonceKey := keccak256(0x00, 0x40)
            let nonce := sload(nonceKey)

            let freeMemPtr := mload(0x40)

            mstore(freeMemPtr, __PERMIT_TYPEHASH)
            mstore(add(freeMemPtr, 0x20), owner)
            mstore(add(freeMemPtr, 0x40), spender)
            mstore(add(freeMemPtr, 0x60), value)
            mstore(add(freeMemPtr, 0x80), nonce)
            mstore(add(freeMemPtr, 0xa0), deadline)
            digest := keccak256(freeMemPtr, 0xc0)

            sstore(nonceKey, add(1, nonce))

            mstore(0x20, _allowance.slot)
            allowanceKey := keccak256(0x00, 0x40)
        }

        if (_hashTypedDataV4(digest).recover(v, r, s) != owner)
            revert ERC20Permit__InvalidSignature();

        assembly {
            mstore(0x00, spender)
            mstore(0x20, allowanceKey)
            sstore(keccak256(0x00, 0x40), value)
        }
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     *

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR()
        external
        view
        override(IERC20PermitUpgradeable)
        returns (bytes32)
    {
        return _domainSeparatorV4();
    }

    function nonces(address account_) external view returns (uint256) {
        bytes32 bytes32Account;
        assembly {
            bytes32Account := account_
        }
        return __nonces.viewNonce(bytes32Account);
    }

    uint256[50] private __gap;
}
