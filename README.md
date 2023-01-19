# Super ERC-4626 • [![CI](https://github.com/saucepoint/super-ERC4626-example/actions/workflows/tests.yml/badge.svg)](https://github.com/saucepoint/super-ERC4626-example/actions/workflows/tests.yml)

Supercharging ERC-4626 tokens on Arbitrum:

1) Underlying assets & value accrual live on L1 (mainnet)
    1) L1 can offer diverse and robust yield opportunities

2) Tokens are *canonically L2* (Arbitrum) for **affordable** utilization:
    1) **Deposit into the vaults from L2**
    1) Transfer, trade, and exchange the tokens on L2
    1) Exchange rate is correctly observable on L2
    1) Use vaults as collateral in lending systems (???)

---

This repo is intended to be an educational application of Arbitrum's cross-chain messaging (L1 <--> L2); you should reference their [tutorial](https://github.com/OffchainLabs/arbitrum-tutorials/tree/master/packages/greeter) as an additional example

Main difference is:

1) **This repo uses on `foundry` (forge + cast) instead of javascript**

2) This repo offers clearer distinction between L1-to-L2 and L2-to-L1 messaging. 4626 Vaults also offer of a real world use-case of cross-chain messaging.

> Note: this example does not contain mechanisms to guarantee ERC-4626 redemption liquidity. Proceed with caution when using in production

---

## Note on Cross-chain Testing in Foundry
Cross-chain messaging is handled at the node level (nitro nodes know to communicate to a corresponding L1 node), the core messaging logic *cannot* be tested with `forge test`

Instead, run Arbitrum local dev node(s) (nitro + geth) to execute `forge scripts` against the two nodes
```
Run L1 + L2 local nodes with Docker: https://developer.arbitrum.io/node-running/local-dev-node
```

1. Messaging occurs over the course of a few blocks, so testing the functionality will occur over multiple scripts. **See `scripts/` and `/scripts/local.sh`**

2. L2-to-L1 messages takes 7 days (on mainnet / production)
    - Modify the confirmation time of our local nodes to be 1 block instead
        `scripts/local.sh`
        ```bash
        # Set the challenge period to be 1 block for testing L2 --> L1 messages
        # (normally its a week!)
        cast send 0x65a59d67da8e710ef9a01eca37f83f84aedec416 "setConfirmPeriodBlocks(uint64)" 1 \
            --rpc-url $mainnetRPC \
            --private-key $rollupPK
        ```

2. Custom opcodes by Arbitrum (i.e. `arbsys.withdrawEth()`) are not supported within `forge scripts`. Contract functions which send messages from L2 to L1 are handled with `cast`
    
    `scripts/local.sh`
    ```bash
    # Simulating L2 --> L1 message (sweepToL1)
    # Need to use cast since arbsys.withdrawEth uses a custom opcode
    # which foundry EVM does not recognize
    cast send $ARB_VAULT "sweepToL1()" \
        --rpc-url $arbitrumRPC \
        --private-key $arbPK
    ```

## Testing

Run Cross-chain messaging tests & integration
```bash
# start the L1 geth and L2 nitro dev nodes
# (in the offchainlabs/nitro repository)
./test-node.bash

# Execute forge scripts & cast calls, from the repository root
# Non-blocking script, so you should monitor the output for errors
./scripts/local.sh
```

Run solidity/vault tests
```
forge test
```

---

## Contributing & Setup

You will need a copy of [Foundry](https://github.com/foundry-rs/foundry) installed before proceeding. See the [installation guide](https://github.com/foundry-rs/foundry#installation) for details.

```sh
git clone https://github.com/saucepoint/super-ERC4626-example
cd super-ERC4626-example

forge install

# Recommended to use node v16 to install arbitrum dependencies
npm install

# install jq on Linux
sudo apt install jq

# install jq on Mac
brew install jq
```
