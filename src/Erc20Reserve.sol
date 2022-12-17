// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IReserve, IBorrowable} from "./IReserve.sol";
import {Controller} from "./Controller.sol";
import "./Oracle.sol";

import "forge-std/console.sol";

contract ERC20Reserve is IReserve, IBorrowable, IERC20, ERC20, Ownable {
    using SafeERC20 for IERC20;
    // Price oracle
    Oracle public oracle;
    // Underlying asset for this Reserve
    address public underlying;
    // Protocol controller
    Controller public controller;
    // Mapping from account address to outstanding borrow balances
    mapping(address => uint256) public accountBorrows;

    constructor(
        string memory name_,
        string memory symbol_,
        address underlying_,
        address controller_,
        address oracle_
    ) ERC20(name_, symbol_) {
        underlying = underlying_;
        controller = Controller(controller_);
        oracle = Oracle(oracle_);
    }

    function supply(uint256 amount) external returns (uint256) {
        /* console.log("underlying:", underlying); */
        /* console.log("msg.sender:", msg.sender); */
        /* console.log( */
        /*     "sender's balance:", */
        /*     IERC20(underlying).balanceOf(msg.sender) */
        /* ); */

        IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);

        return 0;
    }

    function redeem(uint256 amount) external returns (uint256) {
        require(
            controller.redeemAllowed(address(this), msg.sender, amount),
            "ERC20Reserve: redeemption is not allowed"
        );
        require(
            balanceOf(msg.sender) >= amount,
            "ERC20Reserve: redeem transfer amount exceeds position"
        );
        _burn(msg.sender, amount);
        IERC20(underlying).safeTransfer(msg.sender, amount);

        return 0;
    }

    function borrow(uint256 amount) external returns (uint256) {
        require(
            controller.borrowAllowed(address(this), msg.sender, amount),
            "ERC20Reserve: borrowing is not allowed"
        );
        accountBorrows[msg.sender] += amount;
        IERC20(underlying).safeTransfer(msg.sender, amount);

        return 0;
    }

    function repay(uint256 amount) external returns (uint256) {
        require(
            controller.repayAllowed(address(this), msg.sender, amount),
            "ERC20Reserve: repayment is not allowed"
        );
        uint256 borrowBalance = accountBorrows[msg.sender];
        require(
            amount <= borrowBalance,
            "ERC20Reserve: insufficient borrow balance"
        );
        accountBorrows[msg.sender] -= amount;
        IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);

        return 0;
    }

    function getUnderlying() external view returns (address) {
        return underlying;
    }

    function accountCollateral(
        address account,
        uint256 underlyingPrice
    ) external view returns (uint256) {
        uint256 balance = balanceOf(account);
        console.log("account:", account);
        console.log("balance:", balance);
        console.log("price:", underlyingPrice);
        return (balance * underlyingPrice) / 1e18;
    }

    function accountBorrowing(
        address account,
        uint256 underlyingPrice
    ) external view returns (uint256) {
        uint256 borrowBalance = accountBorrows[account];
        return (borrowBalance * underlyingPrice) / 1e18;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165) returns (bool) {
        return
            interfaceId == type(IReserve).interfaceId ||
            interfaceId == type(IBorrowable).interfaceId ||
            interfaceId == type(IERC20).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
