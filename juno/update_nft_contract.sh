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

echo "Deploying new pg721 metadata onchain contract..."
junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/pg721_metadata_onchain.wasm --from $KEY --gas auto --gas-adjustment 1.15 --chain-id $CHAINID -y -b block

NFT_CODE_ID=$(junod query wasm list-code --output json | jq -r '.code_infos[-1].code_id')
sed -i "s/^new_nft_code_id=.*/new_nft_code_id=$NFT_CODE_ID/" .env

junod tx wasm migrate "$new_nft_address" "$NFT_CODE_ID" '{"minter":"'$new_minter_contract'"}' --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block 

echo "Minting token"
junod tx wasm execute "$new_minter_contract" '{"mint":{}}' --amount 100stake --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block

UPDATE='{
    "update_per_address_limit":{
        "per_address_limit": 10
    }
}'

echo "update per person limit"
junod tx wasm execute "$new_minter_contract" "$UPDATE" --amount 100stake --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block