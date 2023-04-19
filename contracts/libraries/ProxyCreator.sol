// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Bytes32Address} from "./Bytes32Address.sol";

error ProxyCreator__DeploymentFailed();
error ProxyCreator__InitializationFailed();

library ProxyCreator {
    using Bytes32Address for bytes32;

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
    bytes internal constant PROXY_BYTECODE =
        hex"63_00_00_00_09_80_60_0E_60_00_39_60_00_F3_36_3d_80_37_36_3d_34_f0_ff";

    /// @dev value is equal to keccak256(PROXY_BYTECODE)
    bytes32 internal constant PROXY_BYTECODE_HASH =
        0x68afe50fe78ae96feb6ec11f21f31fdd467c9fcc7add426282cfa3913daf04e9;

    function deploy(
        bytes32 salt,
        bytes memory creationCode,
        uint256 value
    ) internal returns (address deployed) {
        bytes memory proxyChildBytecode = PROXY_BYTECODE;

        address proxy;
        assembly {
            // Deploy a new contract with our pre-made bytecode via CREATE2.
            // We start 32 bytes into the code to avoid copying the byte length.
            proxy := create2(
                0,
                add(proxyChildBytecode, 32),
                mload(proxyChildBytecode),
                salt
            )
        }
        if (proxy == address(0)) revert ProxyCreator__DeploymentFailed();

        deployed = getDeployed(salt);
        (bool success, ) = proxy.call{value: value}(creationCode);
        if (!success || deployed.code.length == 0)
            revert ProxyCreator__InitializationFailed();
    }

    function getDeployed(bytes32 salt) internal view returns (address) {
        address proxy = keccak256(
            abi.encodePacked(
                // Prefix:
                bytes1(0xFF),
                // Creator:
                address(this),
                // Salt:
                salt,
                // Bytecode hash:
                PROXY_BYTECODE_HASH
            )
        ).fromFirst20Bytes();

        return
            keccak256(
                abi.encodePacked(
                    // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01)
                    // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex)
                    hex"d6_94",
                    proxy,
                    hex"01" // Nonce of the proxy contract (1)
                )
            ).fromFirst20Bytes();
    }
}
