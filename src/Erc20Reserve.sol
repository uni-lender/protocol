// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "forge-std/console.sol";

contract ERC20Reserve is IERC20, ERC20, Ownable {
    using SafeERC20 for IERC20;
    /**
     * @notice Underlying asset for this Reserve
     */
    address public underlying;

    constructor(
        address underlying_,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        underlying = underlying_;
    }

    function supply(uint256 amount) external returns (uint256) {
        /* console.log("underlying:", underlying); */
        /* console.log("msg.sender:", msg.sender); */
        /* console.log( */
        /*     "sender's balance:", */
        /*     IERC20(underlying).balanceOf(msg.sender) */
        /* ); */

        IERC20(underlying).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        _mint(msg.sender, amount);

        return 0;
    }

    function withdraw(uint256 amount) external returns (uint256) {
        require(
            balanceOf(msg.sender) >= amount,
            "ERC20Reserve: transfer amount exceeds balance"
        );
        _burn(msg.sender, amount);
        IERC20(underlying).safeTransfer(
            msg.sender,
            amount 
        );

        return 0;
    }
}
