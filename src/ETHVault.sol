// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

contract ETHVault is ERC4626 {
    using FixedPointMathLib for uint256;

    WETH weth;

    constructor(address _weth) ERC4626(ERC20(_weth), "ETH Vault", "ETHV") {
        weth = WETH(payable(_weth));
    }

    receive() external payable virtual {}

    function totalAssets() public view virtual override returns (uint256) {
        return address(this).balance + asset.balanceOf(address(this));
    }

    function beforeWithdraw(uint256, uint256) internal virtual override {
        if (0 < address(this).balance) weth.deposit{value: address(this).balance}();
    }

    /// @notice Implemented on L1, invoked via a message from L2. Ether swept from L2 is recieved (and used in yield bearing strategies)
    function sweep() public virtual {}

    /// @notice Implemented on L2, invoked via a message from L1. Set the underlying asset (ETH) holdings for ERC4626 conversion/exchange rates
    function setTotalAssets(uint256 _totalAssets) public virtual {}
}
