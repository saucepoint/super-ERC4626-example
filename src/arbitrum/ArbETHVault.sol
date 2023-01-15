// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "arbos-precompiles/arbos/builtin/ArbSys.sol";
import {ETHVault} from "../ETHVault.sol";
import {WETH} from "solmate/tokens/WETH.sol";

contract ArbETHVault is ETHVault {
    uint256 internal _totalAssetsL1;
    address public l1Target;
    ArbSys constant arbsys = ArbSys(address(0x0000000000000000000000000000000000000064));

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

    function afterDeposit(uint256 assets, uint256) internal override {
        unchecked {
            _totalAssetsL1 += assets;
        }
    }

    // ---------------------------------
    // Entry mechanisms
    // ---------------------------------
    function wrapAndDeposit() public payable {
        WETH(payable(address(asset))).deposit{value: msg.value}();
        deposit(msg.value, msg.sender);
    }

    // ---------------------------------
    // Exit mechanisms
    // ---------------------------------
    /// Bridge back to L1

    function backToL1(uint256 assets, address receiver) public {
        bytes memory data = abi.encodeWithSelector(super.deposit.selector, assets, receiver);
        arbsys.sendTxToL1(l1Target, data);
    }

    // ---------------------------------
    // L2 <---> L1 Messaging
    // ---------------------------------
    /// @notice only L1 contract can set totalAssets
    function setTotalAssets(uint256 _totalAssets) public override {
        // TODO:
        // require(msg.sender == l1Target, "only L1 contract can set totalAssets");
        // AddressAliasHelper.applyL1ToL2Alias(l1Target);
        _totalAssetsL1 = _totalAssets;
    }

    /// sweeps the asset (pure ether) into the L1 contract
    function sweepToL1() public {
        // the benefit of using sending pure ether is that we might not have
        // to pick up the message on L1.
        
        // withdraw to L1
        // receive() will then route the ether into the yield strategy
        arbsys.withdrawEth(l1Target);
    }

    /// @notice Call sweepToL1() to trigger this function on L1
    function sweep() public pure override {
        require(false, "sweep() not implemented on L2");
    }
}
