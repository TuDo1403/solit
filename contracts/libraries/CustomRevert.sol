// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error Execution_Failed();

library CustomRevert {
    function _revert(
        bytes memory returnData,
        function() internal view customRevert
    ) internal view {
        if (returnData.length > 0) {
            assembly {
                let revertSize := mload(returnData)
                revert(add(revertData, 0x20), revertLength)
            }
        } else {
            customRevert();
            revert Execution_Failed();
        }
    }
}
