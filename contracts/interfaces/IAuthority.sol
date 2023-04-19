// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IAuthority {
    function canCall(
        address account_,
        address target_,
        bytes4 fnSig_
    ) external view returns (bool);
}
