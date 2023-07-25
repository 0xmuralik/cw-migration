#!/bin/bash
source .env

cd $PATH_TO_CONTRACTS || exit
git switch murali/decommission
cd "$CURRENT_DIR" || exit

echo "$name: Deploying new pg721 metadata onchain contract..."
junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/pg721_metadata_onchain.wasm --from $KEY --gas auto --gas-adjustment 1.15 --chain-id $CHAINID -y -b block

NFT_CODE_ID=$(junod query wasm list-code --output json | jq -r '.code_infos[-1].code_id')

echo "$name: Migrating pg721 metadata onchain contract for decommission..."
junod tx wasm migrate "$nft_address" "$NFT_CODE_ID" '{"minter":""}' --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block 