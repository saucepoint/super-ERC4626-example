// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {ArbETHVault} from "../src/arbitrum/ArbETHVault.sol";
import "@arbitrum/nitro-contracts/src/libraries/AddressAliasHelper.sol";

contract ArbETHVaultTest is Test {
    address alice = address(0xBEEF);
    ArbETHVault vault;
    WETH weth;

    function setUp() public {
        weth = new WETH();
        vault = new ArbETHVault(address(weth));
        vault.setL1Target(address(0x1234));
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
        vm.startPrank(AddressAliasHelper.applyL1ToL2Alias(vault.l1Target()));
        vault.setTotalAssets(address(vault).balance + weth.balanceOf(address(vault)));
        vm.stopPrank();

        assertEq(vault.totalAssets(), 2 ether);
        assertEq(vault.previewRedeem(aliceBalance), 2 ether);
    }
}
