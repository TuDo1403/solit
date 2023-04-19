// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SigUtil {
    /**
     * @dev Merges the ECDSA values into a single signature bytes
     * @param v ECDSA recovery value
     * @param r ECDSA r value
     * @param s ECDSA s value
     * @return signature Combined signature bytes
     */
    function merge(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bytes memory signature) {
        signature = new bytes(65);
        assembly {
            mstore(add(signature, 0x20), r)
            mstore(add(signature, 0x40), s)
            mstore8(add(signature, 0x60), v)
        }
    }

    /**
     * @dev Splits the signature bytes into ECDSA values
     * @param signature_ Signature bytes to split
     * @return r s v Tuple of ECDSA values
     */
    function split(
        bytes calldata signature_
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        assembly {
            r := calldataload(signature_.offset)
            s := calldataload(add(signature_.offset, 0x20))
            v := byte(0, calldataload(add(signature_.offset, 0x40)))
        }
    }
}
