// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ERC20Reserve.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract ERC20ReserveTest is Test {
    address public alice;
    ERC20Reserve public reserve;
    MockERC20 public underlying;

    function setUp() public {
        alice = makeAddr("alice");
        underlying = new MockERC20("Mock ERC20", "M20");
        underlying.mint(alice, 1e20);

        reserve = new ERC20Reserve(address(underlying), "Reserve M20", "RM20");
    }

    function testSupply() public {
        assertEq(underlying.balanceOf(alice), 1e20);
        uint256 amount = 1e18;
        vm.startPrank(alice);
        underlying.approve(address(reserve), 1e20);
        reserve.supply(amount);
        vm.stopPrank();
        assertEq(underlying.balanceOf(alice), 99e18);
        assertEq(reserve.balanceOf(alice), 1e18);
    }

    function testWithdraw() public {
        vm.startPrank(alice);
        underlying.approve(address(reserve), 1e20);
        reserve.supply(1e18);
        reserve.withdraw(5e17);
        vm.stopPrank();
        assertEq(underlying.balanceOf(alice), 995e17);
        assertEq(reserve.balanceOf(alice), 5e17);
    }
}
