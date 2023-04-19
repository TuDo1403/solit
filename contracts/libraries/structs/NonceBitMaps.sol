// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library NonceBitMaps {
    error NonceBitMaps__UsedNonce();

    struct NonceBitMap {
        mapping(uint256 => mapping(uint248 => uint256)) bitmap;
    }

    event NonceInvalidated(
        address indexed operator,
        address indexed account,
        uint256 indexed mask,
        uint248 wordPos
    );

    function viewBitMap(
        NonceBitMap storage nonces_,
        uint256 id_,
        uint256 nonce_
    ) internal view returns (uint256 bitmap, bool isDirtied) {
        assembly {
            mstore(0x00, id_)
            mstore(0x20, nonces_.slot)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(
                0x00,
                and(
                    shr(8, nonce_),
                    0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
                )
            )

            bitmap := sload(keccak256(0x00, 0x40))
            isDirtied := iszero(iszero(and(bitmap, shl(and(nonce_, 0xff), 1))))
        }
    }

    function invalidateNonce(
        NonceBitMap storage nonces_,
        uint256 id_,
        uint248 wordPos_,
        uint256 mask_
    ) internal {
        assembly {
            mstore(0x00, id_)
            mstore(0x20, nonces_.slot)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, wordPos_)
            let key := keccak256(0x00, 0x40)
            let bitmap := sload(key)
            sstore(key, or(bitmap, mask_))

            log4(
                0x00,
                0x20,
                /// @dev value is equal to keccak256("NonceInvalidated(address,address,uint256,uint248)")
                0xbf4e037492f2908c41fc490206d013ce01387b49ffd7615fcabee58deb60f7d0,
                caller(),
                id_,
                mask_
            )
        }
    }

    function invalidateNonce(
        NonceBitMap storage nonces_,
        address sender_,
        uint256 id_,
        uint256 nonce_
    ) internal {
        assembly {
            mstore(0x00, id_)
            mstore(0x20, nonces_.slot)
            mstore(0x20, keccak256(0x00, 0x40))
            let wordPos := and(
                shr(8, nonce_),
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
            mstore(0x00, wordPos)
            let key := keccak256(0x00, 0x40)
            let bitmap := sload(key)
            let bitPosMask := shl(and(nonce_, 0xff), 1)

            if iszero(iszero(and(bitmap, bitPosMask))) {
                mstore(0x00, 0x3279120a)
                revert(0x1c, 0x04)
            }
            sstore(key, or(bitmap, bitPosMask))

            log4(
                0x00,
                0x20,
                /// @dev value is equal to keccak256("NonceInvalidated(address,address,uint256,uint248)")
                0xbf4e037492f2908c41fc490206d013ce01387b49ffd7615fcabee58deb60f7d0,
                sender_,
                id_,
                bitPosMask
            )
        }
    }
}
