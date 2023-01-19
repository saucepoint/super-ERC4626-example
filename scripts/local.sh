export mainnetRPC="http://127.0.0.1:8545"

# Arbitrum local nitro dev node
export arbitrumRPC="http://127.0.0.1:8547"

# Private key from Arbitrum local dev node, with a mainnet balance
export mainnetPK="0xb6b15c8cb491557369f3c7d2c287b053eb229daa9c22138887752191c9520659"

# Private key from Arbitrum local dev node, the 2nd account in the mnemonic
export rollupPK="0xcb5790da63720727af975f42c79f69918580209889225fa7128c92402a6d3a65"

# private key from Arbitrum local dev node, with an arbitrum balance
export arbPK="0xe887f7d17d07cc7b8004053fb8826f6657084e88904bb61590e498ca04704cf2"

# Set the challenge period to be 1 block for testing L2 --> L1 messages
# (normally its a week!)
cast send 0x65a59d67da8e710ef9a01eca37f83f84aedec416 "setConfirmPeriodBlocks(uint64)" 1 \
    --rpc-url $mainnetRPC \
    --private-key $rollupPK

# Deploy the contracts to both L1 and L2
forge script scripts/1.Deploy.s.sol \
    --broadcast \
    --skip-simulation \
    --private-keys $mainnetPK \
    --private-keys $arbPK

# Extract contract addresses from the broadcast artifacts
ARB_VAULT=$(jq '.deployments[0].receipts[0].contractAddress' broadcast/multi/1.Deploy.s.sol-latest/run.json)
ARB_VAULT=$(echo $ARB_VAULT | sed -e 's/^"//' -e 's/"$//')
echo "Arbitrum Vault: $ARB_VAULT"
export ARB_VAULT

MAINNET_VAULT=$(jq '.deployments[1].receipts[0].contractAddress' broadcast/multi/1.Deploy.s.sol-latest/run.json)
MAINNET_VAULT=$(echo $MAINNET_VAULT | sed -e 's/^"//' -e 's/"$//')
echo "Mainnet Vault: $MAINNET_VAULT"
export MAINNET_VAULT

# Configure the L2 vault to only accept message from an L1 contract
cast send $ARB_VAULT "setL1Target(address)" $MAINNET_VAULT \
    --rpc-url $arbitrumRPC \
    --private-key $arbPK

# Simulates L1 --> L2 message (setTotalAssets)
forge script scripts/2.SimL1ToL2.s.sol \
    --broadcast \
    --skip-simulation \
    --private-keys $mainnetPK \
    --private-keys $arbPK

echo "Sleeping 30 seconds to allow for L2 to receive the message"
sleep 30

# Verify the L1 --> L2 message has modified the L2 vault
forge script scripts/3.AssertState.s.sol \
    --broadcast \
    --skip-simulation \
    --private-keys $mainnetPK \
    --private-keys $arbPK

# Simulating L2 --> L1 message (sweepToL1)
# Need to use cast since arbsys.withdrawEth uses a custom opcode
# which foundry EVM does not recognize
cast send $ARB_VAULT "sweepToL1()" \
    --rpc-url $arbitrumRPC \
    --private-key $arbPK

echo "Sleeping 30 seconds to allow for L1 to receive the message"
sleep 30

# Verify the L2 --> L1 withdrawal occurred
forge script scripts/4.AssertL2ToL1.s.sol \
    --skip-simulation \
    --private-keys $mainnetPK \
    --private-keys $arbPK
