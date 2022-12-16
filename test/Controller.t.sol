// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/Oracle.sol";
import "../src/Controller.sol";
import "../src/ERC20Reserve.sol";
import "../src/ERC721Reserve.sol";
import {MockERC20} from "./Mock.t.sol";
import {MockERC721} from "./Mock.t.sol";
import {MockOracle} from "./Mock.t.sol";

contract ControllerTest is Test {
    address public alice;
    MockERC20 public weth;
    MockERC721 public univ3;
    ERC20Reserve public wethReserve;
    ERC721Reserve public univ3Reserve;
    MockOracle public oracle;
    Controller public controller;

    function setUp() public {
        alice = makeAddr("alice");
        oracle = new MockOracle();
        controller = new Controller(address(oracle));

        // init weth market
        weth = new MockERC20("Wrapped ETH", "WETH");
        weth.mint(alice, 1e20);
        wethReserve = new ERC20Reserve(
            address(weth),
            "Reserve Wrapped ETH",
            "RWETH"
        );

        // init univ3 market
        univ3 = new MockERC721("Uniswap v3 LP", "UV3LP");
        univ3.mint(alice, 0);
        univ3.mint(alice, 1);
        univ3.mint(alice, 2);
        univ3.mint(alice, 3);
        univ3Reserve = new ERC721Reserve(
            address(univ3),
            "Reserve Uniswap v3 LP",
            "RUV3LP"
        );

        // list market
        controller.listLendingMarket(address(wethReserve));
        controller.listBorrowingMarket(address(wethReserve));

        // init oracle
        oracle.setPrice(address(weth), 1e18);
        oracle.setPrice(address(univ3), 1e18);
    }

    function testRedeemAllowed() public {
        vm.startPrank(alice);
        weth.approve(address(wethReserve), 1e20);
        wethReserve.supply(1e18);
        wethReserve.withdraw(5e17);
        vm.stopPrank();
        assertEq(weth.balanceOf(alice), 995e17);
        assertEq(wethReserve.balanceOf(alice), 5e17);
        assertEq(
            controller.redeemAllowed(address(wethReserve), alice, 1e10),
            true
        );
        assertEq(
            controller.redeemAllowed(address(wethReserve), alice, 1e18),
            false
        );
    }

    function testBorrowAllowed() public {
        vm.startPrank(alice);
        weth.approve(address(wethReserve), 1e20);
        wethReserve.supply(1e18);
        vm.stopPrank();
        assertEq(weth.balanceOf(alice), 99e18);
        assertEq(wethReserve.balanceOf(alice), 1e18);
        assertEq(
            controller.borrowAllowed(address(wethReserve), alice, 1e10),
            true
        );
        assertEq(
            controller.redeemAllowed(address(wethReserve), alice, 1e18),
            false
        );
    }
}
