// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IExecutable {
    struct CallParams {
        address to;
        uint256 value;
        bytes4 fnSelector;
        bytes args;
    }

    event Executed(address indexed operator, bytes result);

    function execute(
        bytes calldata data_,
        CallParams calldata callParams_
    ) external;
}
