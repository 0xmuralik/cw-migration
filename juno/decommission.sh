#!/bin/bash

# deploy nft contract
./deploy_pg721.sh

# deploy minter contract
./deploy_minter.sh

# decommission nft contract
./update_nft_contract.sh

# decommission minter contract
./update_minter_contract.sh