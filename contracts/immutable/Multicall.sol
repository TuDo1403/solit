// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Guard} from "./guard/Guard.sol";
import {OwnableCore} from "../core/auth/OwnableCore.sol";

import {ErrorHandler} from "../libraries/ErrorHandler.sol";

interface IMulticall {
    struct Calldata {
        address target;
        uint256 value;
        bytes params;
    }

    function batchQuery(
        Calldata[] calldata calldata_
    ) external view returns (bool[] memory success, bytes[] memory results);

    function multicall(
        bool allowFail_,
        Calldata[] calldata calldata_
    ) external payable returns (bool[] memory success, bytes[] memory results);
}

contract Multicall is Guard, OwnableCore, IMulticall {
    using ErrorHandler for bool;

    constructor() payable Guard() {
        _transferOwnership(msg.sender);
    }

    function toggle(bool paused_) external onlyOwner {
        _toggle(paused_);
    }

    function batchQuery(
        Calldata[] calldata calldata_
    )
        external
        view
        requiresStatus(false)
        restrictDelegate(false)
        returns (bool[] memory successes, bytes[] memory results)
    {
        uint256 length = calldata_.length;
        results = new bytes[](length);
        successes = new bool[](length);

        for (uint256 i; i < length; ) {
            (successes[i], results[i]) = calldata_[i].target.staticcall(
                calldata_[i].params
            );

            unchecked {
                ++i;
            }
        }
    }

    function multicall(
        bool allowFail_,
        Calldata[] calldata calldata_
    )
        external
        payable
        onlyOwner
        nonReentrant
        requiresStatus(false)
        restrictDelegate(false)
        returns (bool[] memory successes, bytes[] memory results)
    {
        uint256 length = calldata_.length;
        results = new bytes[](length);
        successes = new bool[](length);

        bool success;
        bytes memory result;

        for (uint256 i; i < length; ) {
            (success, result) = calldata_[i].target.call{
                value: calldata_[i].value
            }(calldata_[i].params);

            (allowFail_ || success).handleRevertIfNotSuccess(result);

            results[i] = result;
            successes[i] = success;

            unchecked {
                ++i;
            }
        }
    }
}
