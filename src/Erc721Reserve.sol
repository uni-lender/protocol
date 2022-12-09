// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Erc721Reserve {
    mapping (address => uint256) internal accountTokens;
    function supply(uint256 tokenId) external returns (uint256) {}
    function withdraw(uint256 tokenId) external returns (uint256) {}
}
