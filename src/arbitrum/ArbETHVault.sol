// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "arbos-precompiles/arbos/builtin/ArbSys.sol";
import {ETHVault} from "../ETHVault.sol";

//import "@arbitrum/nitro-contracts/src/libraries/AddressAliasHelper.sol";

contract ArbETHVault is ETHVault {
    uint256 internal _totalAssetsL1;
    address public l1Target;
    ArbSys constant arbsys = ArbSys(address(100));

    constructor(address _weth, address _l1Target) ETHVault(_weth) {
        l1Target = _l1Target;
    }

    function totalAssets() public view override returns (uint256) {
        return _totalAssetsL1;
    }

    /// @notice only L1 contract can set totalAssets
    function setTotalAssets(uint256 _totalAssets) public override {
        require(msg.sender == l1Target, "only L1 contract can set totalAssets");
        // AddressAliasHelper.applyL1ToL2Alias(l1Target);
        _totalAssetsL1 = _totalAssets;
    }

    /// sweeps the ether into the L1 contract
    function sweepToL1() public {
        bytes memory data = abi.encodeWithSelector(ETHVault.sweep.selector);

        arbsys.sendTxToL1(l1Target, data);
    }

    function sweep() public pure override {
        require(false, "sweep() not implemented on L2");
    }
}
