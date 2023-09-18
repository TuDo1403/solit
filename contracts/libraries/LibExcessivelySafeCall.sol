// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @author Modified from ExcessivelySafeCall (https://github.com/nomad-xyz/ExcessivelySafeCall/blob/main/src/ExcessivelySafeCall.sol)
library LibExcessivelySafeCall {
    uint256 internal constant LOW_28_MASK =
        0x00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    /// @notice Use when you _really_ really _really_ don't trust the called
    /// contract. This prevents the called contract from causing reversion of
    /// the caller in as many ways as we can.
    /// @dev The main difference between this and a solidity low-level call is
    /// that we limit the number of bytes that the callee can cause to be
    /// copied to caller memory. This prevents stupid things like malicious
    /// contracts returning 10,000,000 bytes causing a local OOG when copying
    /// to memory.
    /// @param target The address to call
    /// @param gasStipend The amount of gas to forward to the remote contract
    /// @param value The value in wei to send to the remote contract
    /// @param maxCopy The maximum number of bytes of returndata to copy
    /// to memory.
    /// @param callData The data to send to the remote contract
    /// @return success and returndata, as `.call()`. Returndata is capped to
    /// `maxCopy` bytes.
    function excessivelySafeCall(
        address target,
        uint256 gasStipend,
        uint256 value,
        uint16 maxCopy,
        bytes memory callData
    ) internal returns (bool, bytes memory) {
        // set up for assembly call
        uint256 toCopy;
        bool success;
        bytes memory _returnData = new bytes(maxCopy);
        // dispatch message to recipient
        // by assembly calling "handle" function
        // we call via assembly to avoid memcopying a very large returndata
        // returned by a malicious contract
        assembly {
            success := call(
                gasStipend, // gas
                target, // recipient
                value, // ether value
                add(callData, 0x20), // inloc
                mload(callData), // inlen
                0, // outloc
                0 // outlen
            )
            // limit our copy to 256 bytes
            toCopy := returndatasize()
            if gt(toCopy, maxCopy) {
                toCopy := maxCopy
            }
            // Store the length of the copied bytes
            mstore(_returnData, toCopy)
            // copy the bytes from returndata[0:toCopy]
            returndatacopy(add(_returnData, 0x20), 0, toCopy)
        }
        return (success, _returnData);
    }

    /// @notice Use when you _really_ really _really_ don't trust the called
    /// contract. This prevents the called contract from causing reversion of
    /// the caller in as many ways as we can.
    /// @dev The main difference between this and a solidity low-level call is
    /// that we limit the number of bytes that the callee can cause to be
    /// copied to caller memory. This prevents stupid things like malicious
    /// contracts returning 10,000,000 bytes causing a local OOG when copying
    /// to memory.
    /// @param target The address to call
    /// @param gasStipend The amount of gas to forward to the remote contract
    /// @param maxCopy The maximum number of bytes of returndata to copy
    /// to memory.
    /// @param callData The data to send to the remote contract
    /// @return success and returndata, as `.call()`. Returndata is capped to
    /// `maxCopy` bytes.
    function excessivelySafeStaticCall(
        address target,
        uint256 gasStipend,
        uint16 maxCopy,
        bytes memory callData
    ) internal view returns (bool, bytes memory) {
        // set up for assembly call
        uint256 toCopy;
        bool success;
        bytes memory _returnData = new bytes(maxCopy);
        // dispatch message to recipient
        // by assembly calling "handle" function
        // we call via assembly to avoid memcopying a very large returndata
        // returned by a malicious contract
        assembly {
            success := staticcall(
                gasStipend, // gas
                target, // recipient
                add(callData, 0x20), // inloc
                mload(callData), // inlen
                0, // outloc
                0 // outlen
            )
            // limit our copy to 256 bytes
            toCopy := returndatasize()
            if gt(toCopy, maxCopy) {
                toCopy := maxCopy
            }
            // Store the length of the copied bytes
            mstore(_returnData, toCopy)
            // copy the bytes from returndata[0:toCopy]
            returndatacopy(add(_returnData, 0x20), 0, toCopy)
        }
        return (success, _returnData);
    }
}
