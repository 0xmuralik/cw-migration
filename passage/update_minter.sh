#!/bin/bash
source .env

cd "$PATH_TO_CONTRACTS" || exit
git switch murali/new_nft_version
cd "$CURRENT_DIR" || exit

echo "Deploying $name pg721 metadata onchain contract..."
RESULT=$(passage tx wasm store "$PATH_TO_CONTRACTS"/artifacts/pg721_metadata_onchain.wasm --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block)

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

echo $NFT_CODE_ID

sed -i "s/^new_nft_code_id=.*/new_nft_code_id=$NFT_CODE_ID/" .env

migrate_msg='{"minter":"'"$new_mint_address"'"}' 

echo "Change $name minter to minting contract...."
passage tx wasm migrate "$new_nft_address" "$NFT_CODE_ID" "$migrate_msg" --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block