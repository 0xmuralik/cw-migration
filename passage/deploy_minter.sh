#!/bin/bash
source .env

cd "$PATH_TO_CONTRACTS" || exit
git switch murali/migration
cd "$CURRENT_DIR" || exit

# Load INIT payload
MINT_INIT=$(<./init_msgs/mint/$name.json)
MINT_INIT=$(echo "$MINT_INIT" | jq '.cw721_code_id='"$pg721_code"'')
MINT_INIT=$(echo "$MINT_INIT" | jq '.cw721_address="'"$new_nft_address"'"')
echo "$MINT_INIT"

# instantiate contract
echo "Instantiating $name minting contract..."
MINT_CONTRACT=$(passage tx wasm instantiate "$minter_code" "$MINT_INIT" --from "$KEY" --label "minter metadata onchain" --admin "$minter_addr" --gas auto --gas-adjustment 1.15 -y -b block| jq -r '.logs[0]["events"][0]["attributes"][0]["value"]')

echo "$name minter contract deployed. Minter contract address: $MINT_CONTRACT"
sed -i "s/^new_mint_address=.*/new_mint_address=$MINT_CONTRACT/" .env

len=$(jq '.tokens | length' ../output/$name/mint_migrations.json)
batch_size=50
iterations=$(((len + batch_size -1) / batch_size))

# migrate tokens
for ((i=0;i<iterations;i++)); do 
    start_index=$((i*batch_size))
    end_index=$((start_index+batch_size))
    TOKENS=$(jq ".tokens[$start_index:$end_index]" ../output/$name/mint_migrations.json)
    MIGRATIONS='{
        "migrate_data": {
            "migrations": {
                "tokens":'$TOKENS'
            }
        }    
    }'

    echo "Migrating tokens $((i+1)) / $iterations"
    passage tx wasm execute "$MINT_CONTRACT" "$MIGRATIONS" --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block

done

# migrate minters
len=$(jq '.minters | length' ../output/$name/mint_migrations.json)
batch_size=50
iterations=$(((len + batch_size -1) / batch_size))
for ((i=0;i<iterations;i++)); do 
    start_index=$((i*batch_size))
    end_index=$((start_index+batch_size))
    MINTERS=$(jq ".minters[$start_index:$end_index]" ../output/$name/mint_migrations.json)
    MIGRATIONS='{
        "migrate_data": {
            "migrations": {
                "minters":'$MINTERS'
            }
        }    
    }'

    echo "Migrating minters $((i+1)) / $iterations"
    passage tx wasm execute "$MINT_CONTRACT" "$MIGRATIONS" --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block

    
done

# migrate mintable_tokens
MINTABLE_TOKENS=$(jq ".mintable_tokens" ../output/$name/mint_migrations.json)

MIGRATIONS='{
        "migrate_data": {
            "migrations": {
                "mintable_tokens":'$MINTABLE_TOKENS'
            }
        }    
    }'

    echo "Migrating mintable tokens"
    passage tx wasm execute "$MINT_CONTRACT" "$MIGRATIONS" --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block

    

# mark migration done
echo "Migration done"
passage tx wasm execute "$MINT_CONTRACT" '{"migration_done":{}}' --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block