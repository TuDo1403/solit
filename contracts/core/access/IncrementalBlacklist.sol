// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract IncrementalBlacklist {
    /// @dev value is equal to keccak256("IncrementalBlacklist.ACCOUNT_STATUS_SLOT") - 1
    bytes32 internal constant _ACCOUNT_STATUS_SLOT =
        0x26acbc057a5a236629f2cd637f64385c79eeec1bb88628293e681b8fc4f0e715;

    struct Status {
        address account;
        bool status;
    }

    modifier nonBlacklisted() virtual {
        _;
    }

    event AccountStatusUpdated(address indexed account, bool status);

    function viewAccountsStatus(
        address[] calldata accounts_
    ) public view virtual returns (bool[] memory results) {
        results = new bool[](accounts_.length);

        assembly {
            mstore(0x20, _ACCOUNT_STATUS_SLOT)

            let length := shr(5, accounts_.length)
            let resultsElementLocation := add(results, 0x20)

            for {
                let i
            } lt(i, length) {
                i := add(i, 0x20)
            } {
                let account := calldataload(add(accounts_.offset, i))
                mstore(0x00, shr(8, account))

                mstore(
                    add(resultsElementLocation, i),
                    and(
                        sload(keccak256(0x00, 0x40)),
                        shl(and(account, 0xff), 1)
                    )
                )
            }
        }
    }

    // function _setAccountsStatus(Status[] calldata statuses_) returns () {}

    function _setStatus(Status calldata status_) internal virtual {}
}
