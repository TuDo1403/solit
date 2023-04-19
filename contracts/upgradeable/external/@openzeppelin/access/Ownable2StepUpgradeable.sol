// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import {Initializable} from "../proxy/utils/Initializable.sol";
import {OwnableUpgradeable, Bytes32Address} from "./OwnableUpgradeable.sol";

interface IOwnable2StepUpgradeable {
    error Ownable2Step__CallerIsNotTheNewOwner();

    event OwnershipTransferStarted(
        address indexed previousOwner,
        address indexed newOwner
    );

    function pendingOwner() external view returns (address _pendingOwner);

    function acceptOwnership() external;
}

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2StepUpgradeable is
    Initializable,
    OwnableUpgradeable,
    IOwnable2StepUpgradeable
{
    using Bytes32Address for *;

    bytes32 private __pendingOwner;

    function __Ownable2Step_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return __pendingOwner.fromFirst20Bytes();
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(
        address newOwner_
    ) public virtual override onlyOwner {
        __pendingOwner = newOwner_.fillLast12Bytes();
        emit OwnershipTransferStarted(owner(), newOwner_);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete __pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() external {
        address sender = _msgSender();
        if (pendingOwner() != sender)
            revert Ownable2Step__CallerIsNotTheNewOwner();

        _transferOwnership(sender);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
