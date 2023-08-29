#!/bin/bash
source .env

junod config

ADDR=$(junod keys show "$KEY" -a)

cd "$PATH_TO_CONTRACTS" || exit
git switch main

# Update the value in the .env file
sed -i "s/^minter_addr=.*/minter_addr=$ADDR/" .env

echo "Deploying pg721 metadata onchain contract..."
TX_HASH=$(junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/pg721_metadata_onchain.wasm --from "$KEY" --gas auto --gas-adjustment 1.5 -y | jq -r '.txhash')

echo "tx-hash=$TX_HASH"
echo "waiting for transaction to be included in the block"

sleep 10

NFT_CODE_ID=$(junod q tx "$TX_HASH" | jq -r '.logs[0]["events"][-1]["attributes"][-1]["value"]')

echo $NFT_CODE_ID

sed -i "s/^new_nft_code_id=.*/new_nft_code_id=$NFT_CODE_ID/" .env

# Load INIT payload
NFT_INIT='{
  "name": "MetaHuahua",
  "symbol": "MH",
  "minter": "'$ADDR'",
  "collection_info": {
    "creator": "juno1gtueg07w5f5h3hydvwzc2z5nz989e4p053dxre",
    "description": "THE WOOFIEST PASSPORT TO THE METAVERSE",
    "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/2990.png",
    "external_link": "https://www.aaa-metahuahua.com/",
    "royalty_info": {
      "payment_address": "juno1gtueg07w5f5h3hydvwzc2z5nz989e4p053dxre",
      "share": "0.1"
    }
  }
}'

# instantiate contract
echo "Instantiating contract..."
junod tx wasm instantiate "$NFT_CODE_ID" "$NFT_INIT" --from "$KEY" --label "nft metadata onchain" --admin "$KEY" --gas auto --gas-adjustment 1.5 -y

sleep 10

NFT_CONTRACT=$(junod query wasm list-contract-by-code $NFT_CODE_ID --output json | jq -r '.contracts[-1]')

sed -i "s/^new_nft_address=.*/new_nft_address=$NFT_CONTRACT/" .env

echo $NFT_CONTRACT

echo "NFT contract deployed. NFT contract address: $NFT_CONTRACT"
