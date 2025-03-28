// SPDX-License_Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Challenge04} from "../src/Challenge04.sol";

contract ERC20Test is Test {
    Challenge04 public erc20;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Paused(address account);
    event Unpaused(address account);

    function setUp() public {
        vm.prank(address(1));
        erc20 = new Challenge04();
    }

    function test_ERC20_Constructor() public view {
        assertEq(erc20.name(), "BuggyToken4");
        assertEq(erc20.symbol(), "BUG4");
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

    function test_ERC20_transfer_revert_paused() public {
        vm.prank(address(1));
        erc20.pause();
        vm.prank(address(1));
        vm.expectRevert("Challenge4: transfers paused");
        erc20.transfer(address(1234), 1e18);
    }

    function test_ERC20_transfer_reverts_sender_address_0() public {
        vm.prank(address(0));
        vm.expectRevert("Challenge4: transfer from zero address");
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

    function test_ERC20_tranferFrom() public {
        vm.prank(address(1));
        erc20.approve(address(1234), 2e18);
        vm.prank(address(1234));
        assertEq(erc20.transferFrom(address(1), address(12345), 2e18), true);
    }

    function test_ERC20_transferFrom_revert_owner_address_0() public {
        vm.prank(address(1));
        erc20.approve(address(1234), 2e18);
        vm.prank(address(1234));
        vm.expectRevert("Challenge4: token owner zero address");
        erc20.transferFrom(address(0), address(12345), 2e18);
    }

    function test_ERC20_transferFrom_revert_spender_address_0() public {
        vm.prank(address(123));
        erc20.approve(address(1234), 2e18);
        vm.prank(address(0));
        vm.expectRevert("Challenge4: spender zero address");
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

    function test_ERC20_unpause() public {
        vm.prank(address(1));
        erc20.pause();
        vm.prank(address(1));
        vm.expectEmit(true, false, false, true);
        emit Unpaused(address(1));
        erc20.unpause();
    }

    function test_ERC20_unpause_revert() public {
        vm.prank(address(1));
        vm.expectRevert("Challenge4: not paused");
        erc20.unpause();
    }
}
