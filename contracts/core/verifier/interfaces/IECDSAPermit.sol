// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IECDSAPermit {
    error InvalidNonce();
    error InvalidSigner();
    error SignatureExpired();

    struct Permission {
        address signer;
        uint256 nonce;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
