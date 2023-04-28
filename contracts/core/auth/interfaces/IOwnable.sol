// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IOwnable {
    error Unauthorized();

    event OwnershipTransferred(
        address indexed operator,
        address indexed newOwner
    );

    function transferOwnership(address account_) external;

    function owner() external view returns (address _owner);
}
