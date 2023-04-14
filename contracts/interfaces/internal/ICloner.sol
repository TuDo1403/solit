// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICloner {
    event Cloned(
        address indexed cloner,
        address implement,
        address indexed clone,
        bytes32 indexed salt
    );

    event ImplementChanged(address indexed from, address indexed to);

    /**
     * @notice Changes the contract's implementation address
     * @param implement_ The new implementation address
     */
    function setImplement(address implement_) external;

    /**
     * @notice Returns the contract's implementation address
     * @return The implementation address
     */
    function implement() external view returns (address);

    /**
     * @notice Returns all cloned contract instances of the given implementation address
     * @param implement_ The implementation address
     * @return clones The array of cloned contract instances
     */
    function allClonesOf(
        address implement_
    ) external view returns (address[] memory clones);
}
