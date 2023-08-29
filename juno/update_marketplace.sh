#!/bin/bash
source .env

junod config

cd $PATH_TO_CONTRACTS || exit
git switch murali/decommission

sleep 6

echo "$name: Deploying new marketplace legacy contract..."
RESULT=$(junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/marketplace_legacy.wasm --from $KEY --gas auto --gas-adjustment 1.5 -y)

TX_HASH=$(echo $RESULT | jq -r '.txhash')
CODE=$(echo $RESULT | jq -r '.code')

if [ $CODE != 0 ]; then
    echo "Something went wrong"
    echo $RESULT
    exit 1
fi

echo "tx-hash=$TX_HASH"
echo "waiting for transaction to be included in the block"


sleep 10

MP_CODE_ID=$(junod q tx "$TX_HASH" | jq -r '.logs[0]["events"][-1]["attributes"][-1]["value"]')

echo $MP_CODE_ID

echo "$name: Migrating marketplace legacy contract for decommission..."
junod tx wasm migrate "$marketplace_address" "$MP_CODE_ID" '{}' --from $KEY --gas auto --gas-adjustment 1.5 -y

sleep 10