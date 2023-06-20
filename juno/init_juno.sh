#!/bin/bash

KEY="mykey"
CHAINID="junod-1"
MONIKER="localtestnet"

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# remove existing daemon and client
rm -rf ~/.junod*

# if $KEY exists it should be deleted
junod keys add $KEY

# Set moniker and chain-id for Ethermint (Moniker can be anything, chain-id must be an integer)
junod init $MONIKER --chain-id $CHAINID

# Allocate genesis accounts (cosmos formatted addresses)
junod add-genesis-account $KEY 100000000000000000000000000stake

# Sign genesis transaction
junod gentx $KEY 1000000000000000000000stake --chain-id $CHAINID

# Collect genesis tx
junod collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
junod validate-genesis

# Start the node
junod start 