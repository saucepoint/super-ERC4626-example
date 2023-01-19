// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "arbos-precompiles/arbos/builtin/ArbSys.sol";
import "@arbitrum/nitro-contracts/src/libraries/AddressAliasHelper.sol";
import {ETHVault} from "../ETHVault.sol";

contract ArbETHVault is ETHVault {
    uint256 internal _totalAssetsL1;
    address public l1Target;
    ArbSys internal arbsys = ArbSys(address(0x0000000000000000000000000000000000000064));

    constructor(address _weth) ETHVault(_weth) {}

    function setL1Target(address _l1Target) public {
        l1Target = _l1Target;
    }

    // ---------------------------------
    // ERC4626 overrides
    // ---------------------------------
    function totalAssets() public view override returns (uint256) {
        return _totalAssetsL1;
    }

    /// @dev Update the exchange rate when new underlying is provided -- even if the underlying asset is not deployed into an L1 yield strategy
    function afterDeposit(uint256 assets, uint256) internal override {
        unchecked {
            _totalAssetsL1 += assets;
        }
    }

    // ---------------------------------
    // Entry mechanisms
    //   1. deposit() w/ a WETH approval
    //   2. wrapAndDeposit() w/ a pure ETH transfer
    // ---------------------------------
    function wrapAndDeposit() external payable returns (uint256 shares) {
        uint256 amount = msg.value;
        weth.deposit{value: msg.value}();

        // logic taken from deposit(), but without the ERC20 transfer

        // Check for rounding error since we round down in previewDeposit.
        require((shares = previewDeposit(amount)) != 0, "ZERO_SHARES");

        _mint(msg.sender, shares);

        emit Deposit(msg.sender, msg.sender, amount, shares);

        afterDeposit(amount, shares);
    }

    // ---------------------------------
    // Exit mechanisms
    // ---------------------------------
    // I was initially going to implement an exit/redemption mechanism using cross-chain messaging
    // However, testing it will require using arbitrum's SDK (javascript). This feels out of scope for this project
    // I am not confident in my testing and do not want to set a bad example for others.
    //
    // There are probably two ways to handle withdrawals on L2
    // 1. Use an L2 --> L1 message (which triggers a deposit/bridge back into L2), example below
    //    - this will create exit liquidity where traditional ERC-4626 redemption behavior will work
    //    - the problem with this solution is the confirmation time. You also cannot pre-emptively transfer liquidity to L2
    //      without some sort of trusted actor
    // 2. Use the canonical token bridge (or a custom one), which mints 4626 tokens on L1
    //    - traditional ERC-4626 redemption behavior will work on L1
    //    - the problem with this solution is also confirmation time. You also need to ensure that token supply on L1 and L2 are in sync
    //
    //
    /// @notice Request liquidity from L1, to act as exit liquidity
    // ```
    // function requestExitLiquidity(uint256 assets, address receiver) public {
    //     bytes memory data = abi.encodeWithSelector(super.unwind.selector, assets, receiver);
    //     arbsys.sendTxToL1(l1Target, data);
    // }
    // ```

    // ---------------------------------
    // L2 <---> L1 Messaging
    // ---------------------------------
    /// @notice only L1 contract can set totalAssets
    function setTotalAssets(uint256 _totalAssets) public override {
        require(msg.sender == AddressAliasHelper.applyL1ToL2Alias(l1Target), "only L1 contract can set totalAssets");
        _totalAssetsL1 = _totalAssets;
    }

    /// sweeps the asset (pure ether) into the L1 contract
    function sweepToL1() public {
        // the benefit of using sending pure ether is that we might not have
        // to pick up the message on L1.

        // unwrap any weth
        if (weth.balanceOf(address(this)) > 0) {
            weth.withdraw(weth.balanceOf(address(this)));
        }

        // withdraw to L1
        // receive() will then route the ether into the yield strategy
        arbsys.withdrawEth{value: address(this).balance}(l1Target);

        // if you are not handling ETH, you should bridge the ERC-20 back to L1
        // and invoke the sweep() function on L1
    }

    /// @notice Call sweepToL1() to trigger this function on L1
    function sweep() public pure override {
        require(false, "sweep() not implemented on L2");
    }
}
