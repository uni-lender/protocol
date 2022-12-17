// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./deps/chainlink/AggregatorInterface.sol";

interface IOracle {
    function getPrice(address asset) external view returns (uint256);

    function getAtomicPrice(
        address asset,
        uint256 tokenId
    ) external view returns (uint256);
}

contract Oracle is IOracle {
    function getPrice(address asset) external view returns (uint256) {
        asset;
        return 1e18;
    }

    function getAtomicPrice(
        address asset,
        uint256 tokenId
    ) external view returns (uint256) {
        return 1e18;
    }
}
