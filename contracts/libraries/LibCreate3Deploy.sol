// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library LibCreate3Deploy {
    error DeploymentFailed();
    error InitializationFailed();
    //--------------------------------------------------------------------------------//
    // Opcode     | Opcode + Arguments    | Description      | Stack View             //
    //--------------------------------------------------------------------------------//
    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 0 size               //
    // 0x37       |  0x37                 | CALLDATACOPY     |                        //
    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //
    // 0x34       |  0x34                 | CALLVALUE        | value 0 size           //
    // 0xf0       |  0xf0                 | CREATE           | newContract            //
    // 0xff       |  0xff                 | SELFDESTRUCT     |                        //
    //--------------------------------------------------------------------------------//
    // Opcode     | Opcode + Arguments    | Description      | Stack View             //
    //--------------------------------------------------------------------------------//
    // 0x67       |  0x67XXXXXXXXXXXXXXXX | PUSH8 bytecode   | bytecode               //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 bytecode             //
    // 0x52       |  0x52                 | MSTORE           |                        //
    // 0x60       |  0x6008               | PUSH1 08         | 8                      //
    // 0x60       |  0x6018               | PUSH1 18         | 24 8                   //
    // 0xf3       |  0xf3                 | RETURN           |                        //
    //--------------------------------------------------------------------------------//
    uint256 internal constant PROXY_BYTECODE =
        0x630000000980600e6000396000f3363d8037363d34f0ff;

    /// @dev value is equal to keccak256(PROXY_BYTECODE)
    bytes32 internal constant PROXY_BYTECODE_HASH =
        0x68afe50fe78ae96feb6ec11f21f31fdd467c9fcc7add426282cfa3913daf04e9;

    function deploy(
        bytes32 salt,
        bytes memory creationCode,
        uint256 value
    ) internal returns (address deployed) {
        /// @solidity memory-safe-assembly
        assembly {
            // Store the `_PROXY_BYTECODE` into scratch space.
            // Deploy a new contract with our pre-made bytecode via CREATE2.
            mstore(0x00, PROXY_BYTECODE)
            let proxy := create2(0, 0x09, 0x17, salt)

            // If the result of `create2` is the zero address, revert.
            if iszero(proxy) {
                // Store the function selector of `DeploymentFailed()`.
                mstore(0x00, 0x30116425)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Store the proxy's address.
            mstore(0x14, proxy)
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
            mstore(0x00, 0xd694)
            // Nonce of the proxy contract (1).
            mstore8(0x34, 0x01)

            deployed := keccak256(0x1e, 0x17)

            // If the `call` fails, revert.
            if iszero(
                call(
                    gas(), // Gas remaining.
                    proxy, // Proxy's address.
                    value, // Ether value.
                    add(creationCode, 0x20), // Start of `creationCode`.
                    mload(creationCode), // Length of `creationCode`.
                    0x00, // Offset of output.
                    0x00 // Length of output.
                )
            ) {
                // Store the function selector of `InitializationFailed()`.
                mstore(0x00, 0x19b991a8)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // If the code size of `deployed` is zero, revert.
            if iszero(extcodesize(deployed)) {
                // Store the function selector of `InitializationFailed()`.
                mstore(0x00, 0x19b991a8)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }
    }

    function getDeployed(
        bytes32 salt
    ) internal view returns (address deployed) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cache the free memory pointer.
            let m := mload(0x40)
            // Store `address(this)`.
            mstore(0x00, address())
            // Store the prefix.
            mstore8(0x0b, 0xff)
            // Store the salt.
            mstore(0x20, salt)
            // Store the bytecode hash.
            mstore(0x40, PROXY_BYTECODE_HASH)

            // Store the proxy's address.
            mstore(0x14, keccak256(0x0b, 0x55))
            // Restore the free memory pointer.
            mstore(0x40, m)
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
            mstore(0x00, 0xd694)
            // Nonce of the proxy contract (1).
            mstore8(0x34, 0x01)

            deployed := keccak256(0x1e, 0x17)
        }
    }
}
