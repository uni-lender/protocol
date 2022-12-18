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
    address public bob;
    address public charlie;
    address public dave;

    MockERC20 public weth;
    MockERC721 public univ3;
    ERC20Reserve public wethReserve;
    ERC721Reserve public univ3Reserve;
    MockOracle public oracle;
    Controller public controller;

    function setUp() public {
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");
        dave = makeAddr("dave");
        oracle = new MockOracle();
        controller = new Controller(address(oracle));

        // init weth market
        weth = new MockERC20("Wrapped ETH", "WETH");
        weth.mint(alice, 1e20);
        weth.mint(bob, 1e20);
        weth.mint(charlie, 1e20);
        wethReserve = new ERC20Reserve(
            "Reserve Wrapped ETH",
            "RWETH",
            address(weth),
            address(controller),
            address(oracle)
        );

        // init univ3 market
        univ3 = new MockERC721("Uniswap v3 LP", "UV3LP");
        univ3.mint(alice, 0);
        univ3.mint(alice, 1);
        univ3.mint(alice, 2);
        univ3.mint(alice, 3);
        univ3Reserve = new ERC721Reserve(
            "Reserve Uniswap v3 LP",
            "RUV3LP",
            address(univ3),
            address(oracle)
        );

        // list market
        controller.listLendingMarket(address(wethReserve));
        controller.listLendingMarket(address(univ3Reserve));
        controller.listBorrowingMarket(address(wethReserve));

        // init oracle
        oracle.setPrice(address(weth), 1e18);
        oracle.setPrice(address(univ3), 1e18);
    }

    function testWithdrawAllowed() public {
        vm.startPrank(alice);
        weth.approve(address(wethReserve), 1e20);
        wethReserve.supply(1e18);
        wethReserve.withdraw(5e17);
        vm.stopPrank();
        assertEq(weth.balanceOf(alice), 995e17);
        assertEq(wethReserve.supplyBalanceOf(alice), 5e17);
        wethReserve.withdrawAllowed(alice, 1e10);
        vm.expectRevert("ERC20Reserve: insufficient liquidity");
        wethReserve.withdrawAllowed(alice, 1e18);
    }

    function testBorrowAllowed() public {
        vm.startPrank(alice);
        weth.approve(address(wethReserve), 1e20);
        wethReserve.supply(1e18);
        vm.stopPrank();
        assertEq(weth.balanceOf(alice), 99e18);
        assertEq(wethReserve.supplyBalanceOf(alice), 1e18);
        wethReserve.borrowAllowed(alice, 1e10);
        vm.expectRevert("ERC20Reserve: insufficient liquidity");
        wethReserve.borrowAllowed(alice, 1e18);
    }

    function testSupply() public {
        assertEq(weth.balanceOf(alice), 1e20);
        uint256 amount = 1e18;
        vm.startPrank(alice);
        weth.approve(address(wethReserve), 1e20);
        wethReserve.supply(amount);
        vm.stopPrank();
        assertEq(weth.balanceOf(alice), 99e18);
        assertEq(wethReserve.supplyBalanceOf(alice), 1e18);
    }

    function testWithdraw() public {
        vm.startPrank(alice);
        weth.approve(address(wethReserve), 1e20);
        wethReserve.supply(1e18);
        wethReserve.withdraw(5e17);
        vm.stopPrank();
        assertEq(weth.balanceOf(alice), 995e17);
        assertEq(wethReserve.supplyBalanceOf(alice), 5e17);
    }

    function testBorrow() public {
        vm.startPrank(alice);
        weth.approve(address(wethReserve), 1e20);
        wethReserve.supply(1e18);
        vm.stopPrank();

        vm.startPrank(bob);
        weth.approve(address(wethReserve), 1e20);
        wethReserve.supply(1e19);
        wethReserve.borrow(1e18);
        vm.stopPrank();

        assertEq(weth.balanceOf(alice), 99e18);
        assertEq(weth.balanceOf(bob), 91e18);
        assertEq(wethReserve.supplyBalanceOf(alice), 1e18);
        assertEq(wethReserve.supplyBalanceOf(bob), 1e19);
        assertEq(wethReserve.accountCollateral(bob), 1e19);
        assertEq(wethReserve.accountBorrowing(bob), 1e18);

        uint256 tokenId = 4;
        univ3.mint(charlie, 4);
        univ3.mint(charlie, 5);
        univ3.mint(charlie, 6);
        univ3.mint(charlie, 7);
        vm.startPrank(charlie);
        univ3.approve(address(univ3Reserve), tokenId);
        univ3Reserve.supply(tokenId);
        wethReserve.borrow(1e17);
        vm.stopPrank();
        assertEq(univ3.balanceOf(charlie), 3);
        assertEq(univ3.ownerOf(tokenId), address(univ3Reserve));
        assertEq(univ3Reserve.balanceOf(charlie), 1);
        assertEq(univ3Reserve.accountCollateral(charlie), 1e18);
        assertEq(wethReserve.accountBorrowing(charlie), 1e17);
    }
}
