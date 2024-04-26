// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.13;

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";

contract HarakaLoan {
  // This is a mapping of the users and their respective loan limits
  mapping(address => uint256) public loanLimit;

  // ERC20 Contract address
  address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
  address liquidityProvider = 0x5c44960332c00D00a05ae89e8F2Ce520a589b2e8;

  // Borrow a loan
  function borrowLoan(uint256 amount) public returns (uint256){
    // ensure the user can borrow the amount
    require(loanLimit[msg.sender] >= amount, "Exceedeed loan limit");

    // deduct the loan limit. 
    // Rentrancy guard to be implemented incase execution is passed to another contract
    loanLimit[msg.sender] = loanLimit[msg.sender] - amount;

    // return loanlimit balance
    return loanLimit[msg.sender];
  }

  // function to increase loan limit
  // Should have an authorization modifier `onlyOwner`
  function increaseLoanLimit(uint256 limit) public {
    loanLimit[msg.sender] = limit;
  }

  
  // Called by lenders to provide liquidity to this contract
  // Suggested modifications:
  // If we need to implement this here, best way to do it is by doing a delegatecall
  // This function would take token address and amount then do a delegatecall 
  // to the token contract to transfer the tokens into this contract.
  // This would be better than the implementation below.
  // Add logic to keep track of lenders funds

  function lendFunds(uint256 amount) external returns (bool res){
    // Approve this contract to spend their ERC20 tokens from the contract
    res = IERC20(WBNB).transferFrom(msg.sender, address(this), amount);
  } 
}