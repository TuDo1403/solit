// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ErrorHandler} from "../libraries/ErrorHandler.sol";

abstract contract Anouncer {
    using ErrorHandler for bool;

    function anounce(
        address target,
        bytes4 fnSig,
        bytes memory data
    ) external virtual {
        _anounce(target, fnSig, data);
    }

    function _anounce(
        address target,
        bytes4 fnSig,
        bytes memory data
    ) internal {
        (bool anounced, bytes memory returnOrRevertData) = target.call(abi.encode(fnSig, data));
        anounced.handleRevertIfNotSuccess(returnOrRevertData);
    }
}
