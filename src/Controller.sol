// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Oracle.sol";
import {IReserve, IBorrowable} from "./IReserve.sol";

import "forge-std/console.sol";

contract Controller {
    Oracle public oracle;
    uint256 public closeFactorMantissa;
    uint256 public liquidationIncentiveMantissa;
    address[] public lendingMarkets;
    address[] public borrowMarkets;

    constructor(address oracle_) {
        oracle = Oracle(oracle_);
    }

    function supplyAllowed(
        address reserve,
        address supplier,
        uint256 supplyAmount
    ) external view returns (bool) {
        reserve;
        supplier;
        supplyAmount;
        return true;
    }

    function redeemAllowed(
        address reserve,
        address redeemer,
        uint256 redeemAmount
    ) external view returns (bool) {
        uint256 priceMantissa = getUnderlyingPrice(reserve);
        uint256 redeemEffects = (redeemAmount * priceMantissa) / 1e18;
        uint256 liquidity = getAccountLiquidity(redeemer);

        console.log("priceMantissa:", priceMantissa);
        console.log("redeemEffects:", redeemEffects);
        console.log("liquidity:", liquidity);

        if (redeemEffects < liquidity) {
            return true;
        } else {
            return false;
        }
    }

    function borrowAllowed(
        address reserve,
        address borrower,
        uint256 borrowAmount
    ) external view returns (bool) {
        uint256 priceMantissa = getUnderlyingPrice(reserve);
        uint256 borrowEffects = (borrowAmount * priceMantissa) / 1e18;
        uint256 liquidity = getAccountLiquidity(borrower);

        console.log("priceMantissa:", priceMantissa);
        console.log("borrowEffects:", borrowEffects);
        console.log("liquidity:", liquidity);

        if (borrowEffects < liquidity) {
            return true;
        } else {
            return false;
        }
    }

    function repayAllowed(
        address reserve,
        address repayer,
        uint256 repayAmount
    ) external view returns (bool) {
        reserve;
        repayer;
        repayAmount;
        return true;
    }

    function getUnderlyingPrice(address reserve) public view returns (uint256) {
        address underlying = IReserve(reserve).getUnderlying();
        bool isERC20 = IReserve(reserve).supportsInterface(
            type(IERC20).interfaceId
        );
        if (isERC20) {
            return oracle.getPrice(underlying);
        } else {
            return oracle.getPrice(underlying);
        }
    }

    function getAccountLiquidity(
        address account
    ) public view returns (uint256) {
        uint256 totalCollateral;
        uint256 totalBorrowing;

        for (uint256 i = 0; i < lendingMarkets.length; i++) {
            address reserve = lendingMarkets[i];
            uint256 underlyingPrice = getUnderlyingPrice(reserve);
            uint256 accountCollateral = IReserve(reserve).accountCollateral(
                account,
                underlyingPrice
            );
            totalCollateral += accountCollateral;
        }
        for (uint256 i = 0; i < borrowMarkets.length; i++) {
            address reserve = borrowMarkets[i];
            uint256 underlyingPrice = getUnderlyingPrice(reserve);
            uint256 accountBorrowing = IBorrowable(reserve).accountBorrowing(
                account,
                underlyingPrice
            );
            totalBorrowing += accountBorrowing;
        }

        if (totalCollateral >= totalBorrowing) {
            return totalCollateral - totalBorrowing;
        } else {
            return totalBorrowing - totalCollateral;
        }
    }

    // TODO: check IReserve
    function listLendingMarket(address reserve) external {
        lendingMarkets.push(reserve);
    }

    // TODO: check IBorrowable
    function listBorrowingMarket(address reserve) external {
        borrowMarkets.push(reserve);
    }
}
