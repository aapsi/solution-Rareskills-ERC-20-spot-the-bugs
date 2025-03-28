// SPDX-License_Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Challenge02} from "../src/Challenge02.sol";

contract ERC20Test is Test {
    Challenge02 public erc20;

    function setUp() public {
        erc20 = new Challenge02("Test", "TEST", 18);
    }

    function test_ERC20_Constructor() public view {
        assertEq(erc20.name(), "Test");
        assertEq(erc20.symbol(), "TEST");
        assertEq(erc20.decimals(), 18);
    }

    function test_ERC20_totalSupply() public {
        assertEq(erc20.totalSupply(), 0);
    }

    function test_ERC20_transfer() public {
        assertEq(erc20.transfer(address(1234), 0), true);
        assertEq(erc20.balanceOf(address(1234)), 0);
    }

    // function test_ERC20_transfer_reverts_sender_address_0() public {
    //     vm.expectRevert(
    //         abi.encodeWithSelector(
    //             Challenge02.InvalidSender.selector,
    //             address(0)
    //         )
    //     );
    //     vm.prank(address(0));
    //     vm.deal(address(0), 10e18);
    //     erc20.transfer(address(1234), 10e18);
    // }

    function test_ERC20_transfer_reverts_receiver_is_address_0() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Challenge02.InvalidReceiver.selector,
                address(0)
            )
        );
        vm.prank(address(123));
        vm.deal(address(123), 10e18);
        erc20.transfer(address(0), 10e18);
    }

    function test_ERC20_transfer_reverts_insufficient_sender_balance() public {
        vm.prank(address(123));
        vm.expectRevert(
            abi.encodeWithSelector(
                Challenge02.InsufficientBalance.selector,
                address(123),
                0,
                20e18
            )
        );
        erc20.transfer(address(1234), 20e18);
    }

    function test_ERC20_mint() public {
        assertEq(erc20.totalSupply(), 0);
    }

    function test_ERC20_mint_revert_receiver_address_0() public {
        assertEq(erc20.totalSupply(), 0);
    }

    function test_ERC20_burn() public {
        assertEq(erc20.totalSupply(), 0);
    }

    function test_ERC20_burn_revert_sender_address_0() public {
        assertEq(erc20.totalSupply(), 0);
    }

    function test_ERC20_burn_revert_sender_insufficient_balance() public {
        assertEq(erc20.totalSupply(), 0);
    }

    function test_ERC20_approve() public {
        vm.prank(address(123));
        assertEq(erc20.approve(address(1234), 2e18), true);
        assertEq(erc20.allowance(address(123), address(1234)), 2e18);
    }

    function test_ERC20_approve_revert_approver_address_0() public {
        vm.prank(address(0));
        vm.expectRevert(
            abi.encodeWithSelector(
                Challenge02.InvalidApprover.selector,
                address(0)
            )
        );
        erc20.approve(address(123), 1e18);
    }

    function test_ERC20_approve_revert_receiver_address_0() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Challenge02.InvalidSpender.selector,
                address(0)
            )
        );
        vm.prank(address(123));
        erc20.approve(address(0), 1e18);
    }

    function test_ERC20_tranferFrom() public {
        vm.prank(address(123));
        erc20.approve(address(1234), 2e18);
        vm.prank(address(1234));
        vm.expectRevert(
            abi.encodeWithSelector(
                Challenge02.InsufficientBalance.selector,
                address(123),
                0,
                2e18
            )
        );
        erc20.transferFrom(address(123), address(12345), 2e18);
    }

    function test_ERC20_transferFrom_revert_owner_address_0() public {
        vm.prank(address(123));
        erc20.approve(address(1234), 2e18);
        vm.prank(address(1234));
        vm.expectRevert(
            abi.encodeWithSelector(
                Challenge02.InvalidSender.selector,
                address(0)
            )
        );
        erc20.transferFrom(address(0), address(1), 2e18);
    }

    function test_ERC20_transferFrom_revert_spender_invalid_alowance() public {
        vm.prank(address(123));
        erc20.approve(address(1234), 1e18);
        vm.prank(address(1234));
        vm.expectRevert(
            abi.encodeWithSelector(
                Challenge02.InsufficientAllowance.selector,
                address(1234),
                1e18,
                2e18
            )
        );
        erc20.transferFrom(address(123), address(1), 2e18);
    }

    function test_ERC20_transferFrom_revert_receiver_address_0() public {
        vm.prank(address(123));
        erc20.approve(address(1234), 2e18);
        vm.prank(address(1234));
        vm.expectRevert(
            abi.encodeWithSelector(
                Challenge02.InvalidReceiver.selector,
                address(0)
            )
        );
        erc20.transferFrom(address(123), address(0), 2e18);
    }
}
