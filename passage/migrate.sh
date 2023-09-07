#!/bin/bash

source .env

ADDR=$(passage keys show "$KEY" -a)

cd "$PATH_TO_CONTRACTS" || exit
git switch murali/migration
cd "$CURRENT_DIR" || exit

if [ "$pg721_code" -ne -1 ]; then
    echo "PG721 contract already uploaded"
else
    echo "Uploading PG721 contract..."
    RESULT=$(passage tx wasm store "$PATH_TO_CONTRACTS"/artifacts/pg721_metadata_onchain.wasm --from "$KEY" --gas 100000000 --gas-adjustment 1.8 -y -b block)
    CODE=$(echo $RESULT | jq -r '.code')
    if [ $CODE != 0 ]; then
        echo "Something went wrong"
        echo $RESULT
        exit 1
    fi

    TX_HASH=$(echo $RESULT | jq -r '.txhash')
    echo "tx-hash=$TX_HASH"
    sleep 6

    NFT_CODE_ID=$(passage q tx "$TX_HASH" | jq -r '.logs[0]["events"][-1]["attributes"][-1]["value"]')
    sed -i "s/^pg721_code=.*/pg721_code=$NFT_CODE_ID/" .env
fi



# uploading minter contract
if [ "$minter_code" -ne -1 ]; then
    echo "Minter contract already uploaded"
else
    echo "Uploading minter contract..."
    RESULT=$(passage tx wasm store "$PATH_TO_CONTRACTS"/artifacts/minter_metadata_onchain.wasm --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block)


    CODE=$(echo $RESULT | jq -r '.code')
    if [ $CODE != 0 ]; then
        echo "Something went wrong"
        echo $RESULT
        exit 1
    fi

    TX_HASH=$(echo $RESULT | jq -r '.txhash')
    echo "tx-hash=$TX_HASH"

    sleep 6

    CODE_ID=$(passage q tx "$TX_HASH" | jq -r '.logs[0]["events"][-1]["attributes"][-1]["value"]')
    echo $CODE_ID
    sed -i "s/^minter_code=.*/minter_code=$CODE_ID/" .env
fi

# uploading marketplace contract
if [ "$marketplace_code" -ne -1 ]; then
    echo "Marketplace contract already uploaded"
else
    echo "Uploading marketplace contract..."
    RESULT=$(passage tx wasm store "$PATH_TO_CONTRACTS"/artifacts/marketplace_v2.wasm --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block)

    CODE=$(echo $RESULT | jq -r '.code')
    if [ $CODE != 0 ]; then
        echo "Something went wrong"
        echo $RESULT
        exit 1
    fi

    TX_HASH=$(echo $RESULT | jq -r '.txhash')
    echo "tx-hash=$TX_HASH"

    sleep 6

    CODE_ID=$(passage q tx "$TX_HASH" | jq -r '.logs[0]["events"][-1]["attributes"][-1]["value"]')
    echo $CODE_ID
    sed -i "s/^marketplace_code=.*/marketplace_code=$CODE_ID/" .env
fi

# export nft data from juno contracts
# python3 export_nft.py

# migrate nft contract
./deploy_pg721.sh

if [ -z "$mint_address" ] || [ "$mint_address" == "null" ]; then
    sed -i "s/^new_mint_address=.*/new_mint_address=null/" .env
    echo "no mint contract to migrate"
else
    # export minter data from juno contracts
    # python3 export_mint.py

    # migrate minter contract
    ./deploy_minter.sh

    # update minter addr in pg721 (needs migration) and mint a new nft
    ./update_minter.sh
fi

./deploy_marketplace.sh