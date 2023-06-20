#!/bin/bash
CHAINID="passage-1"
KEY="mykey"
PATH_TO_CONTRACTS="/home/vitwit/passage/passage-contracts"

source .env
echo "new nft code id: $new_nft_code_id"
echo "new nft address: $new_nft_address"

echo "Deploying minter contract..."
passage tx wasm store "$PATH_TO_CONTRACTS"/artifacts/minter_metadata_onchain.wasm --from $KEY --gas auto --gas-adjustment 1.15 --chain-id $CHAINID -y -b block



CODE_ID=$(passage query wasm list-code --output json | jq -r '.code_infos[-1].code_id')
CURRENT_TIME=$(($(date +%s)+600))
# Load INIT payload
MINT_INIT='{
  "max_num_tokens": 10000,
  "cw721_code_id": '$new_nft_code_id',
  "per_address_limit": 10000,
  "whitelist": null,
  "cw721_address": "'$new_nft_address'",
  "start_time": "'$CURRENT_TIME'000000000",
  "unit_price": {
    "amount": "'$unit_price'",
    "denom": "'$denom'"
  },
  "cw721_instantiate_msg": null
}'

echo $MINT_INIT

# instantiate contract
echo "Instantiating contract..."
passage tx wasm instantiate "$CODE_ID" "$MINT_INIT" --from $KEY --chain-id $CHAINID --label "minter metadata onchain" --no-admin --gas auto --gas-adjustment 1.15 -y -b block

MINT_CONTRACT=$(passage query wasm list-contract-by-code "$CODE_ID" --output json | jq -r '.contracts[-1]')

echo "Minter contract deployed. Minter contract address: $MINT_CONTRACT"
len=$(jq '.tokens | length' output/mint_migrations.json)
batch_size=50
iterations=$(((len + batch_size -1) / batch_size))

# migrate tokens
for ((i=0;i<iterations;i++)); do 
    start_index=$((i*batch_size))
    end_index=$((start_index+batch_size))
    TOKENS=$(jq ".tokens[$start_index:$end_index]" output/mint_migrations.json)
    MIGRATIONS='{
        "migrate_data": {
            "migrations": {
                "tokens":'$TOKENS'
            }
        }    
    }'

    echo "Migrating tokens $((i+1)) / $iterations"
    passage tx wasm execute "$MINT_CONTRACT" "$MIGRATIONS" --amount 100stake --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block

done

# migrate minters
len=$(jq '.minters | length' output/mint_migrations.json)
batch_size=50
iterations=$(((len + batch_size -1) / batch_size))
for ((i=0;i<iterations;i++)); do 
    start_index=$((i*batch_size))
    end_index=$((start_index+batch_size))
    MINTERS=$(jq ".minters[$start_index:$end_index]" output/mint_migrations.json)
    MIGRATIONS='{
        "migrate_data": {
            "migrations": {
                "minters":'$MINTERS'
            }
        }    
    }'

    echo "Migrating minters $((i+1)) / $iterations"
    passage tx wasm execute "$MINT_CONTRACT" "$MIGRATIONS" --amount 100stake --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block

    
done

# migrate mintable_tokens
MINTABLE_TOKENS=$(jq ".mintable_tokens" output/mint_migrations.json)

MIGRATIONS='{
        "migrate_data": {
            "migrations": {
                "mintable_tokens":'$MINTABLE_TOKENS'
            }
        }    
    }'

    echo "Migrating mintable tokens"
    passage tx wasm execute "$MINT_CONTRACT" "$MIGRATIONS" --amount 100stake --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block

    

# mark migration done
echo "Migration done"
passage tx wasm execute "$MINT_CONTRACT" '{"migration_done":{}}' --amount 100stake --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block



# mint new token
passage tx wasm execute "$MINT_CONTRACT" '{"mint":{}}' --amount 100stake --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block