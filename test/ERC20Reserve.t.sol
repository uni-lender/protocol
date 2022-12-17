// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ERC20Reserve.sol";
import {MockERC20} from "./Mock.t.sol";

contract ERC20ReserveTest is Test {
    address public alice;
    ERC20Reserve public reserve;
    MockERC20 public underlying;

    /* function setUp() public { */
    /*     alice = makeAddr("alice"); */
    /*     underlying = new MockERC20("Mock ERC20", "M20"); */
    /*     underlying.mint(alice, 1e20); */

    /*     reserve = new ERC20Reserve("Reserve M20", "RM20", address(underlying), ); */
    /* } */
}
