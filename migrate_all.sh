#!/bin/bash
CONTRACTS=$(jq ".contracts" ./contracts.json)
NEW_CONTRACTS='[]'
len=$(jq ".contracts | length" ./contracts.json)

cd ./passage || exit
for ((i=0;i<len;i++)); do
    name=$(echo "$CONTRACTS" | jq -r ' .['$i'] | .name')
    nft=$(echo "$CONTRACTS" | jq -r ' .['$i'] | .nft')
    mint=$(echo "$CONTRACTS" | jq -r ' .['$i'] | .mint')

    echo "Migrating $name contract"
    sed -i "s/^name=.*/name=$name/" .env
    sed -i "s/^nft_address=.*/nft_address=$nft/" .env
    sed -i "s/^mint_address=.*/mint_address=$mint/" .env
    
    ./migrate.sh

    source .env
    
    new='{"name":"'$name'","nft":"'$new_nft_address'","mint":"'$new_mint_address'"}'
    NEW_CONTRACTS=$(echo "$NEW_CONTRACTS" | jq '. += ['$new']')
done

cd ..
echo "$NEW_CONTRACTS" > new_contracts.json