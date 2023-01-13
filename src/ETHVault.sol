// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {WETH} from "solmate/tokens/WETH.sol";

contract ETHVault is ERC4626 {
    constructor(address _weth) ERC4626(ERC20(_weth), "ETH Vault", "ETHV") {}
    fallback() external payable {}
    receive() external payable {}

    function totalAssets() public view virtual override returns (uint256) {
        return address(this).balance + asset.balanceOf(address(this));
    }

    function beforeWithdraw(uint256 assets, uint256) internal override {
        if (assets < asset.balanceOf(address(this)) && 0 < address(this).balance) {
            WETH(payable(address(asset))).deposit{value: address(this).balance}();
        }
    }

    /// @notice (L2 --> L1) Ether swept from L2 is recieved (and used in yield bearing strategies)
    function sweep() public virtual {}

    /// @notice (L1 --> L2) Set the underlying asset (ETH) holdings for ERC4626 conversion/exchange rates
    function setTotalAssets(uint256 _totalAssets) public virtual {}
}
