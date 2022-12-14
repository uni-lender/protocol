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
    IERC20 public weth;
    IERC20 public wbtc;
    IERC20 public dai;
    IERC20 public usdc;
    IERC721 public univ3;
    ERC20Reserve public wethReserve;
    ERC20Reserve public wbtcReserve;
    ERC20Reserve public daiReserve;
    ERC20Reserve public usdcReserve;
    ERC721Reserve public univ3Reserve;
    MockOracle public oracle;
    Controller public controller;

    function setUp() public {
        weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        univ3 = IERC721(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    }

    function run() public {
        uint256 deployerPrivateKey = 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6;
        vm.startBroadcast(deployerPrivateKey);
        oracle = new MockOracle();
        controller = new Controller(address(oracle));

        wethReserve = new ERC20Reserve(
            "Reserve Wrapped ETH",
            "RWETH",
            address(weth),
            address(controller),
            address(oracle),
            8e17
        );
        wbtcReserve = new ERC20Reserve(
            "Reserve Wrapped BTC",
            "RWBTC",
            address(wbtc),
            address(controller),
            address(oracle),
            8e17
        );
        daiReserve = new ERC20Reserve(
            "Reserve DAI",
            "RDAI",
            address(dai),
            address(controller),
            address(oracle),
            8e17
        );
        usdcReserve = new ERC20Reserve(
            "Reserve USDC",
            "RUSDC",
            address(usdc),
            address(controller),
            address(oracle),
            8e17
        );
        univ3Reserve = new ERC721Reserve(
            "Reserve Uniswap v3 LP",
            "RUV3LP",
            address(univ3),
            address(oracle),
            8e17
        );

        controller.listLendingMarket(address(wethReserve));
        controller.listLendingMarket(address(wbtcReserve));
        controller.listLendingMarket(address(daiReserve));
        controller.listLendingMarket(address(usdcReserve));
        controller.listLendingMarket(address(univ3Reserve));

        controller.listBorrowingMarket(address(wethReserve));
        controller.listBorrowingMarket(address(wbtcReserve));
        controller.listBorrowingMarket(address(daiReserve));
        controller.listBorrowingMarket(address(usdcReserve));

        oracle.setPrice(address(weth), 1e18);
        oracle.setPrice(address(wbtc), 14122000170000000000);
        oracle.setPrice(address(dai), 842195727011508);
        oracle.setPrice(address(usdc), 843573526469612);

        vm.stopBroadcast();
    }
}
