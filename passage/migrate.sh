#!/bin/bash

# # export nft data from juno contracts
python3 export_nft.py

# # migrate nft contract
./deploy_pg721.sh

# # export minter data from juno contracts
python3 export_mint.py


# migrate minter contract
./deploy_minter.sh

# update minter in pg721 (needs migration) and mint a new nft
./update_minter.sh