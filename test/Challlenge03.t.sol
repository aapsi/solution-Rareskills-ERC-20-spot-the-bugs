// SPDX-License_Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Challenge03} from "../src/Challenge03.sol";

contract ERC20Test is Test {
    Challenge03 public erc20;

    function setUp() public {
        vm.prank(address(1));
        erc20 = new Challenge03();
    }

    function test_ERC20_Constructor() public view {
        assertEq(erc20.name(), "BuggyToken3");
        assertEq(erc20.symbol(), "BUG3");
        assertEq(erc20.decimals(), 18);
        assertEq(erc20.balanceOf(address(1)), 1000000e18);
    }

    function test_ERC20_totalSupply() public view {
        assertEq(erc20.totalSupply(), 1000000e18);
    }

    function test_ERC20_transfer() public {
        vm.prank(address(1));
        assertEq(erc20.transfer(address(1234), 0), true);
        assertEq(erc20.balanceOf(address(1234)), 0);
    }

    function test_ERC20_transfer_reverts_sender_address_0() public {
        vm.prank(address(0));
        vm.expectRevert("Invalid sender");

        vm.deal(address(0), 10e18);
        erc20.transfer(address(1234), 10e18);
    }

    function test_ERC20_transfer_reverts_receiver_is_address_0() public {
        vm.expectRevert();
        vm.prank(address(123));
        vm.deal(address(123), 10e18);
        erc20.transfer(address(0), 10e18);
    }

    function test_ERC20_transfer_reverts_insufficient_sender_balance() public {
        vm.prank(address(123));
        vm.expectRevert();
        erc20.transfer(address(1234), 20e18);
    }

    function test_ERC20_approve() public {
        vm.prank(address(123));
        assertEq(erc20.approve(address(1234), 2e18), true);
        assertEq(erc20.allowance(address(123), address(1234)), 2e18);
    }

    function test_ERC20_approve_revert_approver_address_0() public {
        vm.prank(address(0));
        vm.expectRevert();
        erc20.approve(address(123), 1e18);
    }

    function test_ERC20_approve_revert_receiver_address_0() public {
        vm.expectRevert();
        vm.prank(address(123));
        erc20.approve(address(0), 1e18);
    }

    function test_ERC20_transferFrom() public {
        vm.prank(address(1));
        erc20.approve(address(1234), 2e18);
        vm.prank(address(1234));
        assertEq(erc20.transferFrom(address(1), address(12345), 2e18), true);
    }

    function test_ERC20_transferFrom_revert_spender_address_0() public {
        vm.prank(address(123));
        erc20.approve(address(1234), 2e18);
        vm.prank(address(0));
        vm.expectRevert();
        erc20.transferFrom(address(123), address(1), 2e18);
    }

    function test_ERC20_transferFrom_revert_spender_invalid_alowance() public {
        vm.prank(address(123));
        erc20.approve(address(1234), 1e18);
        vm.prank(address(1234));
        vm.expectRevert();
        erc20.transferFrom(address(123), address(1), 2e18);
    }

    function test_ERC20_transferFrom_revert_receiver_address_0() public {
        vm.prank(address(123));
        erc20.approve(address(1234), 2e18);
        vm.prank(address(1234));
        vm.expectRevert();
        erc20.transferFrom(address(123), address(0), 2e18);
    }
}
