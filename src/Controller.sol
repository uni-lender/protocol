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

    function getAccountLiquidity(address account) public view returns (uint256) {
        uint256 totalCollateral;
        uint256 totalBorrowing;

        for (uint256 i = 0; i < lendingMarkets.length; i++) {
            address reserve = lendingMarkets[i];
            uint256 accountCollateral = IReserve(reserve).accountCollateral(account);
            totalCollateral += accountCollateral;
        }
        for (uint256 i = 0; i < borrowMarkets.length; i++) {
            address reserve = borrowMarkets[i];
            uint256 accountBorrowing = IBorrowable(reserve).accountBorrowing(account);
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
