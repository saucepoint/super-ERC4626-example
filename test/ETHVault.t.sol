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
}
