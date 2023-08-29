#!/bin/bash
source .env

junod config

cd $PATH_TO_CONTRACTS || exit
git switch murali/decommission
cd "$CURRENT_DIR" || exit


sleep 6

echo "$name: Deploying new minter metadata onchain contract..."
RESULT=$(junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/minter_metadata_onchain.wasm --from $KEY --gas auto --gas-adjustment 1.5 -y)

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

MINT_CODE_ID=$(junod q tx "$TX_HASH" | jq -r '.logs[0]["events"][-1]["attributes"][-1]["value"]')

echo $MINT_CODE_ID

echo "$name: Migrating minter metadata onchain contract for decommission..."
junod tx wasm migrate "$minter_address" "$MINT_CODE_ID" '{}' --from $KEY --gas auto --gas-adjustment 1.5 -y

sleep 10