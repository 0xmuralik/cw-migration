#!/bin/bash
source .env

cd "$PATH_TO_CONTRACTS" || exit
git switch murali/migration
cd "$CURRENT_DIR" || exit

echo "Deploying $name marketplace contract..."
RESULT=$(passage tx wasm store "$PATH_TO_CONTRACTS"/artifacts/marketplace_v2.wasm --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block)

CODE=$(echo $RESULT | jq -r '.code')
if [ $CODE != 0 ]; then
    echo "Something went wrong"
    echo $RESULT
    exit 1
fi

TX_HASH=$(echo $RESULT | jq -r '.txhash')
echo "tx-hash=$TX_HASH"

sleep 6

CODE_ID=$(passage q tx "$TX_HASH" | jq -r '.logs[0]["events"][-1]["attributes"][-1]["value"]')
echo $CODE_ID

# Load INIT payload
MARKET_INIT=$(<./init_msgs/marketplace/$name.json)
MARKET_INIT=$(echo "$MARKET_INIT" | jq '.cw721_address="'"$new_nft_address"'"')
echo "$MARKET_INIT"

# instantiate contract
echo "Instantiating $name marketplace contract..."
MARKET_CONTRACT=$(passage tx wasm instantiate "$CODE_ID" "$MARKET_INIT" --from "$KEY" --label "marketplace v2" --admin "$minter_addr" --gas auto --gas-adjustment 1.15 -y -b block| jq -r '.logs[0]["events"][0]["attributes"][0]["value"]')

echo "$name marketplace contract deployed. Marketplace contract address: $MARKET_CONTRACT"
sed -i "s/^new_market_address=.*/new_market_address=$MARKET_CONTRACT/" .env