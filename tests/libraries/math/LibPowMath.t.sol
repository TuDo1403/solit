// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "@solit/contracts/libraries/math/LibPowMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LibPowMathTest is Test {
    uint64 public constant PRECISION = 18;

    modifier skipOverflow(
        uint256 x,
        uint256 y,
        uint256 d,
        uint8 n
    ) {
        vm.assume(d != 0);
        vm.assume(LibPowMath.findMaxExponent(x) <= n);
        vm.assume(LibPowMath.findMaxExponent(y) <= n);
        (bool ok, ) = address(this).staticcall(
            abi.encodeCall(this.unsafePow, (x, y, d, n))
        );
        vm.assume(ok);
        _;
    }

    /**
     * @notice Ensures the method {LibPowMath.findMaxExponent} works without reverting.
     */
    function test_findMaxExponent(uint256 n) public pure returns (uint256 res) {
        uint16 e = LibPowMath.findMaxExponent(n);
        res = n ** uint256(e);
    }

    /**
     * @notice Should fail when the exponent k+1.
     */
    function testFail_findMaxExponent_ExponentWhenPlus1(
        uint256 n
    ) public pure returns (uint256 res) {
        vm.assume(7132 < n && n < 340282366920938463463374607431768211456);
        uint16 k = LibPowMath.findMaxExponent(n);
        res = n ** uint256(k + 1);
    }

    /**
     * @notice Gas report for {safeUnutilizedPow}.
     */
    function testGas_safeUnutilizedPow(
        uint256 x,
        uint256 y,
        uint256 d,
        uint8 n
    ) public view skipOverflow(x, y, d, n) {
        safeUnutilizedPow(x, y, d, n);
    }

    /**
     * @notice Gas report for {LibPowMath.mulDiv}.
     */
    function testGas_mulDiv(
        uint256 x,
        uint256 y,
        uint256 d,
        uint8 n
    ) public view skipOverflow(x, y, d, n) {
        x = 5739;
        y = 1293;
        d = 242;
        n = 21;
        LibPowMath.mulDiv(x, y, d, n);
    }

    /**
     * @notice Gas report for {LibPowMath.mulDivLowPrecision}.
     */
    function testGas_mulDivLowPrecision(
        uint256 x,
        uint256 y,
        uint256 d,
        uint8 n
    ) public view skipOverflow(x, y, d, n) {
        LibPowMath.mulDivLowPrecision(x, y, d, n);
    }

    /**
     * @notice Gas report for {LibPowMath.unsafePow}.
     */
    function testGas_unsafePow(
        uint256 x,
        uint256 y,
        uint256 d,
        uint8 n
    ) public view skipOverflow(x, y, d, n) {
        unsafePow(x, y, d, n);
    }

    /**
     * @notice Test the correctness of the mul div method {LibPowMath.mulDiv}.
     */
    function test_mulDiv(
        uint256 x,
        uint256 y,
        uint256 d,
        uint8 n
    ) public skipOverflow(x, y, d, n) {
        uint256 calc = LibPowMath.mulDiv(x, y, d, n);
        uint256 expt = safeUnutilizedPow(x, y, d, n);
        assertEq(
            calc,
            expt,
            string.concat(
                "Expression: ",
                vm.toString(x),
                "*(",
                vm.toString(y),
                "/",
                vm.toString(d),
                ")**",
                vm.toString(n)
            )
        );
    }

    /**
     * @notice Helper method to compute scale: x * (y / d) ^ n.
     */
    function unsafePow(
        uint256 x,
        uint256 y,
        uint256 d,
        uint8 n
    ) public pure returns (uint256 r) {
        r = x;
        for (uint256 i = 0; i < n; i++) {
            r = Math.mulDiv(r, y, d);
        }
    }

    /**
     * @notice Helper method to compute scale: x * (y / d) ^ n.
     */
    function safeUnutilizedPow(
        uint256 x,
        uint256 y,
        uint256 d,
        uint8 n
    ) public pure returns (uint256 res) {
        res = x;
        uint8 ndReverse;
        while (n > 0) {
            (bool ok, uint256 res_) = SafeMath.tryMul(res, y);
            if (!ok) {
                if (ndReverse > 0) {
                    res /= d;
                    ndReverse--;
                    continue;
                }

                res_ = Math.mulDiv(res, y, d);
            } else {
                ndReverse++;
            }

            res = res_;
            n--;
        }

        while (ndReverse > 0) {
            res = res / d;
            ndReverse--;
        }
    }
}
