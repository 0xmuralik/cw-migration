#!/bin/bash

# # export nft data from juno contracts
python3 export_nft.py

# # migrate nft contract
./deploy_pg721.sh

# # export minter data from juno contracts
python3 export_mint.py


# migrate minter contract
./deploy_minter.sh "$NFT_CODE_ID" "$NFT_CONTRACT"