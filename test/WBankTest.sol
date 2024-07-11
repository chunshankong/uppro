pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {WBank} from "../src/WBank.sol";

contract WBankTest is Test {
    WBank public bank;

    function setUp() public {
        bank = new WBank();
    }

    function test_deposit() public {
      
        address user = address(0x37D5F39EB1F63B471D30b1Ede3F8d6eeBc3aFC47);
        console.log(user); 
    
        vm.deal(user, 6 ether);

        vm.prank(user); // msg.sender
      
        uint256 amount = 2;
        
        bank.depositETH{value: amount}();
        
        uint balance = bank.balanceOf(user);
    

        assertEq(balance, amount, "Wrong balance");

    }

    function test_noDeposit() public {
        address user = address(0xa3A7a52Ffd0a44Eacf276Af28657DAfB424805F1);
        console.log(user); 
    
        vm.deal(user, 6 ether);
        vm.prank(user); // msg.sender
        
        // bank.depositETH{value: 0}();
        
        uint balance = bank.balanceOf(user);
    
        assertEq(balance, 0, "Wrong balance");
    }

      function test_DepositEvent() public {
        address user = address(0xa3A7a52Ffd0a44Eacf276Af28657DAfB424805F1);

        vm.deal(user, 6 ether);
        vm.prank(user); 
        uint256 amount = 2;

        vm.expectEmit(true, false, false, true);
        emit WBank.Deposit(user, amount); 

        bank.depositETH{value: amount}(); 
    }

}