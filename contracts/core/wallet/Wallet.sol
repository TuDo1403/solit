// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AuthAccessCore} from "../auth/AuthAccessCore.sol";

import {ECDSAPermitCore} from "../verifier/ECDSAPermitCore.sol";

import {IncrementalNonce} from "../../libraries/udvts/Types.sol";

import {ErrorHandler} from "../../libraries/ErrorHandler.sol";

library LibTx {
    using ErrorHandler for bool;

    struct Tx {
        address from;
        address to;
        uint256 value;
        bytes data;
    }

    bytes32 internal constant TYPE_HASH =
        0x9c37571f9b7f2d3d74e78b92532dda9ffd32b8c68ffc1b7736818a7f5a7bb2b5;

    function hash(Tx calldata tx_) internal pure returns (bytes32 digest) {
        digest = keccak256(
            abi.encode(TYPE_HASH, tx_.from, tx_.to, tx_.value, tx_.data)
        );
    }

    function execute(
        Tx calldata tx_
    ) internal returns (bool ok, bytes memory data) {
        (ok, data) = tx_.to.call{value: tx_.value}(tx_.data);
        ok.handleRevertIfNotSuccess(data);
    }
}

abstract contract WalletCore is AuthAccessCore, ECDSAPermitCore {
    using LibTx for LibTx.Tx;

    IncrementalNonce internal constant NONCE =
        IncrementalNonce.wrap(
            0xd3632a9d45e3e9b6ac299a56cded7147103d04ffa4e9de369a28ba70cc2fb476
        );

    function _invalidateNonce(
        bytes32 key_,
        bytes32 typeHash_
    ) internal virtual override {
        if (typeHash_ == LibTx.TYPE_HASH) {
            NONCE.increment(key_);
        } else revert InvalidSigner();
    }

    function execute(
        LibTx.Tx calldata tx_,
        Permission calldata permission_
    )
        external
        payable
        virtual
        requiresAuth
        validateSignature(LibTx.TYPE_HASH, tx_.hash(), permission_)
        returns (bool success, bytes memory returnData)
    {
        (success, returnData) = tx_.execute();
    }
}
