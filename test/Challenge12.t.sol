// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Challenge12} from "../src/Challenge12.sol";

contract Challenge12Test is Test {
    Challenge12 challenge;
    address owner = address(0x1);

    address user1 = address(0x2);
    address user2 = address(0x3);
    address user3 = address(0x4);
    address user4 = address(0x5);
    address user5 = address(0x6);

    function setUp() public {
        vm.startPrank(owner);
        challenge = new Challenge12("Test", "TEST", 18);
        vm.stopPrank();
    }

    function test_transfer_zero_address() public {
        vm.expectRevert("ERC20: transfer to the zero address");
        challenge.transfer(address(0), 100);
    }

    function test_transfer_insufficient_balance() public {
        vm.expectRevert("ERC20: insufficient balance");
        challenge.transfer(user1, 100);
    }

    function test_transfer_insufficient_allowance() public {
        vm.startPrank(owner);
        challenge.gift(user1, 100);
        vm.stopPrank();
        vm.expectRevert("ERC20: insufficient allowance");
        vm.prank(user2);
        challenge.transferFrom(user1, user3, 100);
    }

    function test_approve_zero_address() public {
        vm.expectRevert("ERC20: approve to the zero address");
        challenge.approve(address(0), 100);
    }

    function test_gift_zero_address() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC20: gift to the zero address");
        challenge.gift(address(0), 100);
        vm.stopPrank();
    }

    function test_gift_zero_amount() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC20: gift amount must be greater than zero");
        challenge.gift(user1, 0);
        vm.stopPrank();
    }

    function test_gift_success() public {
        vm.startPrank(owner);
        challenge.gift(user1, 100);
        vm.stopPrank();

        assertEq(challenge.balanceOf(user1), 100);
        assertEq(challenge.totalSupply(), 100);
    }
}
