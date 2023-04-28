// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAuthority} from "./IAuthority.sol";

interface IAuthAccess {
    error NonZeroAddress();

    event AuthorityUpdated(
        address indexed operator,
        IAuthority indexed previousAuthority,
        IAuthority indexed currentAuthority
    );

    function authority() external view returns (IAuthority _authority);

    function isAuthorized(
        address sender_,
        bytes4 fnSig_
    ) external view returns (bool);
}
