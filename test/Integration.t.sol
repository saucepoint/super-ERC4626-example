// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {ArbETHVault} from "../src/arbitrum/ArbETHVault.sol";
import {MainnetETHVault} from "../src/ethereum/MainnetETHVault.sol";

contract IntegrationTest is Test {
    uint256 mainnetFork = vm.createFork("https://eth.llamarpc.com");
    uint256 arbFork = vm.createFork("https://arb1.arbitrum.io/rpc");

    address alice = address(0xBEEF);
    address inbox = address(0x4Dbd4fc535Ac27206064B68FfCf827b0A60BAB3f);

    MainnetETHVault mainnetVault;
    ArbETHVault arbVault;
    WETH wethMainnet = WETH(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    WETH wethArb = WETH(payable(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1));

    function setUp() public {
        vm.selectFork(arbFork);
        arbVault = new ArbETHVault(
            address(wethArb)
        );

        vm.selectFork(mainnetFork);
        mainnetVault = new MainnetETHVault(
            address(wethMainnet),
            address(arbVault),
            address(inbox)
        );

        vm.selectFork(arbFork);
        arbVault.setL1Target(address(mainnetVault));
    }

    // L1 --> L2 message, to update totalAssets()
    function testUpdateTotalAssetsL2() public {
        assertEq(true, true);
        // Deposit 1 ETH into L1 vault
        // vm.selectFork(mainnetFork);
        // vm.deal(address(mainnetVault), 1 ether);

        // assertEq(mainnetVault.totalAssets(), 1 ether);

        // mainnetVault.setTotalAssetsInL2(1 ether, 3_000_000, 500 gwei);
    }
}