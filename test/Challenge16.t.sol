// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/Challenge16.sol";

contract Challenge16Test is Test {
    Challenge16 challenge;
    address owner;
    address user1;
    address user2;
    address user3;
    address zeroAddress;
    uint256 constant INITIAL_SUPPLY = 1000000 * 10 ** 18;

    function setUp() public {
        // Set up test accounts
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        zeroAddress = address(0);

        // Deploy contract
        challenge = new Challenge16();

        // Verify initial state
        assertEq(challenge.balanceOf(owner), INITIAL_SUPPLY);
        assertEq(challenge.totalSupply(), INITIAL_SUPPLY);
    }

    // Test basic token properties
    function testTokenProperties() public {
        assertEq(challenge.name(), "BuggyToken11");
        assertEq(challenge.symbol(), "BUG11");
        assertEq(challenge.decimals(), 18);
        assertEq(challenge.totalSupply(), INITIAL_SUPPLY);
    }

    // Test initial balance
    function testInitialBalance() public {
        assertEq(challenge.balanceOf(owner), INITIAL_SUPPLY);
    }

    // Test transfer to zero address
    function testTransferToZeroAddress() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC20: transfer to the zero address");
        challenge.transfer(zeroAddress, 1000);
        vm.stopPrank();
    }

    // Test transfer from zero address
    function testTransferFromZeroAddress() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC20: transfer from the zero address");
        challenge.transferFrom(zeroAddress, user1, 1000);
        vm.stopPrank();
    }

    // Test transfer with insufficient balance
    function testTransferInsufficientBalance() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        challenge.transfer(user1, INITIAL_SUPPLY + 1);
        vm.stopPrank();
    }

    // Test transfer to self
    function testTransferToSelf() public {
        uint256 initialBalance = challenge.balanceOf(owner);
        vm.startPrank(owner);
        challenge.transfer(owner, 1000);
        vm.stopPrank();
        assertEq(challenge.balanceOf(owner), initialBalance);
    }

    // Test approve zero address
    function testApproveZeroAddress() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC20: approve to the zero address");
        challenge.approve(zeroAddress, 1000);
        vm.stopPrank();
    }

    // Test approve from zero address
    function testApproveFromZeroAddress() public {
        vm.startPrank(address(0));
        vm.expectRevert("ERC20: approve from the zero address");
        challenge.approve(user1, 1000);
        vm.stopPrank();
    }

    // Test transferFrom with insufficient allowance
    function testTransferFromInsufficientAllowance() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Set up allowance from user1 to user2
        vm.startPrank(user1);
        challenge.approve(user2, 500);
        vm.stopPrank();

        // Try to transfer more than allowance
        vm.startPrank(user2);
        vm.expectRevert("ERC20: insufficient allowance");
        challenge.transferFrom(user1, user2, 1000);
        vm.stopPrank();
    }

    // Test increaseAllowance
    function testIncreaseAllowance() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Set up initial allowance and increase it
        vm.startPrank(user1);
        challenge.approve(user2, 500);
        challenge.increaseAllowance(user2, 300);
        assertEq(challenge.allowance(user1, user2), 800);
        vm.stopPrank();
    }

    // Test decreaseAllowance below zero
    function testDecreaseAllowanceBelowZero() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Try to decrease allowance below zero
        vm.startPrank(user1);
        challenge.approve(user2, 500);
        vm.expectRevert("ERC20: decreased allowance below zero");
        challenge.decreaseAllowance(user2, 600);
        vm.stopPrank();
    }

    // Test transferFrom with correct allowance
    function testTransferFromWithCorrectAllowance() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Set up allowance and transfer
        vm.startPrank(user1);
        challenge.approve(user2, 1000);
        vm.stopPrank();

        vm.startPrank(user2);
        challenge.transferFrom(user1, user2, 1000);
        assertEq(challenge.balanceOf(user2), 1000);
        assertEq(challenge.balanceOf(user1), 0);
        assertEq(challenge.allowance(user1, user2), 0);
        vm.stopPrank();
    }

    // Test multiple transfers and approvals
    function testMultipleTransfersAndApprovals() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Test multiple approvals
        vm.startPrank(user1);
        challenge.approve(user2, 500);
        challenge.approve(user2, 1000); // Should update allowance
        assertEq(challenge.allowance(user1, user2), 1000);
        vm.stopPrank();
    }

    // Test transfer with maximum uint256 value
    function testTransferWithMaxValue() public {
        uint256 maxValue = type(uint256).max;
        // Only transfer what we have
        vm.startPrank(owner);
        challenge.transfer(user1, INITIAL_SUPPLY);
        vm.stopPrank();
        assertEq(challenge.balanceOf(user1), INITIAL_SUPPLY);
    }

    // Test approval with maximum uint256 value
    function testApproveWithMaxValue() public {
        uint256 maxValue = type(uint256).max;
        vm.startPrank(owner);
        challenge.approve(user1, maxValue);
        vm.stopPrank();
        assertEq(challenge.allowance(owner, user1), maxValue);
    }

    // Test approve with zero amount
    function testApproveZeroAmount() public {
        vm.startPrank(owner);
        challenge.approve(user1, 0);
        vm.stopPrank();
        assertEq(challenge.allowance(owner, user1), 0);
    }

    // Test transfer with same sender and recipient
    function testTransferSameAddress() public {
        uint256 initialBalance = challenge.balanceOf(owner);
        vm.startPrank(owner);
        challenge.transfer(owner, 1000);
        vm.stopPrank();
        assertEq(challenge.balanceOf(owner), initialBalance);
    }

    // Test transferFrom with same sender and recipient
    function testTransferFromSameAddress() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Set up allowance
        vm.startPrank(user1);
        challenge.approve(user2, 1000);
        vm.stopPrank();

        vm.startPrank(user2);
        challenge.transferFrom(user1, user3, 500);
        assertEq(challenge.balanceOf(user1), 500);
        vm.stopPrank();
    }

    // Test transfer with amount greater than total supply
    function testTransferAmountGreaterThanTotalSupply() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        challenge.transfer(user1, INITIAL_SUPPLY + 1);
        vm.stopPrank();
    }

    // Test transferFrom with amount greater than total supply
    function testTransferFromAmountGreaterThanTotalSupply() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Set up allowance
        vm.startPrank(user1);
        challenge.approve(user2, type(uint256).max);
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        challenge.transferFrom(user1, user2, INITIAL_SUPPLY + 1);
        vm.stopPrank();
    }

    // Test transfer with amount equal to total supply
    function testTransferAmountEqualToTotalSupply() public {
        vm.startPrank(owner);
        challenge.transfer(user1, INITIAL_SUPPLY);
        vm.stopPrank();
        assertEq(challenge.balanceOf(user1), INITIAL_SUPPLY);
        assertEq(challenge.balanceOf(owner), 0);
    }

    // Test transferFrom with amount equal to total supply
    function testTransferFromAmountEqualToTotalSupply() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Set up allowance
        vm.startPrank(user1);
        challenge.approve(user2, 1000);
        vm.stopPrank();

        vm.startPrank(user2);
        challenge.transferFrom(user1, user2, 1000);
        assertEq(challenge.balanceOf(user2), 1000);
        assertEq(challenge.balanceOf(user1), 0);
        vm.stopPrank();
    }

    // Test transfer with amount equal to balance
    function testTransferAmountEqualToBalance() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Transfer entire balance
        vm.startPrank(user1);
        challenge.transfer(user2, 1000);
        vm.stopPrank();
        assertEq(challenge.balanceOf(user2), 1000);
        assertEq(challenge.balanceOf(user1), 0);
    }

    // Test transferFrom with amount equal to allowance
    function testTransferFromAmountEqualToAllowance() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Set up allowance and transfer
        vm.startPrank(user1);
        challenge.approve(user2, 1000);
        vm.stopPrank();

        vm.startPrank(user2);
        challenge.transferFrom(user1, user2, 1000);
        assertEq(challenge.balanceOf(user2), 1000);
        assertEq(challenge.balanceOf(user1), 0);
        assertEq(challenge.allowance(user1, user2), 0);
        vm.stopPrank();
    }

    // Test transfer with amount equal to balance minus 1
    function testTransferAmountEqualToBalanceMinusOne() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Transfer balance minus 1
        vm.startPrank(user1);
        challenge.transfer(user2, 999);
        vm.stopPrank();
        assertEq(challenge.balanceOf(user2), 999);
        assertEq(challenge.balanceOf(user1), 1);
    }

    // Test transferFrom with amount equal to allowance minus 1
    function testTransferFromAmountEqualToAllowanceMinusOne() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Set up allowance and transfer
        vm.startPrank(user1);
        challenge.approve(user2, 1000);
        vm.stopPrank();

        vm.startPrank(user2);
        challenge.transferFrom(user1, user2, 999);
        assertEq(challenge.balanceOf(user2), 999);
        assertEq(challenge.balanceOf(user1), 1);
        assertEq(challenge.allowance(user1, user2), 1);
        vm.stopPrank();
    }

    // Test transfer with amount equal to balance plus 1
    function testTransferAmountEqualToBalancePlusOne() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Try to transfer more than balance
        vm.startPrank(user1);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        challenge.transfer(user2, 1001);
        vm.stopPrank();
    }

    // Test transferFrom with amount equal to allowance plus 1
    function testTransferFromAmountEqualToAllowancePlusOne() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1001);
        vm.stopPrank();

        // Set up allowance and try to transfer more
        vm.startPrank(user1);
        challenge.approve(user2, 1000);
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert("ERC20: insufficient allowance");
        challenge.transferFrom(user1, user2, 1001);
        vm.stopPrank();
    }

    // Test transfer with amount equal to balance divided by 2
    function testTransferAmountEqualToBalanceDividedByTwo() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Transfer half of balance
        vm.startPrank(user1);
        challenge.transfer(user2, 500);
        vm.stopPrank();
        assertEq(challenge.balanceOf(user2), 500);
        assertEq(challenge.balanceOf(user1), 500);
    }

    // Test transferFrom with amount equal to allowance divided by 2
    function testTransferFromAmountEqualToAllowanceDividedByTwo() public {
        // First transfer tokens to user1
        vm.startPrank(owner);
        challenge.transfer(user1, 1000);
        vm.stopPrank();

        // Set up allowance and transfer half
        vm.startPrank(user1);
        challenge.approve(user2, 1000);
        vm.stopPrank();

        vm.startPrank(user2);
        challenge.transferFrom(user1, user2, 500);
        assertEq(challenge.balanceOf(user2), 500);
        assertEq(challenge.balanceOf(user1), 500);
        assertEq(challenge.allowance(user1, user2), 500);
        vm.stopPrank();
    }
}
