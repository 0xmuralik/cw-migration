#!/bin/bash
source .env

ADDR=$(junod keys show "$KEY" -a)

cd "$PATH_TO_CONTRACTS" || exit
git switch main
cd "$CURRENT_DIR" || exit

# Update the value in the .env file
sed -i "s/^minter_addr=.*/minter_addr=$ADDR/" .env

echo "Deploying pg721 metadata onchain contract..."
junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/pg721_metadata_onchain.wasm --from "$KEY" --gas auto --gas-adjustment 1.15 --chain-id "$CHAINID" -y -b block



NFT_CODE_ID=$(junod query wasm list-code --output json | jq -r '.code_infos[-1].code_id')
sed -i "s/^new_nft_code_id=.*/new_nft_code_id=$NFT_CODE_ID/" .env

# Load INIT payload
NFT_INIT='{
  "name": "MetaHuahua",
  "symbol": "MH",
  "minter": "'$ADDR'",
  "collection_info": {
    "creator": "juno166a65em64adkm8mt8j2we0t30s29rzsqtvpqds",
    "description": "THE WOOFIEST PASSPORT TO THE METAVERSE",
    "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/2990.png",
    "external_link": "https://www.aaa-metahuahua.com/",
    "royalty_info": {
      "payment_address": "juno166a65em64adkm8mt8j2we0t30s29rzsqtvpqds",
      "share": "0.1"
    }
  }
}'

# instantiate contract
echo "Instantiating contract..."
junod tx wasm instantiate "$NFT_CODE_ID" "$NFT_INIT" --from "$KEY" --chain-id "$CHAINID" --label "nft metadata onchain" --admin "$KEY" --gas auto --gas-adjustment 1.15 -y -b block

NFT_CONTRACT=$(junod query wasm list-contract-by-code "$NFT_CODE_ID" --output json | jq -r '.contracts[-1]')
sed -i "s/^new_nft_address=.*/new_nft_address=$NFT_CONTRACT/" .env

echo "NFT contract deployed. NFT contract address: $NFT_CONTRACT"
