#!/bin/bash
source .env

cd "$PATH_TO_CONTRACTS" || exit
git switch murali/migration
cd "$CURRENT_DIR" || exit

# Load INIT payload
MARKET_INIT=$(<./init_msgs/marketplace/$name.json)
MARKET_INIT=$(echo "$MARKET_INIT" | jq '.cw721_address="'"$new_nft_address"'"')
echo "$MARKET_INIT"

# instantiate contract
echo "Instantiating $name marketplace contract..."
MARKET_CONTRACT=$(passage tx wasm instantiate "$marketplace_code" "$MARKET_INIT" --from "$KEY" --label "marketplace v2" --admin "$minter_addr" --gas 100000000 --gas-adjustment 1.8 -y -b block| jq -r '.logs[0]["events"][0]["attributes"][0]["value"]')

echo "$name marketplace contract deployed. Marketplace contract address: $MARKET_CONTRACT"
sed -i "s/^new_market_address=.*/new_market_address=$MARKET_CONTRACT/" .env