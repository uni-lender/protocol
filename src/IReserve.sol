// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IReserve {
    function accountCollateral(
        address account,
        uint256 underlyingPrice
    ) external view returns (uint256);

    function getUnderlying() external view returns (address);
}

interface IBorrowable {
    function accountBorrowing(
        address account,
        uint256 underlyingPrice
    ) external view returns (uint256);
}
