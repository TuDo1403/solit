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

    function useNonce(
        Nonce storage nonces_,
        address sender_,
        bytes32 key_
    ) internal returns (uint256 nonce) {
        assembly {
            mstore(0x00, key_)
            mstore(0x20, nonces_.slot)
            let key := keccak256(0x00, 0x40)
            nonce := sload(key)
            let nextNonce := add(1, nonce)
            sstore(key, nextNonce)

            log4(
                0x00,
                0x00,
                /// @dev value is equal to keccak256("NonceIncremented(address,address,uint256)")
                0x2f90b6f628d763d0500def06c7670a4a6cacb6861e186a18dada779e8fb6be71,
                sender_,
                nonce,
                nextNonce
            )
        }
    }
}
