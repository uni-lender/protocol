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

    function withdrawAllowed(address account, uint256 amount) public {
        uint256 priceMantissa = getUnderlyingPrice();
        uint256 redeemEffects = (amount * priceMantissa) / 1e18;
        uint256 liquidity = controller.getAccountLiquidity(account);
        console.log("priceMantissa:", priceMantissa);
        console.log("redeemEffects:", redeemEffects);
        console.log("liquidity:", liquidity);
        require(
            redeemEffects < liquidity,
            "ERC20Reserve: insufficient liquidity"
        );
        require(
            balanceOf(account) >= amount,
            "ERC20Reserve: redeem transfer amount exceeds position"
        );
    }

    function withdraw(uint256 amount) external returns (uint256) {
        withdrawAllowed(msg.sender, amount);
        _burn(msg.sender, amount);
        IERC20(underlying).safeTransfer(msg.sender, amount);

        return 0;
    }

    function borrowAllowed(address account, uint256 amount) public {
        uint256 priceMantissa = getUnderlyingPrice();
        uint256 borrowEffects = (amount * priceMantissa) / 1e18;
        uint256 liquidity = controller.getAccountLiquidity(account);
        console.log("priceMantissa:", priceMantissa);
        console.log("borrowEffects:", borrowEffects);
        console.log("liquidity:", liquidity);
        require(
            borrowEffects < liquidity,
            "ERC20Reserve: insufficient liquidity"
        );
    }

    function borrow(uint256 amount) external returns (uint256) {
        borrowAllowed(msg.sender, amount);
        accountBorrows[msg.sender] += amount;
        IERC20(underlying).safeTransfer(msg.sender, amount);

        return 0;
    }

    function repay(uint256 amount) external returns (uint256) {
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

    function getUnderlyingPrice() public view returns (uint256) {
        return oracle.getPrice(underlying);
    }

    function accountCollateral(
        address account
    ) external view returns (uint256) {
        uint256 balance = balanceOf(account);
        uint256 underlyingPriceMantissa = getUnderlyingPrice();
        console.log("account:", account);
        console.log("balance:", balance);
        console.log("price:", underlyingPriceMantissa);
        return (balance * underlyingPriceMantissa) / 1e18;
    }

    function accountBorrowing(address account) external view returns (uint256) {
        uint256 borrowBalance = accountBorrows[account];
        uint256 underlyingPriceMantissa = getUnderlyingPrice();
        return (borrowBalance * underlyingPriceMantissa) / 1e18;
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
