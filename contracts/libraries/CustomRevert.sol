// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

error Execution_Failed();

library CustomRevert {
    function _revert(
        bytes memory returnData,
        function() internal view customRevert
    ) internal view {
        if (returnData.length > 0) {
            assembly {
                let revertSize := mload(returnData)
                revert(add(returnData, 0x20), revertSize)
            }
        } else {
            customRevert();
            revert Execution_Failed();
        }
    }
}
