// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./deps/chainlink/AggregatorInterface.sol";

contract Oracle {
    function getPrice(address asset) public view returns (uint256) {
        asset;
        return 1e18;
    }
    
    function getAtomicPrice(address asset, uint256 tokenId) public view returns (uint256) {
        
        return 1e18;
    }
}
