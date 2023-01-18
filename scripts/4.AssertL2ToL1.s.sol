// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {ArbETHVault} from "../src/arbitrum/ArbETHVault.sol";
import {MainnetETHVault} from "../src/ethereum/MainnetETHVault.sol";

contract SimulateL1ToL2 is Script {
    uint256 mainnetFork = vm.createFork("http://127.0.0.1:8545");
    uint256 arbFork = vm.createFork("http://127.0.0.1:8547");

    address arbAccount = address(0x683642c22feDE752415D4793832Ab75EFdF6223c);
    address ethAccount = address(0x3f1Eae7D46d88F08fc2F8ed27FCb2AB183EB2d0E);

    MainnetETHVault mainnetVault;
    ArbETHVault arbVault;

    function setUp() public {}

    function run() public {
        // 2 ether is withdrawn from arbitrum to mainnet
        // (happened in a previous step via cast arbVault.sweepToL1())

        mainnetVault = MainnetETHVault(payable(vm.envAddress("MAINNET_VAULT")));
        arbVault = ArbETHVault(payable(vm.envAddress("ARB_VAULT")));

        vm.selectFork(arbFork);
        require(address(arbVault).balance == 0, "ArbETHVault not swept");

        vm.selectFork(mainnetFork);
        require(address(mainnetVault).balance == 2 ether, "Wrong balance on L1");
    }
}
