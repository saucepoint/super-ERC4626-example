# Super ERC-4626 • [![CI](https://github.com/transmissions11/foundry-template/actions/workflows/tests.yml/badge.svg)](https://github.com/transmissions11/foundry-template/actions/workflows/tests.yml)

An L2-native yield-bearing vault, with its underlying assets & value accrual on L1

## Supercharging ERC-4626 tokens on Arbitrum

1) Underlying assets & value accrual live on L1 (mainnet)
    1) L1 can offer diverse and robust yield opportunities

2) Tokens are *canonically L2* (Arbitrum) for **affordable** utilization:
    1) **Deposit into the vaults from L2**
    2) Transfer, trade, and exchange the tokens on L2
    3) Use vaults as collateral in lending systems (???)

---

This repo is intended to be an educational adaptation of Arbitrum's cross-chain messaging (L1 <--> L2), based on their [tutorial](https://github.com/OffchainLabs/arbitrum-tutorials/tree/master/packages/greeter):

1) Uses foundry scripts instead of javascript

2) Provides a clearer distinction between L1 --> L2 and L2 --> L1 messaging. 4626 Vaults offer of a real world example, which is less hello-worldy than the original tutorial.

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
