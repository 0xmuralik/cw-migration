#!/bin/bash
source .env

ADDR=$(passage keys show "$KEY" -a)
# Update the value in the .env file
sed -i "s/^minter_addr=.*/minter_addr=$ADDR/" .env

cd "$PATH_TO_CONTRACTS" || exit
git switch murali/migration
cd "$CURRENT_DIR" || exit


# Load INIT payload
NFT_INIT=$(<./init_msgs/nft/$name.json)
NFT_INIT=$(echo "$NFT_INIT" | jq '.minter="'"$ADDR"'"')

# instantiate contract
echo "Instantiating $name nft contract..."
NFT_CONTRACT=$(passage tx wasm instantiate "$pg721_code" "$NFT_INIT" --from "$KEY" --label "nft metadata onchain" --admin "$ADDR" --gas auto --gas-adjustment 1.15 -y -b block| jq -r '.logs[0]["events"][0]["attributes"][0]["value"]')

sed -i "s/^new_nft_address=.*/new_nft_address=$NFT_CONTRACT/" .env

echo "$name NFT contract deployed. NFT contract address: $NFT_CONTRACT"
len=$(jq '.migrations | length' ../output/$name/nft_migrations.json)
batch_size=50
iterations=$(((len + batch_size -1) / batch_size))

# migrations
for ((i=0;i<iterations;i++)); do
    start_index=$((i*batch_size))
    end_index=$((start_index+batch_size))
    TOKENS=$(jq ".migrations[$start_index:$end_index]" ../output/$name/nft_migrations.json)
    MIGRATIONS='{
        "migrate": {
            "migrations": '$TOKENS'
        }    
    }'

    echo "Migration $((i+1)) / $iterations"
    passage tx wasm execute "$NFT_CONTRACT" "$MIGRATIONS" --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block

    
done
# mark migration done

echo "Migration done"
passage tx wasm execute "$NFT_CONTRACT" '{"migration_done":{}}' --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block