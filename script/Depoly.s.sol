// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Controller.sol";
import "../src/Oracle.sol";
import "../src/ERC20Reserve.sol";
import "../src/ERC721Reserve.sol";
import "../test/Mock.t.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract DeployScript is Script {
    address public alice;
    /* address public bob; */
    /* address public charlie; */
    /* address public dave; */

    IERC20 public weth;
    IERC721 public univ3;
    ERC20Reserve public wethReserve;
    ERC721Reserve public univ3Reserve;
    MockOracle public oracle;
    Controller public controller;

    function setUp() public {
        alice = vm.addr(
            0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
        );
        weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        univ3 = IERC721(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    }

    function run() public {
        uint256 deployerPrivateKey = 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6;
        vm.startBroadcast(deployerPrivateKey);
        oracle = new MockOracle();
        controller = new Controller(address(oracle));

        // init weth market
        wethReserve = new ERC20Reserve(
            "Reserve Wrapped ETH",
            "RWETH",
            address(weth),
            address(controller)
        );

        // init univ3 market
        univ3Reserve = new ERC721Reserve(
            address(univ3),
            "Reserve Uniswap v3 LP",
            "RUV3LP"
        );

        // list market
        controller.listLendingMarket(address(wethReserve));
        controller.listLendingMarket(address(univ3Reserve));
        controller.listBorrowingMarket(address(wethReserve));

        // init oracle
        oracle.setPrice(address(weth), 1e18);
        oracle.setPrice(address(univ3), 1e18);

        vm.stopBroadcast();
    }
}
