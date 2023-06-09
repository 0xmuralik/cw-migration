#!/bin/bash
source .env

cd "$PATH_TO_CONTRACTS" || exit
git switch murali/migration
cd "$CURRENT_DIR" || exit

echo "Deploying $name minter contract..."
passage tx wasm store "$PATH_TO_CONTRACTS"/artifacts/minter_metadata_onchain.wasm --from "$KEY" --gas auto --gas-adjustment 1.15 --chain-id "$CHAINID" -y -b block

CODE_ID=$(passage query wasm list-code --output json | jq -r '.code_infos[-1].code_id')

# Load INIT payload
MINT_INIT=$(<./init_msgs/mint/$name.json)
MINT_INIT=$(echo "$MINT_INIT" | jq '.cw721_code_id='"$new_nft_code_id"'')
MINT_INIT=$(echo "$MINT_INIT" | jq '.cw721_address="'"$new_nft_address"'"')
echo "$MINT_INIT"

# instantiate contract
echo "Instantiating $name minting contract..."
passage tx wasm instantiate "$CODE_ID" "$MINT_INIT" --from "$KEY" --chain-id "$CHAINID" --label "minter metadata onchain" --admin "$minter_addr" --gas auto --gas-adjustment 1.15 -y -b block

MINT_CONTRACT=$(passage query wasm list-contract-by-code "$CODE_ID" --output json | jq -r '.contracts[-1]')

echo "$name minter contract deployed. Minter contract address: $MINT_CONTRACT"
sed -i "s/^new_mint_address=.*/new_mint_address=$MINT_CONTRACT/" .env

len=$(jq '.tokens | length' ../output/mint_migrations.json)
batch_size=50
iterations=$(((len + batch_size -1) / batch_size))

# migrate tokens
for ((i=0;i<iterations;i++)); do 
    start_index=$((i*batch_size))
    end_index=$((start_index+batch_size))
    TOKENS=$(jq ".tokens[$start_index:$end_index]" ../output/mint_migrations.json)
    MIGRATIONS='{
        "migrate_data": {
            "migrations": {
                "tokens":'$TOKENS'
            }
        }    
    }'

    echo "Migrating tokens $((i+1)) / $iterations"
    passage tx wasm execute "$MINT_CONTRACT" "$MIGRATIONS" --from "$KEY" --chain-id "$CHAINID" --gas auto --gas-adjustment 1.15 -y -b block

done

# migrate minters
len=$(jq '.minters | length' ../output/mint_migrations.json)
batch_size=50
iterations=$(((len + batch_size -1) / batch_size))
for ((i=0;i<iterations;i++)); do 
    start_index=$((i*batch_size))
    end_index=$((start_index+batch_size))
    MINTERS=$(jq ".minters[$start_index:$end_index]" ../output/mint_migrations.json)
    MIGRATIONS='{
        "migrate_data": {
            "migrations": {
                "minters":'$MINTERS'
            }
        }    
    }'

    echo "Migrating minters $((i+1)) / $iterations"
    passage tx wasm execute "$MINT_CONTRACT" "$MIGRATIONS" --from "$KEY" --chain-id "$CHAINID" --gas auto --gas-adjustment 1.15 -y -b block

    
done

# migrate mintable_tokens
MINTABLE_TOKENS=$(jq ".mintable_tokens" ../output/mint_migrations.json)

MIGRATIONS='{
        "migrate_data": {
            "migrations": {
                "mintable_tokens":'$MINTABLE_TOKENS'
            }
        }    
    }'

    echo "Migrating mintable tokens"
    passage tx wasm execute "$MINT_CONTRACT" "$MIGRATIONS" --from "$KEY" --chain-id "$CHAINID" --gas auto --gas-adjustment 1.15 -y -b block

    

# mark migration done
echo "Migration done"
passage tx wasm execute "$MINT_CONTRACT" '{"migration_done":{}}' --from "$KEY" --chain-id "$CHAINID" --gas auto --gas-adjustment 1.15 -y -b block