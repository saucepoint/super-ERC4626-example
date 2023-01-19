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

    function setUp() public {}

    function run() public {
        mainnetVault = MainnetETHVault(payable(vm.envAddress("MAINNET_VAULT")));

        // TODO: verify the recieve() function is not being trigged by using custom gift()
        // Deposit 1 ETH into L1 vault
        vm.selectFork(mainnetFork);
        vm.broadcast(ethAccount);
        mainnetVault.gift{value: 2 ether}();

        require(mainnetVault.totalAssets() == 2 ether, "Wrong balance");
        
        // L1 --> L2 message, to update totalAssets()
        vm.broadcast(ethAccount);
        mainnetVault.setTotalAssetsInL2{value: 1 ether}(0.25 ether, 8_000_000, 10000000000);
    }
}
