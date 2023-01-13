// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IOutbox} from "../interfaces/IOutbox.sol";
import {IInbox, IBridge} from "../interfaces/IInbox.sol";
import {ETHVault} from "../ETHVault.sol";

contract MainnetETHVault is ETHVault {
    uint256 public sweepCounter;
    address public l2Target;
    IInbox public immutable inbox;

    event RetryableTicketCreated(uint256 indexed ticketId);

    constructor(address _weth, address _l2Target, address _inbox) ETHVault(_weth) {
        l2Target = _l2Target;
        inbox = IInbox(_inbox);
    }

    function setTotalAssetsInL2(uint256 maxSubmissionCost, uint256 maxGas, uint256 gasPriceBid) public {
        uint256 _totalAssets = totalAssets();
        bytes memory data = abi.encodeWithSelector(ETHVault.setTotalAssets.selector, _totalAssets);

        uint256 ticketID = inbox.createRetryableTicket{value: 0}(
            l2Target, 0, maxSubmissionCost, msg.sender, msg.sender, maxGas, gasPriceBid, data
        );
        emit RetryableTicketCreated(ticketID);
    }

    /// @notice only l2Target can call this
    function sweep() public override {
        IBridge bridge = inbox.bridge();
        // this prevents reentrancies on L2 to L1 txs
        require(msg.sender == address(bridge), "NOT_BRIDGE");
        IOutbox outbox = IOutbox(bridge.activeOutbox());
        address l2Sender = outbox.l2ToL1Sender();
        require(l2Sender == l2Target, "Greeting only updateable by L2");

        // sweep the ether
        sweepCounter++;
    }

    /// @notice Call setTotalAssetsInL2() to trigger this function on L2
    function setTotalAssets(uint256) public pure override {
        require(false, "setTotalAssets() not implemented on L1");
    }
}
