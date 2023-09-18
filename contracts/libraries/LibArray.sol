// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library LibArray {
    function sum(bool[] memory self) internal pure returns (uint256 total) {
        total = sum(toUint256s(self));
    }

    function sum(uint96[] memory self) internal pure returns (uint256 total) {
        total = sum(toUint256s(self));
    }

    function sum(address[] memory self) internal pure returns (uint256 total) {
        total = sum(toUint256s(self));
    }

    function sum(bytes32[] memory self) internal pure returns (uint256 total) {
        total = sum(toUint256s(self));
    }

    function sum(int256[] memory self) internal pure returns (int256 total) {
        total = int256(sum(toUint256s(self)));
    }

    function toSingletonArray(
        bool self
    ) internal pure returns (bool[] memory arr) {
        arr = toBooleans(toSingletonArray(self ? uint256(1) : 0));
    }

    function toSingletonArray(
        uint96 self
    ) internal pure returns (uint96[] memory arr) {
        arr = toUint96s(toSingletonArray(uint256(self)));
    }

    function toSingletonArray(
        int256 self
    ) internal pure returns (int256[] memory arr) {
        arr = toInt256s(toSingletonArray(uint256(self)));
    }

    function toSingletonArray(
        bytes32 self
    ) internal pure returns (bytes32[] memory arr) {
        arr = toBytes32s(toSingletonArray(uint256(self)));
    }

    function toSingletonArray(
        address self
    ) internal pure returns (address[] memory arr) {
        arr = toAddresses(toSingletonArray(uint256(uint160(self))));
    }

    function lengthen(
        uint96[] memory self,
        uint256 length
    ) internal pure returns (uint96[] memory lengthened) {
        lengthened = toUint96s(lengthen(toUint256s(self), length));
    }

    function lengthen(
        int256[] memory self,
        uint256 length
    ) internal pure returns (int256[] memory lengthened) {
        lengthened = toInt256s(lengthen(toUint256s(self), length));
    }

    function lengthen(
        bytes32[] memory self,
        uint256 length
    ) internal pure returns (bytes32[] memory lengthened) {
        lengthened = toBytes32s(lengthen(toUint256s(self), length));
    }

    function lengthen(
        address[] memory self,
        uint256 length
    ) internal pure returns (address[] memory lengthened) {
        lengthened = toAddresses(lengthen(toUint256s(self), length));
    }

    function shorten(
        uint96[] memory self,
        uint256 length
    ) internal pure returns (uint96[] memory shortened) {
        shortened = toUint96s(shorten(toUint256s(self), length));
    }

    function shorten(
        int256[] memory self,
        uint256 length
    ) internal pure returns (int256[] memory shortened) {
        shortened = toInt256s(shorten(toUint256s(self), length));
    }

    function shorten(
        bytes32[] memory self,
        uint256 length
    ) internal pure returns (bytes32[] memory shortened) {
        shortened = toBytes32s(shorten(toUint256s(self), length));
    }

    function shorten(
        address[] memory self,
        uint256 length
    ) internal pure returns (address[] memory shortened) {
        shortened = toAddresses(shorten(toUint256s(self), length));
    }

    function isEqual(
        uint96[] memory self,
        int256[] memory other
    ) internal pure returns (bool yes) {
        yes = isEqual(toUint256s(self), toUint256s(other));
    }

    function isEqual(
        int256[] memory self,
        int256[] memory other
    ) internal pure returns (bool yes) {
        yes = isEqual(toUint256s(self), toUint256s(other));
    }

    function isEqual(
        address[] memory self,
        address[] memory other
    ) internal pure returns (bool yes) {
        yes = isEqual(toUint256s(self), toUint256s(other));
    }

    function isEqual(
        bytes32[] memory self,
        bytes32[] memory other
    ) internal pure returns (bool yes) {
        yes = isEqual(toUint256s(self), toUint256s(other));
    }

    function hasDuplicates(
        uint96[] memory self
    ) internal pure returns (bool yes) {
        yes = hasDuplicates(toUint256s(self));
    }

    function hasDuplicates(
        int256[] memory self
    ) internal pure returns (bool yes) {
        yes = hasDuplicates(toUint256s(self));
    }

    function hasDuplicates(
        bytes32[] memory self
    ) internal pure returns (bool yes) {
        yes = hasDuplicates(toUint256s(self));
    }

    function hasDuplicates(
        address[] memory self
    ) internal pure returns (bool yes) {
        yes = hasDuplicates(toUint256s(self));
    }

    function extend(
        bytes32[] memory self,
        bytes32[] memory other
    ) internal pure returns (bytes32[] memory combined) {
        combined = toBytes32s(extend(toUint256s(self), toUint256s(other)));
    }

    function extend(
        int256[] memory self,
        int256[] memory other
    ) internal pure returns (int256[] memory combined) {
        combined = toInt256s(extend(toUint256s(self), toUint256s(other)));
    }

    function extend(
        address[] memory self,
        address[] memory other
    ) internal pure returns (address[] memory combined) {
        combined = toAddresses(extend(toUint256s(self), toUint256s(other)));
    }

    function toSingletonArray(
        uint256 self
    ) internal pure returns (uint256[] memory arr) {
        arr = new uint256[](1);
        arr[0] = self;
    }

    function shorten(
        uint256[] memory self,
        uint256 length
    ) internal pure returns (uint256[] memory shortened) {
        assembly ("memory-safe") {
            if lt(mload(self), length) {
                revert(0, 0)
            }
            mstore(self, length)
            shortened := self
        }
    }

    function lengthen(
        uint256[] memory self,
        uint256 length
    ) internal pure returns (uint256[] memory lengthened) {
        lengthened = new uint256[](length);
        uint256 lengthSelf = self.length;

        for (uint256 i; i < lengthSelf; ) {
            lengthened[i] = self[i];
            unchecked {
                ++i;
            }
        }
    }

    function isEqual(
        uint256[] memory self,
        uint256[] memory other
    ) internal pure returns (bool yes) {
        assembly ("memory-safe") {
            let selfHashed := keccak256(add(self, 0x20), mul(mload(self), 0x20))
            let otherHashed := keccak256(
                add(other, 0x20),
                mul(mload(other), 0x20)
            )
            yes := eq(selfHashed, otherHashed)
        }
    }

    function extend(
        uint256[] memory self,
        uint256[] memory other
    ) internal pure returns (uint256[] memory combined) {
        uint256 lengthSelf = self.length;
        uint256 lengthOther = other.length;

        unchecked {
            combined = new uint256[](lengthSelf + lengthOther);
        }

        uint256 i;

        for (; i < lengthSelf; ) {
            combined[i] = self[i];
            unchecked {
                ++i;
            }
        }

        for (uint256 j; j < lengthOther; ) {
            combined[i] = other[j];
            unchecked {
                ++i;
                ++j;
            }
        }
    }

    function sort(
        uint96[] memory self
    ) internal pure returns (uint96[] memory sorted) {
        sorted = toUint96s(sort(toUint256s(self)));
    }

    function sort(
        int256[] memory self
    ) internal pure returns (int256[] memory sorted) {
        sorted = toInt256s(sort(toUint256s(self)));
    }

    function sort(
        address[] memory self
    ) internal pure returns (address[] memory sorted) {
        sorted = toAddresses(sort(toUint256s(self)));
    }

    function sort(
        bytes32[] memory self
    ) internal pure returns (bytes32[] memory sorted) {
        sorted = toBytes32s(sort(toUint256s(self)));
    }

    function sort(
        uint256[] memory self
    ) internal pure returns (uint256[] memory sorted) {
        unchecked {
            if (self.length > 1) {
                _quickSort(self, 0, self.length - 1);
            }
        }

        assembly {
            sorted := self
        }
    }

    function _quickSort(
        uint256[] memory arr,
        uint256 left,
        uint256 right
    ) private pure {
        unchecked {
            uint256 i = left;
            uint256 j = right;
            uint256 pivot = arr[left + (right - left) / 2];

            while (i <= j) {
                while (arr[i] < pivot) {
                    i++;
                }
                while (arr[j] > pivot) {
                    j--;
                }
                if (i <= j) {
                    (arr[i], arr[j]) = (arr[j], arr[i]);
                    i++;
                    j--;
                }
            }
            if (left < j) {
                _quickSort(arr, left, j);
            }
            if (i < right) {
                _quickSort(arr, i, right);
            }
        }
    }

    function sum(uint256[] memory self) internal pure returns (uint256 total) {
        uint256 length = self.length;
        for (uint256 i; i < length; ) {
            total += self[i];
            unchecked {
                ++i;
            }
        }
    }

    function hasDuplicates(
        uint256[] memory self
    ) internal pure returns (bool yes) {
        unchecked {
            uint256 length = self.length;

            if (length == 0) {
                return false;
            }

            uint256 lastIndex = length - 1;

            for (uint256 i; i < lastIndex; ++i) {
                for (uint256 j = i + 1; j < length; ++j) {
                    if (self[i] == self[j]) {
                        return true;
                    }
                }
            }
        }
    }

    function toAddresses(
        bytes memory data
    ) internal pure returns (address[] memory addrs) {
        addrs = toAddresses(toUint256s(data));
    }

    function toBytes32s(
        bytes memory data
    ) internal pure returns (bytes32[] memory bytes32s) {
        bytes32s = toBytes32s(toUint256s(data));
    }

    function toUint256s(
        bytes memory data
    ) internal pure returns (uint256[] memory uint256s) {
        assembly ("memory-safe") {
            let bytesLength := mload(data)
            let bytes32Length := div(bytesLength, 0x20)
            if iszero(bytes32Length) {
                revert(0, 0)
            }
            mstore(data, bytes32Length)
            uint256s := data
        }
    }

    function toInt256s(
        uint256[] memory self
    ) internal pure returns (int256[] memory int256s) {
        assembly ("memory-safe") {
            int256s := self
        }
    }

    function toBytes32s(
        uint256[] memory self
    ) internal pure returns (bytes32[] memory bytes32s) {
        assembly ("memory-safe") {
            bytes32s := self
        }
    }

    function toBytes32s(
        address[] memory self
    ) internal pure returns (bytes32[] memory bytes32s) {
        assembly {
            bytes32s := self
        }
    }

    function toAddresses(
        uint256[] memory self
    ) internal pure returns (address[] memory addrs) {
        assembly ("memory-safe") {
            addrs := self
        }
    }

    function toAddresses(
        bytes32[] memory self
    ) internal pure returns (address[] memory addrs) {
        assembly ("memory-safe") {
            addrs := self
        }
    }

    function toBooleans(
        uint256[] memory self
    ) internal pure returns (bool[] memory booleans) {
        assembly ("memory-safe") {
            booleans := self
        }
    }

    function toUint96s(
        uint256[] memory self
    ) internal pure returns (uint96[] memory uint96s) {
        assembly ("memory-safe") {
            uint96s := self
        }
    }

    function toUint256s(
        bool[] memory self
    ) internal pure returns (uint256[] memory uint256s) {
        assembly ("memory-safe") {
            uint256s := self
        }
    }

    function toUint256s(
        uint96[] memory self
    ) internal pure returns (uint256[] memory uint256s) {
        assembly ("memory-safe") {
            uint256s := self
        }
    }

    function toUint256s(
        int256[] memory self
    ) internal pure returns (uint256[] memory uint256s) {
        assembly ("memory-safe") {
            uint256s := self
        }
    }

    function toUint256s(
        address[] memory self
    ) internal pure returns (uint256[] memory uint256s) {
        assembly ("memory-safe") {
            uint256s := self
        }
    }

    function toUint256s(
        bytes32[] memory self
    ) internal pure returns (uint256[] memory uint256s) {
        assembly ("memory-safe") {
            uint256s := self
        }
    }
}
