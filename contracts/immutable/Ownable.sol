// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {OwnableCore} from "../core/auth/OwnableCore.sol";

abstract contract Ownable is OwnableCore {
    constructor() payable {
        _transferOwnership(msg.sender);
    }
}
