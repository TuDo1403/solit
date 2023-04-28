// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ErrorHandler} from "./ErrorHandler.sol";

library LibTransaction {
    using ErrorHandler for bool;

    struct Transaction {
        address from;
        address to;
        uint256 value;
        uint256 gasLimit;
        uint256 nonce;
        uint256 deadline;
        bytes data;
    }

    function call(
        bool allowFail_,
        Transaction calldata tx_
    ) external returns (bool success, bytes memory returnOrRevertData) {
        bytes memory callData = tx_.data;
        assembly {
            let gasLimit := calldataload(add(tx_, 0x60))

            if iszero(gasLimit) {
                gasLimit := gas()
            }

            let freeMemPtr := mload(0x40)
            success := call(
                gas(),
                calldataload(add(tx_, 0x20)), // to
                calldataload(add(tx_, 0x40)), // value
                add(0x20, callData), // argOffset
                mload(callData), // argSize
                returnOrRevertData,
                returndatasize()
            )

            mstore(returnOrRevertData, returndatasize())
            mstore(add(0x20, returnOrRevertData), freeMemPtr)

            if iszero(success) {
                if iszero(iszero(returndatasize())) {
                    // Start of revert data bytes. The 0x20 offset is always the same.
                    revert(add(returnOrRevertData, 0x20), returndatasize())
                }

                //  revert ErrorHandler__ExecutionFailed()
                mstore(0x00, 0xa94eec76)
                revert(0x1c, 0x04)
            }
        }

        // (ok, returnOrRevertData) = tx_.to.call{
        //     value: tx_.value,
        //     gas: tx_.gasLimit != 0 ? gasleft() : tx_.gasLimit
        // }(tx_.data);
        // (ok || allowFail_).handleRevertIfNotSuccess(returnOrRevertData);
    }

    function staticcall(
        bool allowFail_,
        Transaction memory tx_
    ) external view returns (bool ok, bytes memory returnOrRevertData) {
        (ok, returnOrRevertData) = tx_.to.staticcall{
            gas: tx_.gasLimit != 0 ? gasleft() : tx_.gasLimit
        }(tx_.data);
        (ok || allowFail_).handleRevertIfNotSuccess(returnOrRevertData);
    }

    function delegatecall(
        bool allowFail_,
        Transaction calldata tx_
    ) external returns (bool ok, bytes memory returnOrRevertData) {
        (ok, returnOrRevertData) = tx_.to.delegatecall{
            gas: tx_.gasLimit != 0 ? gasleft() : tx_.gasLimit
        }(tx_.data);
        (ok || allowFail_).handleRevertIfNotSuccess(returnOrRevertData);
    }

    function selfDelegatecall(
        bool allowFail_,
        Transaction calldata tx_
    ) external returns (bool ok, bytes memory returnOrRevertData) {
        (ok, returnOrRevertData) = address(this).delegatecall{
            gas: tx_.gasLimit != 0 ? gasleft() : tx_.gasLimit
        }(tx_.data);
        (ok || allowFail_).handleRevertIfNotSuccess(returnOrRevertData);
    }

    function selfStaticcall(
        bool allowFail_,
        Transaction calldata tx_
    ) external view returns (bool ok, bytes memory returnOrRevertData) {
        (ok, returnOrRevertData) = address(this).staticcall{
            gas: tx_.gasLimit != 0 ? gasleft() : tx_.gasLimit
        }(tx_.data);
        (ok || allowFail_).handleRevertIfNotSuccess(returnOrRevertData);
    }
}
