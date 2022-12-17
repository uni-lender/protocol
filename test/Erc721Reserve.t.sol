// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ERC721Reserve.sol";
import {MockERC721} from "./Mock.t.sol";
import "../src/Oracle.sol";

contract Erc721ReserveTest is Test {
    address public alice;
    ERC721Reserve public reserve;
    MockERC721 public underlying;
    Oracle public oracle;

    function setUp() public {
        alice = makeAddr("alice");
        /* vm.deal(alice, 100 ether); */
        /* log_uint256(alice.balance); */
        underlying = new MockERC721("Mock NFT", "MNFT");
        underlying.mint(alice, 0);
        underlying.mint(alice, 1);
        underlying.mint(alice, 2);
        underlying.mint(alice, 3);

        reserve = new ERC721Reserve(
            "Reserve MNFT",
            "RMNFT",
            address(underlying),
            address(oracle)
        );
    }

    function testSupply() public {
        assertEq(underlying.balanceOf(alice), 4);
        uint256 tokenId = 1;
        vm.startPrank(alice);
        underlying.approve(address(reserve), tokenId);
        reserve.supply(tokenId);
        vm.stopPrank();
        assertEq(underlying.balanceOf(alice), 3);
        assertEq(underlying.ownerOf(tokenId), address(reserve));
        assertEq(reserve.balanceOf(alice), 1);
        assertEq(reserve.ownerOf(tokenId), alice);
    }

    function testWithdraw() public {
        uint256 tokenId = 1;
        vm.startPrank(alice);
        underlying.approve(address(reserve), tokenId);
        reserve.supply(tokenId);
        reserve.withdraw(tokenId);
        vm.stopPrank();
        assertEq(underlying.balanceOf(alice), 4);
        assertEq(underlying.ownerOf(tokenId), alice);
        assertEq(reserve.balanceOf(alice), 0);
        /* assertEq(reserve.ownerOf(tokenId), address(0)); */
    }
}
