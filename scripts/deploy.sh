export mainnetRPC="http://127.0.0.1:8545"

# Arbitrum local nitro dev node
export arbitrumRPC="http://127.0.0.1:8547"

# Private key from Arbitrum local dev node, with a mainnet balance
export mainnetPK="0xb6b15c8cb491557369f3c7d2c287b053eb229daa9c22138887752191c9520659"

# private key from Arbitrum local dev node, with an arbitrum balance
export arbPK="0xe887f7d17d07cc7b8004053fb8826f6657084e88904bb61590e498ca04704cf2"

# L1 Arbitrum Inbox Address
export inbox="0xfF4a24b22F94979E9ba5f3eb35838AA814bAD6F1"

# WETH address on both chains
export mainnetWETH="0x408Da76E87511429485C32E4Ad647DD14823Fdc4"
export arbWETH="0x408Da76E87511429485C32E4Ad647DD14823Fdc4"

# forge create src/arbitrum/ArbETHVault.sol:ArbETHVault \
#     --rpc-url $arbitrumRPC \
#     --private-key $arbPK \
#     --constructor-args $arbWETH

# forge create src/ethereum/MainnetETHVault.sol:MainnetETHVault \
#     --rpc-url $mainnetRPC \
#     --private-key $mainnetPK \
#     --constructor-args $mainnetWETH "0x78a6dC8D17027992230c112432E42EC3d6838d74" $inbox

# cast send 0x78a6dC8D17027992230c112432E42EC3d6838d74 \
#     "setL1Target(address)()" "0x84401CD7AbBeBB22ACb7aF2beCfd9bE56C30bcf1" \
#     --rpc-url $arbitrumRPC \
#     --private-key $arbPK

# cast send 0x84401CD7AbBeBB22ACb7aF2beCfd9bE56C30bcf1 \
#     --private-key $mainnetPK \
#     --value 1ether \
#     --rpc-url $mainnetRPC

# cast call 0xe7362d0787b51d8c72d504803e5b1d6dcda89540 "bridge()" --rpc-url $arbitrumRPC

# cast send 0x84401CD7AbBeBB22ACb7aF2beCfd9bE56C30bcf1 \
#     "setTotalAssetsInL2(uint256,uint256,uint256)()" \
#     1000000000000000000 \
#     3000000 \
#     500000000000 \
#     --value 1ether \
#     --private-key $mainnetPK \
#     --rpc-url $mainnetRPC
