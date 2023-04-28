// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.10;

import {
    ERC721Upgradeable,
    IERC165Upgradeable,
    IERC721Upgradeable
} from "../ERC721Upgradeable.sol";

interface IERC721BurnableUpgradeable is IERC721Upgradeable {
    error ERC721Burnable__OnlyOwnerOrApproved();

    function burn(uint256 tokenId) external;
}

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be burned (destroyed).
 */

abstract contract ERC721BurnableUpgradeable is
    ERC721Upgradeable,
    IERC721BurnableUpgradeable
{
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        if (!_isApprovedOrOwner(_msgSender(), tokenId))
            revert ERC721Burnable__OnlyOwnerOrApproved();
        _burn(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId_
    )
        public
        view
        virtual
        override(ERC721Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId_ == type(IERC721BurnableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId_);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
