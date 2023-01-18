// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {ArbETHVault} from "../src/arbitrum/ArbETHVault.sol";

contract ArbETHVaultTest is Test {
    address alice = address(0xBEEF);
    ArbETHVault vault;
    WETH weth;

    function setUp() public {
        weth = new WETH();
        vault = new ArbETHVault(address(weth));
    }

    function testWrapAndDeposit() public {
        vm.deal(alice, 1 ether);
        vm.startPrank(alice);
        vault.wrapAndDeposit{value: 1 ether}();
        vm.stopPrank();

        uint256 aliceBalance = vault.balanceOf(alice);
        assertEq(aliceBalance, 1 ether);
        assertEq(vault.totalAssets(), 1 ether);
        assertEq(vault.previewRedeem(aliceBalance), 1 ether);

        vm.deal(address(vault), 1 ether);
        // manually update total assets (would be done via message passing)
        // we want to verify that wrapAndDeposit() does proper accounting
        vault.setTotalAssets(address(vault).balance + weth.balanceOf(address(vault)));

        assertEq(vault.totalAssets(), 2 ether);
        assertEq(vault.previewRedeem(aliceBalance), 2 ether);
    }
}
