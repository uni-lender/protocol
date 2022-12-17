// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

interface IReserve is IERC165 {
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
