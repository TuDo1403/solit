// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IMultiLevelReferral {
    error MultiLevelReferral__ProxyNotAllowed();
    error MultiLevelReferral__ReferralExisted();
    error MultiLevelReferral__InvalidArguments();
    error MultiLevelReferral__CircularRefUnallowed();

    struct Referrer {
        uint8 level;
        uint88 bonus;
        address addr;
    }

    /**
     * @dev Emits when a referral is added
     * @param referrer Referrer of the referral
     * @param referree Referree of the referral
     */
    event ReferralAdded(address indexed referrer, address indexed referree);

    /**
     * @dev Emits when the level of an account is updated
     * @param account Account whose level was updated
     * @param level New level of the account
     */
    event LevelUpdated(address indexed account, uint256 indexed level);

    /**
     * @dev Returns the referrer information of an account
     * @param account_ Account address to retrieve referrer information for
     * @return Referrer information of the account
     */
    function referrerOf(
        address account_
    ) external view returns (Referrer memory);
}
