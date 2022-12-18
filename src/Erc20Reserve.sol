// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IReserve, IBorrowable} from "./IReserve.sol";
import {Controller} from "./Controller.sol";
import "./Oracle.sol";

import "forge-std/console.sol";

contract ERC20Reserve is IReserve, IBorrowable, IERC20, ERC20, Ownable {
    using SafeERC20 for IERC20;
    // Price oracle
    Oracle public oracle;
    // Underlying asset for this Reserve
    address public underlying;
    // Protocol controller
    Controller public controller;

    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }
    // Mapping from account address to outstanding borrow balances
    mapping(address => BorrowSnapshot) public accountBorrows;
    uint256 public exchangeRate;
    uint256 public borrowIndex;
    uint256 public baseRate;
    uint256 public kinkRate;
    uint256 public fullRate;
    uint256 public kinkUtilization;
    uint256 public totalBorrow;

    constructor(
        string memory name_,
        string memory symbol_,
        address underlying_,
        address controller_,
        address oracle_
    ) ERC20(name_, symbol_) {
        exchangeRate = 2e16;
        borrowIndex = 1e18;
        baseRate = 2e16;
        kinkRate = 1e17;
        fullRate = 5e17;
        kinkUtilization = 8e17;
        underlying = underlying_;
        controller = Controller(controller_);
        oracle = Oracle(oracle_);
    }

    function utilization() public view returns (uint256) {
        // totalBorrow / (totalBorrow + totalCash)
        uint256 totalCash = IERC20(underlying).balanceOf(address(this));
        console.log("totalCash:", totalCash);
        console.log("totalBorrow:", totalBorrow);
        return totalBorrow / (totalBorrow + totalCash);
    }

    function nextExchangeRate() public view returns (uint256) {
        // (totalBorrow + totalCash) / totalSupply
        uint256 totalCash = IERC20(underlying).balanceOf(address(this));
        return (totalBorrow + totalCash) / totalSupply();
    }

    function borrowBalanceOf(address account) public view returns (uint256) {
        BorrowSnapshot storage borrowSnapshot = accountBorrows[account];
        if (borrowSnapshot.principal == 0) {
            return 0;
        }
        return (borrowSnapshot.principal * borrowIndex) / borrowSnapshot.interestIndex;
    }

    function supplyBalanceOf(address account) public view returns (uint256) {
        uint256 reserveBalance = balanceOf(account);
        return reserveBalance * exchangeRate / 1e18;
    }

    function borrowAPY() public view returns (uint256) {
        uint256 util = utilization();
        if (util <= kinkUtilization) {
            return util * (kinkRate - baseRate) / kinkUtilization + baseRate;
        } else {
            uint256 excessUtil = util - kinkUtilization;
            return excessUtil * (fullRate - kinkRate) / (1e18 - kinkUtilization) + kinkRate;
        }
    }

    function supplyAPY() public view returns (uint256) {
        return borrowAPY() * utilization() / 1e18;
    }

    function accrueInterest() public returns (uint256) {
        
    }

    function supply(uint256 amount) external returns (uint256) {
        IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);
        uint256 mintAmount = amount * 1e18 / exchangeRate;
        _mint(msg.sender, mintAmount);

        return 0;
    }

    function withdrawAllowed(address account, uint256 amount) public {
        uint256 priceMantissa = getUnderlyingPrice();
        uint256 redeemEffects = (amount * priceMantissa) / 1e18;
        uint256 liquidity = controller.getAccountLiquidity(account);
        console.log("priceMantissa:", priceMantissa);
        console.log("redeemEffects:", redeemEffects);
        console.log("liquidity:", liquidity);
        require(
            redeemEffects < liquidity,
            "ERC20Reserve: insufficient liquidity"
        );
        require(
            supplyBalanceOf(account) >= amount,
            "ERC20Reserve: redeem transfer amount exceeds position"
        );
    }

    function withdraw(uint256 amount) external returns (uint256) {
        withdrawAllowed(msg.sender, amount);
        uint256 burnAmount = amount * 1e18 / exchangeRate;
        _burn(msg.sender, burnAmount);
        IERC20(underlying).safeTransfer(msg.sender, amount);

        return 0;
    }

    function borrowAllowed(address account, uint256 amount) public {
        uint256 priceMantissa = getUnderlyingPrice();
        uint256 borrowEffects = (amount * priceMantissa) / 1e18;
        uint256 liquidity = controller.getAccountLiquidity(account);
        console.log("priceMantissa:", priceMantissa);
        console.log("borrowEffects:", borrowEffects);
        console.log("liquidity:", liquidity);
        require(
            borrowEffects < liquidity,
            "ERC20Reserve: insufficient liquidity"
        );
    }

    function borrow(uint256 amount) external returns (uint256) {
        borrowAllowed(msg.sender, amount);
        uint256 borrowBalance = borrowBalanceOf(msg.sender);
        accountBorrows[msg.sender].principal = borrowBalance + amount;
        accountBorrows[msg.sender].interestIndex = borrowIndex;
        IERC20(underlying).safeTransfer(msg.sender, amount);

        return 0;
    }

    function repay(uint256 amount) external returns (uint256) {
        uint256 borrowBalance = borrowBalanceOf(msg.sender);
        require(
            amount <= borrowBalance,
            "ERC20Reserve: insufficient borrow balance"
        );
        accountBorrows[msg.sender].principal = borrowBalance - amount;
        accountBorrows[msg.sender].interestIndex = borrowIndex;
        IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);

        return 0;
    }

    function getUnderlyingPrice() public view returns (uint256) {
        return oracle.getPrice(underlying);
    }

    function accountCollateral(
        address account
    ) external view returns (uint256) {
        uint256 balance = supplyBalanceOf(account);
        uint256 underlyingPriceMantissa = getUnderlyingPrice();
        console.log("account:", account);
        console.log("balance:", balance);
        console.log("price:", underlyingPriceMantissa);
        return (balance * underlyingPriceMantissa) / 1e18;
    }

    function accountBorrowing(address account) external view returns (uint256) {
        uint256 borrowBalance = borrowBalanceOf(account);
        uint256 underlyingPriceMantissa = getUnderlyingPrice();
        return (borrowBalance * underlyingPriceMantissa) / 1e18;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165) returns (bool) {
        return
            interfaceId == type(IReserve).interfaceId ||
            interfaceId == type(IBorrowable).interfaceId ||
            interfaceId == type(IERC20).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
