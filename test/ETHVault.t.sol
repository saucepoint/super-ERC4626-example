// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {ETHVault} from "../src/ETHVault.sol";

contract ETHVaultTest is Test {
    address alice = address(0xBEEF);
    ETHVault ethVault;
    WETH weth;

    function setUp() public {
        weth = new WETH();
        ethVault = new ETHVault(address(weth));

        vm.deal(alice, 1 ether);
        vm.prank(alice);
        weth.deposit{value: 1 ether}();

        vm.deal(address(this), 1 ether);
        weth.deposit{value: 1 ether}();
        assertEq(weth.balanceOf(address(this)), 1 ether);
        weth.transfer(address(ethVault), 1 ether);
    }

    function testDeposit() public {
        vm.startPrank(alice);
        weth.approve(address(ethVault), 1 ether);
        ethVault.deposit(1 ether, alice);

        uint256 aliceBalance = ethVault.balanceOf(alice);
        assertEq(aliceBalance, 1 ether);

        assertEq(ethVault.totalAssets(), 2 ether);
        assertEq(ethVault.previewRedeem(aliceBalance), 2 ether);
    }

    function testWithdraw() public {
        vm.startPrank(alice);
        weth.approve(address(ethVault), 1 ether);
        ethVault.deposit(1 ether, alice);

        uint256 aliceBalance = ethVault.balanceOf(alice);
        assertEq(aliceBalance, 1 ether);

        assertEq(ethVault.totalAssets(), 2 ether);
        assertEq(ethVault.previewRedeem(aliceBalance), 2 ether);

        ethVault.redeem(aliceBalance, alice, alice);

        assertEq(ethVault.totalAssets(), 0);
        assertEq(weth.balanceOf(alice), 2 ether);
    }

    // de
    function testDepositWrap() public {
        vm.deal(address(alice), 1 ether);

        vm.startPrank(alice);
        weth.approve(address(ethVault), 1 ether);
        ethVault.deposit(1 ether, alice);

        uint256 aliceBalance = ethVault.balanceOf(alice);
        assertEq(aliceBalance, 1 ether);

        // add pure ETH to the vault so we can test the wrapping on withdraw
        (bool sent,) = address(ethVault).call{value: 1 ether}("");
        assertEq(sent, true);

        assertEq(ethVault.totalAssets(), 3 ether);
        assertEq(ethVault.previewRedeem(aliceBalance), 3 ether);

        ethVault.redeem(aliceBalance, alice, alice);

        assertEq(ethVault.totalAssets(), 0);
        assertEq(weth.balanceOf(alice), 3 ether);
    }
}
