// SPDX-License-Identifier: MIT

// solidity version
pragma solidity 0.8.30;

import "../src/Escrow.sol";
import "forge-std/Test.sol";

contract EscrowTest is Test {

    Escrow escrow;
    address public buyer = vm.addr(1);
    address public seller = vm.addr(2);
    uint256 public transactAmount = 1000;
    function setUp() public {
        escrow = new Escrow(buyer, seller, transactAmount);
    }

    // unit testing

    function testCheckTransactAmount() public view {
        uint256 transactAmount_ = escrow.transactAmount();
        assert(transactAmount_ == transactAmount);
    }

    function testCorrectAmountByBuyer() public {
        // Provide ETH to Buyer
        vm.deal(buyer, 10000);
        
        // Simulate we are the buyer address
        vm.startPrank(buyer);
        escrow.deposit{value: transactAmount} ();
        vm.stopPrank();

        assertTrue(escrow.funded());
        assertFalse(escrow.completed());
        assertEq(address(escrow).balance, transactAmount);
      }

    function testDepositIncorrectBuyer() public {
        address other = vm.addr(3);
        vm.deal(other, 10000); 
        vm.startPrank(other);
        vm.expectRevert();
        escrow.deposit{value: transactAmount} ();
        vm.stopPrank();
    }

    function testReleaseOnlyBuyer() public {
        address other = vm.addr(3);
        vm.deal(other, 10000);
        vm.deal(buyer, 10000);

        vm.startPrank(buyer);
        escrow.deposit{value: transactAmount} ();
        vm.stopPrank();

        vm.startPrank(other);
        vm.expectRevert();
        escrow.release();
        vm.stopPrank();
    }

    function testReleaseDoneCorrectly() public {
        vm.deal(buyer, 10000);

        vm.startPrank(buyer);
        escrow.deposit{value: transactAmount} ();
        escrow.release();
        vm.stopPrank();

        assertTrue(escrow.funded());
        assertTrue(escrow.completed());
        assertEq(address(escrow).balance, 0);        
    }

    function testRefundOnlyBuyer() public {
        address other = vm.addr(3);
        vm.deal(buyer, 10000);
        vm.deal(other, 10000);

        vm.startPrank(buyer);
        escrow.deposit{value: transactAmount} ();
        vm.stopPrank();

        vm.startPrank(other);
        vm.expectRevert();
        escrow.refund();
        vm.stopPrank();
    }

    function testRefundDoneCorrectly() public {
        vm.deal(buyer, 10000);
        
        vm.startPrank(buyer);
        escrow.deposit{value: transactAmount} ();
        escrow.refund();
        vm.stopPrank();

        assertTrue(escrow.funded());
        assertTrue(escrow.completed());
        assertEq(address(escrow).balance, 0);
    }

    function testCannotReleaseAndRefund() public {
        vm.deal(buyer, 10000);
        vm.startPrank(buyer);
        escrow.deposit{value: transactAmount} ();
        escrow.release();
        vm.expectRevert();
        escrow.refund();
        vm.stopPrank();
    }
    
    // Fuzzing test

    function testFuzzingAmount(uint256 amount) public {
        vm.assume(amount != transactAmount);
        
        vm.deal(buyer, amount);
        
        vm.startPrank(buyer);
        vm.expectRevert();
        escrow.deposit{value: amount} ();
        vm.stopPrank();
    }

    function testDepositRevertIfNotBuyer(address a) public {
        vm.deal(a, transactAmount);
        vm.startPrank(a);
        vm.expectRevert();
        escrow.deposit{value: transactAmount} ();
        vm.stopPrank();
    }

    function testCannotDepositTwice(uint256 extraFunds) public {
        vm.assume(extraFunds < 1000 ether);

        vm.deal(buyer, transactAmount + extraFunds);

        vm.startPrank(buyer);
        escrow.deposit{value: transactAmount} ();
        vm.expectRevert();
        escrow.deposit{value: extraFunds} ();
        vm.stopPrank();
    }
} 