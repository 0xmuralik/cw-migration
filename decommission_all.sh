#!/bin/bash
CONTRACTS=$(jq ".contracts" ./contracts.json)
len=$(jq ".contracts | length" ./contracts.json)

cd ./juno || exit
for ((i=0;i<len;i++)); do
    name=$(echo "$CONTRACTS" | jq -r ' .['$i'] | .name')
    nft=$(echo "$CONTRACTS" | jq -r ' .['$i'] | .nft')
    mint=$(echo "$CONTRACTS" | jq -r ' .['$i'] | .mint')
    market=$(echo "$CONTRACTS" | jq -r ' .['$i'] | .marketplace')
    key=$(echo "$CONTRACTS" | jq -r ' .['$i'] | .adminKey')

    echo "Migrating $name contract"
    sed -i "s/^name=.*/name=$name/" .env
    sed -i "s/^nft_address=.*/nft_address=$nft/" .env
    sed -i "s/^minter_address=.*/minter_address=$mint/" .env
    sed -i "s/^marketplace_address=.*/marketplace_address=$market/" .env
    sed -i "s/^KEY=.*/KEY=$key/" .env
    
    ./decommission.sh
done
