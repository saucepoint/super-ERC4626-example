# Super ERC-4626 • [![CI](https://github.com/transmissions11/foundry-template/actions/workflows/tests.yml/badge.svg)](https://github.com/transmissions11/foundry-template/actions/workflows/tests.yml)

Supercharging ERC-4626 tokens on Arbitrum:

1) Underlying assets & value accrual live on L1 (mainnet)
    1) L1 can offer diverse and robust yield opportunities

2) Tokens are *canonically L2* (Arbitrum) for **affordable** utilization:
    1) **Deposit into the vaults from L2**
    2) Transfer, trade, and exchange the tokens on L2
    3) Use vaults as collateral in lending systems (???)

---

This repo is intended to be an educational application of Arbitrum's cross-chain messaging (L1 <--> L2); you should reference their [tutorial](https://github.com/OffchainLabs/arbitrum-tutorials/tree/master/packages/greeter) for additional examples.

Main difference is:

1) **This repo uses foundry scripts + cast instead of javascript**

2) This repo a clearer distinction between L1 --> L2 and L2 --> L1 messaging. 4626 Vaults offer of a real world example, which is less hello-worldy than the original tutorial.

---

## Note on Cross-chain Testing in Foundry
Because cross-chain messaging is handled at the node level (nitro nodes know to communicate to a corresponding L1 node), the core messaging logic *cannot* be tested with `forge test`. Instead, we'll run Arbitrum's local dev node(s) (nitro + geth) and execute `forge scripts` against the two nodes.

Moreover, messaging occurs over the course of a few blocks, so testing the functionality will occur over multiple scripts. **See `scripts/` for testing cross-chain message testing**

Custom opcodes by Arbitrum (i.e. `arbsys.withdrawEth()`) are not supported within `forge scripts`. Contract functions which send messages from L2 to L1 are handled with `cast`

---

## Contributing

You will need a copy of [Foundry](https://github.com/foundry-rs/foundry) installed before proceeding. See the [installation guide](https://github.com/foundry-rs/foundry#installation) for details.

### Setup

```sh
git clone https://github.com/transmissions11/foundry-template.git
cd foundry-template
forge install
```

### Run Tests

```sh
forge test
```

### Update Gas Snapshots

```sh
forge snapshot
```
