// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// import "./Array.sol";
// import "./SSTORE2.sol";
// import {BitMap, BitMaps} from "../oz/utils/structs/BitMaps.sol";

// library EnumerableSetV2 {
//     using Array for uint256[];
//     using SSTORE2 for *;
//     using BitMaps for BitMap;

//     struct Set {
//         uint96 length;
//         address ptr;
//         BitMap indexes;
//     }

//     function _add(Set storage set_, uint256[] calldata values_) private {
//         set_.ptr = abi.encode(values_).writeToAddr();
//         uint256 length_ = values_.length;
//         for (uint256 i; i < length_; ) {
//             set_.indexes.set(values_[i]);
//             unchecked {
//                 ++i;
//             }
//         }
//         set_.length = uint96(length_);
//     }

//     function _remove(Set storage set_) private {
//         delete set_.ptr;
//         delete set_.indexes;
//         delete set_.length;
//     }

//     function _remove(Set storage set_, uint256 value_) private returns (bool) {
//         if (_contains(set_, value_)) {
//             set_.indexes.unset(value_);
//             unchecked {
//                 --set_.length;
//             }
//             return true;
//         }
//         return false;
//     }

//     function _contains(
//         Set storage set,
//         uint256 value
//     ) private view returns (bool) {
//         return set.indexes.get(value);
//     }

//     function _at(
//         Set storage set,
//         uint256 index
//     ) private view returns (uint256) {
//         return _values(set)[index];
//     }

//     function _length(Set storage set) private view returns (uint256) {
//         return _values(set).length;
//     }

//     function _values(Set storage set) private view returns (uint256[] memory) {
//         return abi.decode(set.ptr.read(), (uint256[]));
//     }

//     struct AddressSet {
//         Set _inner;
//     }

//     function add(AddressSet storage set, address[] calldata value) internal {
//         uint256[] memory store;
//         assembly {
//             store := value
//         }
//         _add(set._inner, store);
//     }

//     function remove(AddressSet storage set) internal {
//         _remove(set._inner);
//     }

//     function remove(
//         AddressSet storage set,
//         address value
//     ) internal returns (bool removed) {
//         uint256 val;
//         assembly {
//             val := value
//         }
//         removed = _remove(set._inner, val);
//     }

//     function contains(
//         AddressSet storage set,
//         address value
//     ) internal view returns (bool) {
//         uint256 store;
//         assembly {
//             store := value
//         }
//         return _contains(set._inner, store);
//     }

//     function at(
//         AddressSet storage set,
//         uint256 index
//     ) internal view returns (address addr) {
//         uint256 value = _at(set._inner, index);
//         assembly {
//             addr := value
//         }
//     }

//     function length(AddressSet storage set) internal view returns (uint256) {
//         return _length(set._inner);
//     }

//     function values(
//         AddressSet storage set
//     ) internal view returns (address[] memory res) {
//         uint256[] memory val = _values(set._inner);
//         uint256 length_ = val.length;
//         uint256[] memory tmp = new uint256[](length_);
//         BitMaps.BitMap storage bitmap = set._inner.indexes;
//         uint256 counter;
//         for (uint256 i; i < length_; ) {
//             unchecked {
//                 if (bitmap.get(val[i])) tmp[counter++] = val[i];
//                 ++i;
//             }
//         }
//         assembly {
//             mstore(tmp, add(counter, 1))
//             res := tmp
//         }
//     }
// }
