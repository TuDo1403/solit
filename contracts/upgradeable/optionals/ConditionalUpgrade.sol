// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Restricter} from "../../utils/Restricter.sol";
import {GasStipned} from "../../utils/GasStipned.sol";
import {ErrorHandler} from "../../libraries/ErrorHandler.sol";
import {ERC1967Upgrade} from "../../core/proxy/ERC1967/ERC1967Upgrade.sol";

interface IConditionalUpgrade {
    // Log when revert or require
    event Log(string msg);

    error ConditionalUpgrade__AddressNotUnique();

    /**
     * @dev Executes the selfUpgrade function, upgrading to the new contract implementation.
     */
    function selfUpgrade() external;
}

abstract contract ConditionalUpgrade is
    Restricter,
    GasStipned,
    ERC1967Upgrade,
    IConditionalUpgrade
{
    using ErrorHandler for bool;

    address public immutable PROXY;
    address public immutable NEW_IMPLEMENT;
    address public immutable PREV_IMPLEMENT;

    modifier whenSatisfied() {
        _;
        if (_isSatisfy()) {
            try this.selfUpgrade{gas: _gasStipned()}() {} catch Error(
                string memory reason
            ) {
                emit Log(reason);
            }
        }
    }

    constructor(
        address proxy_,
        address newImplement_,
        address prevImplement_
    )
        onlyContract(proxy_)
        onlyContract(newImplement_)
        onlyContract(prevImplement_)
    {
        if (_areUnique(proxy_, newImplement_, prevImplement_))
            revert ConditionalUpgrade__AddressNotUnique();

        PROXY = proxy_;
        NEW_IMPLEMENT = newImplement_;
        PREV_IMPLEMENT = prevImplement_;
    }

    fallback() external payable virtual onlyDelegateCallFrom(PROXY) {
        _fallback();
    }

    receive() external payable virtual onlyDelegateCallFrom(PROXY) {
        _fallback();
    }

    function selfUpgrade()
        external
        onlyNominee(PROXY)
        onlyDelegateCallFrom(PROXY)
    {
        _upgradeTo(NEW_IMPLEMENT);
    }

    function _areUnique(
        address proxy_,
        address newImpl_,
        address prevImpl_
    ) internal pure returns (bool) {
        return
            !(proxy_ == newImpl_ ||
                proxy_ == prevImpl_ ||
                newImpl_ == prevImpl_);
    }

    function _isSatisfy() internal view virtual returns (bool) {}

    function _getCurrentImplementation()
        internal
        view
        virtual
        returns (address)
    {
        return _isSatisfy() ? NEW_IMPLEMENT : PREV_IMPLEMENT;
    }

    function _fallback() internal virtual {
        bytes memory returnData = _dispatchCall(_getCurrentImplementation());
        assembly {
            return(add(returnData, 0x20), mload(returnData))
        }
    }

    function _dispatchCall(
        address impl_
    ) internal virtual whenSatisfied returns (bytes memory result) {
        (bool success, bytes memory data) = impl_.delegatecall(msg.data);
        success.handleRevertIfNotSuccess(data);
        assembly {
            result := data
        }
    }
}
