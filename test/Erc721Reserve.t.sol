// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Erc721Reserve.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {}

    function mint(address to, uint256 tokenId) public payable {
        _safeMint(to, tokenId);
    }
}

contract Erc721ReserveTest is Test {
    address public alice;
    Erc721Reserve public reserve;
    MockNFT public mockNFT;

    function setUp() public {
        alice = makeAddr("alice");
        /* vm.deal(alice, 100 ether); */
        /* log_uint256(alice.balance); */
        mockNFT = new MockNFT("Mock NFT", "MNFT");
        mockNFT.mint(alice, 0);
        mockNFT.mint(alice, 1);
        mockNFT.mint(alice, 2);
        mockNFT.mint(alice, 3);

        reserve = new Erc721Reserve(address(mockNFT), "Reserve MNFT", "RMNFT");
    }

    function testSupply() public {
        console.log(alice);
        vm.startPrank(alice);
        mockNFT.approve(address(reserve), 1);
        reserve.supply(1);
        vm.stopPrank();
        assertEq(true, true);
    }
}
