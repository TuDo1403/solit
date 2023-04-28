// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {SSTORE2} from "../../SSTORE2.sol";

import {ExternalMapping} from "../Types.sol";

library LibExternalMapping {
    using SSTORE2 for *;

    /// @dev value is equal to keccak256("ExternalMapping.STORAGE_SLOT") - 1
    bytes32 private constant STORAGE_SLOT =
        0xc5649bc44a9a4c03cd5bef9dc9ab9e1fdded92e183f84a944ca71619a7bd618a;

    function get(
        ExternalMapping slot,
        bytes32 key
    ) internal view returns (bytes memory) {
        address link;
        assembly {
            mstore(0x00, key)
            mstore(0x20, xor(slot, STORAGE_SLOT))
            link := sload(keccak256(0x00, 0x40))
        }
        return link.read();
    }

    function set(
        ExternalMapping slot,
        bytes32 key,
        bytes memory value
    ) internal returns (address link) {
        link = value.write();
        assembly {
            mstore(0x00, key)
            mstore(0x20, xor(slot, STORAGE_SLOT))
            sstore(keccak256(0x00, 0x40), link)
        }
    }
}
