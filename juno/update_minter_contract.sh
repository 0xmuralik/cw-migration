#!/bin/bash
CHAINID="junod-1"
KEY="mykey"
PATH_TO_CONTRACTS="/home/vitwit/passage/passage-contracts"
CURRENT_DIR=$(pwd)

source .env

cd $PATH_TO_CONTRACTS || exit
git stash
git switch murali/decommission
cd "$CURRENT_DIR" || exit


echo "Deploying new minter metadata onchain contract..."
junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/minter_metadata_onchain.wasm --from $KEY --gas auto --gas-adjustment 1.15 --chain-id $CHAINID -y -b block

MINT_CODE_ID=$(junod query wasm list-code --output json | jq -r '.code_infos[-1].code_id')

junod tx wasm migrate "$new_minter_contract" "$MINT_CODE_ID" '{}' --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block 

UPDATE='{
    "update_per_address_limit":{
        "per_address_limit": 10
    }
}'

echo "update per person limit"
junod tx wasm execute "$new_minter_contract" "$UPDATE" --amount 100stake --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block