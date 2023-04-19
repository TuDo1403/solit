// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.10;

import {ERC721Upgradeable} from "../ERC721Upgradeable.sol";

import {SSTORE2} from "../../../../../../libraries/SSTORE2.sol";
import {StringLib} from "../../../../../../libraries/StringLib.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorageUpgradeable is ERC721Upgradeable {
    using SSTORE2 for *;
    using StringLib for uint256;

    bytes32 internal _baseTokenURIPtr;

    // Optional mapping for token URIs
    mapping(uint256 => bytes32) private __tokenURIs;

    function __ERC721URIStorage_init(
        string calldata baseURI_
    ) internal onlyInitializing {
        __ERC721URIStorage_init_unchained(baseURI_);
    }

    function __ERC721URIStorage_init_unchained(
        string calldata baseURI_
    ) internal onlyInitializing {
        _baseTokenURIPtr = bytes(baseURI_).write();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return string(_baseTokenURIPtr.read());
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        ownerOf(tokenId);

        bytes memory _tokenURI = __tokenURIs[tokenId].read();
        bytes memory _baseTokenURI = _baseTokenURIPtr.read();
        // If there is no base URI, return the token URI.
        if (_baseTokenURI.length == 0) return string(_tokenURI);

        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (_tokenURI.length != 0)
            return
                string(
                    abi.encodePacked(
                        _baseTokenURI,
                        _tokenURI,
                        tokenId.toString()
                    )
                );

        return tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(
        uint256 tokenId,
        string calldata _tokenURI
    ) internal virtual {
        ownerOf(tokenId);
        __tokenURIs[tokenId] = bytes(_tokenURI).write();
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if ((__tokenURIs[tokenId].read()).length != 0)
            delete __tokenURIs[tokenId];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}
