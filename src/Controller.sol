// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Oracle.sol";
import {IReserve, IBorrowable} from "./IReserve.sol";

contract Controller {
    Oracle public oracle;
    uint256 public closeFactorMantissa;
    uint256 public liquidationIncentiveMantissa;
    // Mapping from owner to list of owned token IDs
    /* mapping(address => mapping(uint256 => uint256)) private _ownedTokens; */
    struct Market {
        bool isListed;
        uint256 collateralFactorMantissa;
    }
    // Mapping from reserve to market metadata.
    mapping(address => Market) public markets;
    address[] public lendingMarkets;
    address[] public borrowMarkets;

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
        reserve;
        redeemer;
        redeemAmount;
        return true;
    }

    function borrowAllowed(
        address reserve,
        address borrower,
        uint256 borrowAmount
    ) external view returns (bool) {

        return true;
    }

    function repayAllowed(
        address reserve,
        address repayer,
        uint256 repayAmount
    ) external view returns (bool) {
        return true;
    }

    function getUnderlyingPrice(address reserve) public view returns (uint256) {
        address underlying = IReserve(reserve).getUnderlying();
        return oracle.getPrice(underlying);
    }

    function getAccountLiquidity(
        address account
    ) public view returns (uint256) {
        uint256 totalCollateral;
        uint256 totalBorrowing;

        for (uint256 i = 0; i < lendingMarkets.length; i++) {
            address reserve = lendingMarkets[i];
            uint256 underlyingPrice = getUnderlyingPrice(reserve);
            uint256 accountCollateral = IReserve(reserve)
                .accountCollateral(account, underlyingPrice);
            totalCollateral += accountCollateral;
        }
        for (uint256 i = 0; i < borrowMarkets.length; i++) {
            address reserve = borrowMarkets[i];
            uint256 underlyingPrice = getUnderlyingPrice(reserve);
            uint256 accountBorrowing = IBorrowable(reserve)
                .accountBorrowing(account, underlyingPrice);
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
