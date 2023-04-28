// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library IncrementalNonce {
    event NonceIncremented(
        address indexed operator,
        uint256 indexed from,
        uint256 indexed to
    );

    struct Nonce {
        mapping(bytes32 => uint256) data;
    }

    function viewNonce(
        Nonce storage nonces_,
        bytes32 key_
    ) internal view returns (uint256 nonce) {
        assembly {
            mstore(0x00, key_)
            mstore(0x20, nonces_.slot)
            nonce := sload(keccak256(0x00, 0x40))
        }
    }

    function incrementNonce(
        Nonce storage nonces_,
        address sender_,
        bytes32 key_
    ) internal returns (uint256 nonce) {
        bytes32 nonceIncremented = NonceIncremented.selector;

        assembly {
            mstore(0x00, key_)
            mstore(0x20, nonces_.slot)
            let key := keccak256(0x00, 0x40)
            nonce := sload(key)
            let nextNonce := add(1, nonce)
            sstore(key, nextNonce)

            log4(0x00, 0x00, nonceIncremented, sender_, nonce, nextNonce)
        }
    }
}
