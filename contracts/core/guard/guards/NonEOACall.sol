// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract NonEOACall {
    error EOACallNotAllowed();

    modifier requiresProxyCall() {
        _requiresProxyCall();
        _;
    }

    function _requiresProxyCall() internal view {
        bytes4 eoaCallNotAllowed = EOACallNotAllowed.selector;
        assembly {
            if iszero(extcodesize(caller())) {
                mstore(0x00, eoaCallNotAllowed)
                revert(0x1c, 0x04)
            }
        }
    }
}
