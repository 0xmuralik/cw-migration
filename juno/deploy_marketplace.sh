#!/bin/bash
source .env

UNIT_PRICE=100
DENOM="ujuno"

junod config

cd "$PATH_TO_CONTRACTS" || exit
git switch main
cd "$CURRENT_DIR" || exit

# Update the value in the .env file
sed -i "s/^minter_addr=.*/minter_addr=$ADDR/" .env

echo "Deploying pg721 metadata onchain contract..."
TX_HASH=$(junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/marketplace_legacy.wasm --from "$KEY" --gas auto --gas-adjustment 1.5 -y | jq -r '.txhash')

echo "tx-hash=$TX_HASH"
echo "waiting for transaction to be included in the block"

sleep 10

MP_CODE_ID=$(junod q tx "$TX_HASH" | jq -r '.logs[0]["events"][-1]["attributes"][-1]["value"]')

echo $MP_CODE_ID

echo $new_nft_address

MSG_INIT='{
  "admin": "juno1gtueg07w5f5h3hydvwzc2z5nz989e4p053dxre",
  "allowed_native": "ujuno",
  "collector_addr": "juno1gtueg07w5f5h3hydvwzc2z5nz989e4p053dxre",
  "fee_percentage": "0.1",
  "nft_addr": "'$new_nft_address'"
}
'

# instantiate contract
echo "Instantiating contract..."
junod tx wasm instantiate "$MP_CODE_ID" "$MSG_INIT" --from "$KEY" --label "nft marketplace onchain" --admin "$KEY" --gas auto --gas-adjustment 1.5 -y

sleep 10

MP_CONTRACT=$(junod query wasm list-contract-by-code $MP_CODE_ID --output json | jq -r '.contracts[-1]')

sed -i "s/^new_nft_address=.*/new_market_address=$MP_CONTRACT/" .env

echo $MP_CONTRACT

echo "NFT marketplace contract deployed. Address: $MP_CONTRACT"
