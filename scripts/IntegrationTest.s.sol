// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {ArbETHVault} from "../src/arbitrum/ArbETHVault.sol";
import {MainnetETHVault} from "../src/ethereum/MainnetETHVault.sol";

contract IntegrationTest is Script {
    uint256 mainnetFork = vm.createFork("http://127.0.0.1:8545");
    uint256 arbFork = vm.createFork("http://127.0.0.1:8547");

    address arbAccount = address(0x683642c22feDE752415D4793832Ab75EFdF6223c);
    address ethAccount = address(0x3f1Eae7D46d88F08fc2F8ed27FCb2AB183EB2d0E);

    MainnetETHVault mainnetVault;
    ArbETHVault arbVault;
    WETH wethMainnet;
    WETH wethArb;

    function setUp() public {}

    function run() public {
        // Deploy Arbitrum Contract
        vm.selectFork(arbFork);
        vm.broadcast(arbAccount);
        arbVault = new ArbETHVault(address(0x408Da76E87511429485C32E4Ad647DD14823Fdc4));

        // vm.selectFork(arbFork);
        // vm.broadcast(arbAccount);
        // (bool sentL2,) = address(arbVault).call{value: 1 ether}("");
        // require(sentL2, "Failed to send Ether");
        // vm.stopBroadcast();

        // Deploy Mainnet Contract
        vm.selectFork(mainnetFork);
        vm.startBroadcast(ethAccount);
        mainnetVault = new MainnetETHVault(
            address(0x408Da76E87511429485C32E4Ad647DD14823Fdc4),
            address(arbVault),
            address(0xfF4a24b22F94979E9ba5f3eb35838AA814bAD6F1)
        );
        vm.stopBroadcast();

        // configure arbitrum contract
        // vm.selectFork(arbFork);
        // vm.startBroadcast(arbAccount);
        // arbVault.setL1Target(address(mainnetVault));
        // vm.stopBroadcast();

        // Deposit 1 ETH into L1 vault
        // vm.selectFork(mainnetFork);
        // vm.broadcast(ethAccount);
        // mainnetVault.foo();
        vm.broadcast(ethAccount);
        (bool sent,) = address(mainnetVault).call{value: 2 ether}("");
        require(sent, "Failed to send Ether");

        require(mainnetVault.totalAssets() == 2 ether, "Wrong balance");
        
        // L1 --> L2 message, to update totalAssets()
        // vm.broadcast(ethAccount);
        // mainnetVault.setTotalAssetsInL2{value: 1 ether}(0.25 ether, 8_000_000, 10000000000);
    }
}
