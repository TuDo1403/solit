// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract NonProxyCall {
    error ProxyCallNotAllowed();

    modifier requiresEOA() virtual {
        _requiresEOA();
        _;
    }

    function _requiresEOA() internal view {
        assembly {
            if iszero(eq(caller(), origin())) {
                mstore(0x00, 0xe110c0ee)
                revert(0x1c, 0x04)
            }
        }
    }
}
