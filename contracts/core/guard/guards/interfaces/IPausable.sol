// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPausable {
    error StatusNotMet(bool status);

    event StatusUpdated(bool indexed paused);

    function toggle(bool paused_) external;

    function status() external view returns (bool paused);
}
