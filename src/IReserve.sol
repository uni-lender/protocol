// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

interface IReserve is IERC165 {
    function accountCollateral(address account) external view returns (uint256);
}

interface IBorrowable {
    function accountBorrowing(address account) external view returns (uint256);
}
