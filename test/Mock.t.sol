// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC20 is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract MockERC721 is ERC721 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {}

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}

contract MockOracle {
    mapping(address => uint256) private assetPrices;

    function getPrice(address asset) public view returns (uint256) {
        return assetPrices[asset];
    }

    function setPrice(address asset, uint256 price) public {
        assetPrices[asset] = price;
    }
}
