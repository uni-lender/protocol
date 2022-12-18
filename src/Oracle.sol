// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./deps/chainlink/AggregatorInterface.sol";
import {IUniswapV3Factory} from "./deps/uniswap/IUniswapV3Factory.sol";
import {IUniswapV3PoolState} from "./deps/uniswap/IUniswapV3PoolState.sol";
import {INonfungiblePositionManager} from "./deps/uniswap/INonfungiblePositionManager.sol";
import {LiquidityAmounts} from "./deps/uniswap/LiquidityAmounts.sol";
import {TickMath} from "./deps/uniswap/libraries/TickMath.sol";
import {FullMath} from "./deps/uniswap/libraries/FullMath.sol";
import {SqrtLib} from "./deps/math/SqrtLib.sol";

interface IOracle {
    function getPrice(address asset) external view returns (uint256);

    function getAtomicPrice(address asset, uint256 tokenId) external view returns (uint256);
}

contract Oracle is IOracle {
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    mapping(address => uint256) private prices;
    mapping(address => mapping(uint256 => uint256)) private atomicPrices;

    INonfungiblePositionManager private univ3Manager;
    IUniswapV3Factory private univ3Factory;

    function getPrice(address asset) public view returns (uint256) {
        if (asset == WETH) {
            return 1e18;
        }
        return prices[asset];
    }

    function setPrice(address asset, uint256 price) public {
        prices[asset] = price;
    }

    function getAtomicPrice(address asset, uint256 tokenId) public view returns (uint256) {
        return atomicPrices[asset][tokenId];
    }

    function setAtomicPrice(address asset, uint256 tokenId, uint256 price) public {
        atomicPrices[asset][tokenId] = price;
    }
}
