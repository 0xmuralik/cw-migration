#!/bin/bash
source .env

cd "$PATH_TO_CONTRACTS" || exit
git switch murali/migration
cd "$CURRENT_DIR" || exit

echo "Deploying $name marketplace contract..."
passage tx wasm store "$PATH_TO_CONTRACTS"/artifacts/marketplace_v2.wasm --from "$KEY" --gas auto --gas-adjustment 1.15 --chain-id "$CHAINID" -y -b block

CODE_ID=$(passage query wasm list-code --output json | jq -r '.code_infos[-1].code_id')

# Load INIT payload
MARKET_INIT=$(<./init_msgs/marketplace/$name.json)
MARKET_INIT=$(echo "$MARKET_INIT" | jq '.cw721_address="'"$new_nft_address"'"')
echo "$MARKET_INIT"

# instantiate contract
echo "Instantiating $name marketplace contract..."
passage tx wasm instantiate "$CODE_ID" "$MARKET_INIT" --from "$KEY" --chain-id "$CHAINID" --label "marketplace v2" --admin "$minter_addr" --gas auto --gas-adjustment 1.15 -y -b block

MARKET_CONTRACT=$(passage query wasm list-contract-by-code "$CODE_ID" --output json | jq -r '.contracts[-1]')

echo "$name marketplace contract deployed. Marketplace contract address: $MARKET_CONTRACT"
sed -i "s/^new_market_address=.*/new_market_address=$MARKET_CONTRACT/" .env