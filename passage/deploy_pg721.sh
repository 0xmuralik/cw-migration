#!/bin/bash
source .env

ADDR=$(passage keys show "$KEY" -a)
# Update the value in the .env file
sed -i "s/^minter_addr=.*/minter_addr=$ADDR/" .env

cd "$PATH_TO_CONTRACTS" || exit
git switch murali/migration
cd "$CURRENT_DIR" || exit

echo "Deploying contract..."
passage tx wasm store "$PATH_TO_CONTRACTS"/artifacts/pg721_metadata_onchain.wasm --from "$KEY" --gas auto --gas-adjustment 1.15 --chain-id "$CHAINID" -y -b block



NFT_CODE_ID=$(passage query wasm list-code --output json | jq -r '.code_infos[-1].code_id')
sed -i "s/^new_nft_code_id=.*/new_nft_code_id=$NFT_CODE_ID/" .env

# Load INIT payload
NFT_INIT=$(<./init_msgs/nft/$name.json)
NFT_INIT=$(echo "$NFT_INIT" | jq '.minter="'"$ADDR"'"')

# instantiate contract
echo "Instantiating contract..."
passage tx wasm instantiate "$NFT_CODE_ID" "$NFT_INIT" --from "$KEY" --chain-id "$CHAINID" --label "nft metadata onchain" --admin "$ADDR" --gas auto --gas-adjustment 1.15 -y -b block

NFT_CONTRACT=$(passage query wasm list-contract-by-code "$NFT_CODE_ID" --output json | jq -r '.contracts[-1]')
sed -i "s/^new_nft_address=.*/new_nft_address=$NFT_CONTRACT/" .env

echo "NFT contract deployed. NFT contract address: $NFT_CONTRACT"
len=$(jq '.migrations | length' ../output/nft_migrations.json)
batch_size=50
iterations=$(((len + batch_size -1) / batch_size))

# migrations
for ((i=0;i<iterations;i++)); do 
    start_index=$((i*batch_size))
    end_index=$((start_index+batch_size))
    TOKENS=$(jq ".migrations[$start_index:$end_index]" ../output/nft_migrations.json)
    MIGRATIONS='{
        "migrate": {
            "migrations": '$TOKENS'
        }    
    }'

    echo "Migration $((i+1)) / $iterations"
    passage tx wasm execute "$NFT_CONTRACT" "$MIGRATIONS" --from "$KEY" --chain-id "$CHAINID" --gas auto --gas-adjustment 1.15 -y -b block

    
done
# mark migration done

echo "Migration done"
passage tx wasm execute "$NFT_CONTRACT" '{"migration_done":{}}' --from "$KEY" --chain-id "$CHAINID" --gas auto --gas-adjustment 1.15 -y -b block