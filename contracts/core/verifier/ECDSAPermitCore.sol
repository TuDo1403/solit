// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {EIP712} from "../EIP/EIP712.sol";

import {IECDSAPermit} from "./interfaces/IECDSAPermit.sol";

import {ECDSA} from "../../libraries/cryptography/ECDSA.sol";

abstract contract ECDSAPermitCore is EIP712, IECDSAPermit {
    using ECDSA for bytes32;

    modifier validateSignature(
        bytes32 typeHash_,
        bytes32 structHash_,
        Permission memory permission_
    ) virtual {
        _validateSignature(typeHash_, structHash_, permission_);
        _;
    }

    function _invalidateNonce(bytes32 key_, bytes32 typeHash_) internal virtual;

    function _validateSignature(
        bytes32 typeHash_,
        bytes32 structHash_,
        Permission memory permission_
    ) internal virtual {
        if (permission_.deadline < block.timestamp) revert SignatureExpired();

        if (!_isValidNonce(typeHash_, permission_)) revert InvalidNonce();

        _invalidateNonce(typeHash_, bytes32(bytes20(permission_.signer)));

        bytes32 digest = _hashTypedData(structHash_);

        address signer = digest.recover(
            permission_.v,
            permission_.r,
            permission_.s
        );

        if (!_isValidSigner(signer, permission_.signer)) revert InvalidSigner();
    }

    function _isValidSigner(
        address signer,
        address verifier
    ) internal view virtual returns (bool isValid) {
        isValid = signer == verifier;
    }

    function _isValidNonce(
        bytes32 typeHash_,
        Permission memory permission_
    ) internal view virtual returns (bool isValid);
}
