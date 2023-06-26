#!/bin/bash
source .env

cd "$PATH_TO_CONTRACTS" || exit
git switch murali/new_nft_version
cd "$CURRENT_DIR" || exit

echo "Deploying pg721 metadata onchain contract..."
passage tx wasm store "$PATH_TO_CONTRACTS"/artifacts/pg721_metadata_onchain.wasm --from "$KEY" --gas auto --gas-adjustment 1.15 --chain-id "$CHAINID" -y -b block

NFT_CODE_ID=$(passage query wasm list-code --output json | jq -r '.code_infos[-1].code_id')
sed -i "s/^new_nft_code_id=.*/new_nft_code_id=$NFT_CODE_ID/" .env

migrate_msg='{"minter":"'"$new_mint_address"'"}' 
echo "Change minter to minting contract...."
passage tx wasm migrate "$new_nft_address" "$NFT_CODE_ID" "$migrate_msg" --from "$KEY" --chain-id "$CHAINID" --gas auto --gas-adjustment 1.15 -y -b block