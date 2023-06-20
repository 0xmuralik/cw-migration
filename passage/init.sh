#!/bin/bash

KEY="mykey"
CHAINID="passage-1"
MONIKER="localtestnet"

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# remove existing daemon and client
rm -rf ~/.passage*

# if $KEY exists it should be deleted
passage keys add $KEY

# Set moniker and chain-id for Ethermint (Moniker can be anything, chain-id must be an integer)
passage init $MONIKER --chain-id $CHAINID

# Allocate genesis accounts (cosmos formatted addresses)
passage add-genesis-account $KEY 100000000000000000000000000stake

# Sign genesis transaction
passage gentx $KEY 1000000000000000000000stake --chain-id $CHAINID

# Collect genesis tx
passage collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
passage validate-genesis

# Start the node
passage start 