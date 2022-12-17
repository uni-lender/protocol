// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IReserve} from "./IReserve.sol";

import "forge-std/console.sol";

contract ERC721Reserve is IReserve, ERC721, ERC721Enumerable, IERC721Receiver, Ownable {
    /**
     * @notice Underlying asset for this Reserve
     */
    address public underlying;

    constructor(
        address underlying_,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        underlying = underlying_;
    }

    function supply(uint256 tokenId) external returns (uint256) {
        IERC721(underlying).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        _safeMint(msg.sender, tokenId);

        return 0;
    }

    function withdraw(uint256 tokenId) external returns (uint256) {
        require(
            ownerOf(tokenId) == msg.sender,
            "ERC721Reserve: reserve token transfer from incorrect owner"
        );
        _burn(tokenId);
        IERC721(underlying).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );

        return 0;
    }

    function accountCollateral(
        address account,
        uint256 underlyingPrice
    ) external view returns (uint256) {
        uint256 balance = balanceOf(account);
        console.log("account:", account);
        console.log("ERC721 balance:", balance);
        console.log("price:", underlyingPrice);
        return balance * underlyingPrice;
    }

    function getUnderlying() external view returns (address) {
        return underlying;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        operator;
        from;
        tokenId;
        data;

        return this.onERC721Received.selector;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
