// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.10;

import {IERC2981Upgradeable} from "../../interfaces/IERC2981Upgradeable.sol";
import {
    ERC165Upgradeable,
    IERC165Upgradeable
} from "../..//utils/introspection/ERC165Upgradeable.sol";
import {
    FixedPointMathLib
} from "../../../../../libraries/math/FixedPointMathLib.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981Upgradeable is IERC2981Upgradeable, ERC165Upgradeable {
    using FixedPointMathLib for uint256;

    RoyaltyInfo internal _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) internal _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC2981Upgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981Upgradeable
     */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) public view virtual override returns (address, uint256) {
        address receiver;
        uint256 royaltyFraction;
        assembly {
            mstore(0x00, _tokenId)
            mstore(0x20, _tokenRoyaltyInfo.slot)
            let data := sload(keccak256(0x00, 0x40))
            receiver := and(data, 0xffffffffffffffffffffffffffffffffffffffff)
            royaltyFraction := shr(data, 160)

            if iszero(receiver) {
                data := sload(_defaultRoyaltyInfo.slot)
                receiver := and(
                    data,
                    0xffffffffffffffffffffffffffffffffffffffff
                )
                royaltyFraction := shr(data, 160)
            }
        }

        return (
            receiver,
            _salePrice.mulDivDown(royaltyFraction, _feeDenominator())
        );
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10_000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        __nonZeroAdress(receiver);
        if (feeNumerator > _feeDenominator())
            revert ERC2981__SalePriceExceeded();

        assembly {
            sstore(
                _defaultRoyaltyInfo.slot,
                or(shl(160, feeNumerator), receiver)
            )
        }
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        if (feeNumerator > _feeDenominator())
            revert ERC2981__SalePriceExceeded();
        __nonZeroAdress(receiver);

        assembly {
            mstore(0, tokenId)
            mstore(32, _tokenRoyaltyInfo.slot)
            sstore(keccak256(0, 64), or(shl(160, feeNumerator), receiver))
        }
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }

    function __nonZeroAdress(address addr_) private pure {
        if (addr_ == address(0)) revert ERC2981__InvalidArguments();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}
