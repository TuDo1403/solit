// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICommitRevealer {
    error CommitRevealer__InvalidReveal();

    struct Commitment {
        bytes32 commitment;
        uint256 timePoint;
    }

    event Commited(
        address indexed submitter,
        bytes32 indexed commiment,
        uint256 indexed timePoint,
        bytes extraData
    );

    function commit(address from_, bytes32 commitment_) external;
}
