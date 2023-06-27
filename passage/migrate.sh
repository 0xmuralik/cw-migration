#!/bin/bash

source .env

# export nft data from juno contracts
python3 export_nft.py

# migrate nft contract
./deploy_pg721.sh

if [ -z "$mint_address" ] || [ "$mint_address" == "null" ]; then 
    sed -i "s/^new_mint_address=.*/new_mint_address=null/" .env
    echo "no mint contract to migrate"
else
    # export minter data from juno contracts
    python3 export_mint.py

    # migrate minter contract
    ./deploy_minter.sh

    # update minter addr in pg721 (needs migration) and mint a new nft
    ./update_minter.sh
fi

./deploy_marketplace.sh