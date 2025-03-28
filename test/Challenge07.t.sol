// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity >=0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {Challenge07} from "../src/Challenge07.sol";

contract Challenge07Test is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    Challenge07 public token;
    address public owner;
    address public user1;
    address public user2;
    address public zeroAddress;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        zeroAddress = address(0);

        token = new Challenge07();
    }

    // Test Initial State
    function testInitialState() public {
        assertEq(token.name(), "BuggyToken7");
        assertEq(token.symbol(), "BUG7");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 1000000 * 10 ** 18);
        assertEq(token.balanceOf(owner), 1000000 * 10 ** 18);
    }

    // Test Transfer Functionality
    function testTransfer() public {
        uint256 amount = 100 * 10 ** 18;
        token.transfer(user1, amount);
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.balanceOf(owner), 1000000 * 10 ** 18 - amount);
    }

    function testTransferToZeroAddress() public {
        vm.expectRevert(Challenge07.ERC20InvalidReceiver.selector);
        token.transfer(zeroAddress, 100 * 10 ** 18);
    }

    function testTransferInsufficientBalance() public {
        vm.expectRevert(Challenge07.ERC20InsufficientBalance.selector);
        token.transfer(user1, 2000000 * 10 ** 18);
    }

    // Test Allowance and Approval
    function testApprove() public {
        uint256 amount = 100 * 10 ** 18;
        token.approve(user1, amount);
        assertEq(token.allowance(owner, user1), amount);
    }

    function testApproveZeroAddress() public {
        vm.expectRevert(Challenge07.ERC20InvalidSpender.selector);
        token.approve(zeroAddress, 100 * 10 ** 18);
    }

    // Test TransferFrom
    function testTransferFrom() public {
        uint256 amount = 100 * 10 ** 18;
        token.approve(user1, amount);
        vm.prank(user1);
        token.transferFrom(owner, user2, amount);
        assertEq(token.balanceOf(user2), amount);
        assertEq(token.allowance(owner, user1), 0);
    }

    function testTransferFromInsufficientAllowance() public {
        uint256 amount = 100 * 10 ** 18;
        token.approve(user1, amount);
        vm.prank(user1);
        vm.expectRevert("Challenge07: insufficient allowance");
        token.transferFrom(owner, user2, amount + 1);
    }

    // Test Mint Functionality
    function testMint() public {
        uint256 amount = 100 * 10 ** 18;
        token.mint(user1, amount);
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.totalSupply(), 1000000 * 10 ** 18 + amount);
    }

    function testMintByNonOwner() public {
        uint256 amount = 100 * 10 ** 18;
        vm.prank(user1);
        vm.expectRevert(Challenge07.Unauthorized.selector);
        token.mint(user2, amount);
    }

    function testMintToZeroAddress() public {
        uint256 amount = 100 * 10 ** 18;
        vm.expectRevert(Challenge07.ERC20InvalidReceiver.selector);
        token.mint(zeroAddress, amount);
    }

    // Test Events
    function testTransferEvent() public {
        uint256 amount = 100 * 10 ** 18;
        vm.expectEmit(true, true, false, false);
        emit Transfer(owner, user1, amount);
        token.transfer(user1, amount);
    }

    function testApprovalEvent() public {
        uint256 amount = 100 * 10 ** 18;
        vm.expectEmit(true, true, false, false);
        emit Approval(owner, user1, amount);
        token.approve(user1, amount);
    }

    // Test Edge Cases
    function testTransferZeroAmount() public {
        token.transfer(user1, 0);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(owner), 1000000 * 10 ** 18);
    }

    function testApproveZeroAmount() public {
        token.approve(user1, 0);
        assertEq(token.allowance(owner, user1), 0);
    }

    function testTransferFromZeroAmount() public {
        token.approve(user1, 100 * 10 ** 18);
        vm.prank(user1);
        token.transferFrom(owner, user2, 0);
        assertEq(token.balanceOf(user2), 0);
        assertEq(token.allowance(owner, user1), 100 * 10 ** 18);
    }

    // Test Maximum Allowance
    function testTransferFromMaxAllowance() public {
        uint256 amount = 100 * 10 ** 18;
        token.approve(user1, type(uint256).max);
        vm.prank(user1);
        token.transferFrom(owner, user2, amount);
        assertEq(token.balanceOf(user2), amount);
        assertEq(token.allowance(owner, user1), type(uint256).max);
    }
}
