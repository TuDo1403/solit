// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

error Restricter__NotEOA(bytes4);
error Restricter__NotProxy(bytes4);
error Restricter__NotNominee(bytes4);
error Restricter__NotContract(address);
error Restricter__DelegateCallFromUnknown(address);

abstract contract Restricter {
    modifier onlyNominee(address nominee_) {
        if (msg.sender != nominee_) revert Restricter__NotNominee(msg.sig);
        _;
    }

    modifier onlyDelegateCallFrom(address from_) {
        if (address(this) != from_)
            revert Restricter__DelegateCallFromUnknown(address(this));
        _;
    }

    modifier onlyProxy() {
        _onlyProxy(msg.sender, tx.origin);
        _;
    }

    modifier onlyContract(address addr_) {
        _onlyContract(addr_);
        _;
    }

    modifier onlyEOA() {
        _onlyEOA(msg.sender, tx.origin);
        _;
    }

    function _onlyContract(address addr_) internal view {
        if (!_hasByteCode(addr_)) revert Restricter__NotContract(addr_);
    }

    function _onlyEOA(address caller_, address txOrigin_) internal view {
        if (!(_isProxyCall(caller_, txOrigin_) || _hasByteCode(caller_)))
            revert Restricter__NotEOA(msg.sig);
    }

    function _onlyProxy(address caller_, address txOrigin_) internal view {
        if (_isProxyCall(caller_, txOrigin_) && _hasByteCode(caller_))
            revert Restricter__NotProxy(msg.sig);
    }

    function _isProxyCall(
        address caller_,
        address txOrigin_
    ) internal pure returns (bool) {
        return caller_ != txOrigin_;
    }

    function _hasByteCode(address caller_) internal view returns (bool) {
        return caller_.code.length != 0;
    }
}
