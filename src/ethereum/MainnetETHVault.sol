// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IOutbox} from "../interfaces/IOutbox.sol";
import {IInbox, IBridge} from "../interfaces/IInbox.sol";
import {ETHVault} from "../ETHVault.sol";

contract MainnetETHVault is ETHVault {
    uint256 public sweepCounter;

    address public immutable l2Target;
    IInbox public immutable inbox;

    event RetryableTicketCreated(uint256 indexed ticketId);

    constructor(address _weth, address _l2Target, address _inbox) ETHVault(_weth) {
        l2Target = _l2Target;
        inbox = IInbox(_inbox);
    }

    receive() external payable override {
        // TODO: use reasonable values. is there an oracle we can read from?
        // values are used to pay for L2 gas/execution
        uint256 maxSubmissionCost = 0.25 ether;
        uint256 maxGas = 1_000_000;
        uint256 gasPriceBid = 10 gwei;

        // caller must send enough ETH to pay for the L2 tx
        // we'll need to subtract msg.value from totalAssets
        uint256 _totalAssets = totalAssets() - msg.value;
        bytes memory data = abi.encodeWithSelector(ETHVault.setTotalAssets.selector, _totalAssets);

        uint256 ticketID = inbox.createRetryableTicket{value: msg.value}(
            l2Target, 0, maxSubmissionCost, msg.sender, msg.sender, maxGas, gasPriceBid, data
        );
        emit RetryableTicketCreated(ticketID);
    }

    /// @notice Anyone can call this to update the exchange rate on L2
    /// @dev should be called after fresh ether gets swept to a strategy
    function setTotalAssetsInL2(uint256 maxSubmissionCost, uint256 maxGas, uint256 gasPriceBid) public payable {
        // caller must send enough ETH to pay for the L2 tx
        // we'll need to subtract msg.value from totalAssets
        uint256 _totalAssets = totalAssets() - msg.value;
        bytes memory data = abi.encodeWithSelector(ETHVault.setTotalAssets.selector, _totalAssets);

        uint256 ticketID = inbox.createRetryableTicket{value: msg.value}(
            l2Target, 0, maxSubmissionCost, msg.sender, msg.sender, maxGas, gasPriceBid, data
        );
        emit RetryableTicketCreated(ticketID);
    }

    /// @notice Educational example purpose. Used to increase our underlying ETH balance to simulate yield
    /// @dev Used to avoid triggering receive() hook
    function gift() external payable {}

    /// @notice Is callable once a message from L2 is confirmed. Used to sweep the ERC20 into a strategy
    /// @dev not used in this example. invoked using arbitrum sdk
    function sweep() public override {
        IBridge bridge = inbox.bridge();
        // this prevents reentrancies on L2 to L1 txs
        require(msg.sender == address(bridge), "NOT_BRIDGE");
        IOutbox outbox = IOutbox(bridge.activeOutbox());
        address l2Sender = outbox.l2ToL1Sender();
        require(l2Sender == l2Target, "Sweeps only handled by L2");

        // TODO: actually sweep the ether into a yield strategy
        sweepCounter++;
    }

    function beforeWithdraw(uint256, uint256) internal pure override {
        // I do not want to provide a bad example, so do not allow L1 withdrawals
        // L1 withdrawals will require keeping L2 & L1 token supplies in sync
        require(false, "withdrawal not implemented on L1");
    }

    /// @notice Call setTotalAssetsInL2() to trigger this function on L2
    function setTotalAssets(uint256) public pure override {
        require(false, "setTotalAssets() not implemented on L1");
    }
}
