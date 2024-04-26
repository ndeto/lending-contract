// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {HarakaLoan} from "../src/HarakaLoan.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract HarakaLoanTest is Test {
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address lenderAddress = 0x5c44960332c00D00a05ae89e8F2Ce520a589b2e8;
    address borrower = 0x0181f12c85113b5FB4A4F1AbF8dBfd9ec8E77Efb;

    HarakaLoan public harakaloan;
    uint256 bsc;

    function setUp() public {
        // Create a fork of BSC using RPC Url and recent block number
        bsc = vm.createSelectFork("https://binance.llamarpc.com", 38195827);

        // Deploy the test contract
        harakaloan = new HarakaLoan();

        // Increase loan limit for our borrower
        vm.prank(borrower);
        harakaloan.increaseLoanLimit(1000);
    }

    function testBorrowLoan() public {
        // Make the call as borrower
        vm.prank(borrower);
        uint256 balance = harakaloan.borrowLoan(200);
        assertEq(balance, 800);
    }

    function testSupplyLiquidity() public {
        // Select current fork
        vm.selectFork(bsc);

        // Give our lender provider some tokens
        deal(WBNB, address(lenderAddress), 10 ** 18);
        
        // Approve the contract to spend our tokens
        vm.prank(lenderAddress);
        IERC20(WBNB).approve(address(harakaloan), 10 ** 9);

        // Call contract as our lender provider
        vm.prank(lenderAddress);
        bool lend = harakaloan.lendFunds(10 ** 9);

        // Confirm call was successful
        assertEq(lend, true);

        // Check erc20 balance of the contract loan and compare
        uint256 bal = IERC20(WBNB).balanceOf(address(harakaloan));
        assertEq(bal, 10**9);
    }
}
