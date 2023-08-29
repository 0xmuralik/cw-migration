#!/bin/bash
source .env

cd $PATH_TO_CONTRACTS || exit
git switch murali/decommission
cd "$CURRENT_DIR" || exit


echo "$name: Deploying new minter metadata onchain contract..."
junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/minter_metadata_onchain.wasm --from $KEY --gas auto --gas-adjustment 1.15 --chain-id $CHAINID -y -b block

MINT_CODE_ID=$(junod query wasm list-code --reverse --output json | jq -r '.code_infos[0].code_id')

echo "$name: Migrating minter metadata onchain contract for decommission..."
junod tx wasm migrate "$minter_address" "$MINT_CODE_ID" '{}' --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block
