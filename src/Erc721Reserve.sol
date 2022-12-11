// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "forge-std/console.sol";

contract Erc721Reserve is ERC721, ERC721Enumerable, IERC721Receiver, Ownable {
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
            "Erc721Reserve: reserve token transfer from incorrect owner"
        );
        _burn(tokenId);
        IERC721(underlying).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );

        return 0;
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
