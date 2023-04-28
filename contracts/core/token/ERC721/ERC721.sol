// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ERC721 {
    bytes32 internal constant SLOT_SEED =
        0xf6353f22112861aa000000000000000000000000000000000000000000000000;

    /// @dev `keccak256(bytes("Transfer(address,address,uint256)"))`.
    bytes32 private constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    /// @dev `keccak256(bytes("Approval(address,address,uint256)"))`.
    bytes32 private constant _APPROVAL_EVENT_SIGNATURE =
        0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    /// @dev `keccak256(bytes("ApprovalForAll(address,address,bool)"))`.
    bytes32 private constant _APPROVAL_FOR_ALL_EVENT_SIGNATURE =
        0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31;

    function totalSupply() public view returns (uint256 supply) {
        assembly ("memory-safe") {
            mstore(0x00, SLOT_SEED)
            supply := sload(keccak256(0x18, 0x08))
        }
    }

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        assembly ("memory-safe") {
            mstore(0x1c, SLOT_SEED)
            let slot := add(id, add(id, keccak256(0x00, 0x20)))
            owner := and(
                sload(slot),
                0xffffffffffffffffffffffffffffffffffffffff
            )
        }
    }

    function balanceOf(
        address owner
    ) public view virtual returns (uint256 amount) {
        assembly ("memory-safe") {
            mstore(0x00, owner)
            mstore(0x1c, SLOT_SEED)
            let slot := keccak256(0x0c, 0x1c)
            amount := and(sload(slot), 0xffffffff)
        }
    }

    function getApproved(
        uint256 id
    ) public view virtual returns (address approval) {
        assembly ("memory-safe") {
            mstore(0x1c, SLOT_SEED)
            let slot := add(1, add(id, add(id, keccak256(0x00, 0x20))))
            approval := and(
                sload(slot),
                0xffffffffffffffffffffffffffffffffffffffff
            )
        }
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view virtual returns (bool approved) {
        assembly ("memory-safe") {
            mstore(0x00, owner)
            mstore(0x1c, or(SLOT_SEED, shr(8, operator)))
            let slot := keccak256(0x0c, 0x30)
            approved := and(sload(slot), shl(and(operator, 0xff), 1))
        }
    }

    function isApprovedOrOwner(
        address spender,
        uint256 id
    ) internal view virtual returns (bool approved) {
        assembly {
            approved := 1

            mstore(0x00, id)
            mstore(0x1c, or(SLOT_SEED, shr(8, spender)))
            let slot := add(id, add(id, keccak256(0x00, 0x20)))
            let owner := and(
                sload(slot),
                0xffffffffffffffffffffffffffffffffffffffff
            )

            if iszero(owner) {
                mstore(0x00, 0xceea21b6) // `TokenDoesNotExist()`.
                revert(0x1c, 0x04)
            }

            if iszero(eq(owner, spender)) {
                mstore(0x00, owner)

                if iszero(sload(keccak256(0x0c, 0x30))) {
                    approved := eq(spender, sload(add(1, slot)))
                }
            }
        }
    }
}
