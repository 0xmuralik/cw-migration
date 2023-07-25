#!/bin/bash
source .env

cd $PATH_TO_CONTRACTS || exit
git switch murali/decommission
cd "$CURRENT_DIR" || exit

echo "$name: Deploying new marketplace legacy contract..."
junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/marketplace_legacy.wasm --from $KEY --gas auto --gas-adjustment 1.15 --chain-id $CHAINID -y -b block

MP_CODE_ID=$(junod query wasm list-code --output json | jq -r '.code_infos[-1].code_id')

echo "$name: Migrating marketplace legacy contract for decommission..."
junod tx wasm migrate "$marketplace_address" "$MP_CODE_ID" '{}' --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block 