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
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function getPrice(address asset) external view returns (uint256) {
        if (asset == WETH) {
            return 1e18;
        }
        return 1e18;
    }

    function getAtomicPrice(
        address asset,
        uint256 tokenId
    ) external view returns (uint256) {
        return 1e18;
    }
}
