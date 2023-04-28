// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibBitSlot} from "./operations/LibBitSlot.sol";
import {LibAddressArray} from "./operations/LibAddressArray.sol";
import {LibExternalMapping} from "./operations/LibExternalMapping.sol";
import {LibIncrementalNonce} from "./operations/LibIncrementalNonce.sol";

type BitSlot is bytes32;

type BitmapNonce is bytes32;

type AddressArray is bytes32;

type ExternalMapping is bytes32;

type IncrementalNonce is bytes32;

using {LibBitSlot.get} for BitSlot global;
using {LibBitSlot.set} for BitSlot global;

using {LibAddressArray.all} for AddressArray global;
using {LibAddressArray.push} for AddressArray global;
using {LibAddressArray.unwrap} for AddressArray global;

using {LibExternalMapping.get} for ExternalMapping global;
using {LibExternalMapping.set} for ExternalMapping global;

using {LibIncrementalNonce.increment} for IncrementalNonce global;
