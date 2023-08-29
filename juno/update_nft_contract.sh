#!/bin/bash
source .env

junod config

cd $PATH_TO_CONTRACTS || exit
git switch murali/decommission
echo $PATH_TO_CONTRACTS


# echo "$name: Deploying new pg721 metadata onchain contract..."
RESULT=$(junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/pg721_metadata_onchain.wasm --from $KEY --gas auto --gas-adjustment 1.75 -y)

CODE=$(echo $RESULT | jq -r '.code')
if [ $CODE != 0 ]; then
    echo "Something went wrong"
    echo $RESULT
    exit 1
fi

TX_HASH=$(echo $RESULT | jq -r '.txhash')
echo "tx-hash=$TX_HASH"
echo "waiting for transaction to be included in the block"

sleep 10

NFT_CODE_ID=$(junod q tx "$TX_HASH" | jq -r '.logs[0]["events"][-1]["attributes"][-1]["value"]')

echo $NFT_CODE_ID

# echo "$name: Migrating pg721 metadata onchain contract for decommission..."
junod tx wasm migrate "$nft_address" "$NFT_CODE_ID" '{"minter":""}' --from $KEY --gas auto --gas-adjustment 1.75 -y

sleep 6