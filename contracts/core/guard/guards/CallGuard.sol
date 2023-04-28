// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract CallGuard {
    error EOACallNotAllowed();
    error ProxyCallNotAllowed();

    modifier requiresEOA() virtual {
        _requiresEOA();
        _;
    }

    modifier requiresProxyCall() virtual {
        _requiresProxyCall();
        _;
    }

    function _requiresProxyCall() internal view virtual {
        bytes4 eoaCallNotAllowed = EOACallNotAllowed.selector;
        assembly {
            if iszero(extcodesize(caller())) {
                mstore(0x00, eoaCallNotAllowed)
                revert(0x1c, 0x04)
            }
        }
    }

    function _requiresEOA() internal view virtual {
        bytes4 proxyCallNotAllowed = ProxyCallNotAllowed.selector;
        assembly {
            if iszero(eq(caller(), origin())) {
                mstore(0x00, proxyCallNotAllowed)
                revert(0x1c, 0x04)
            }
        }
    }
}
