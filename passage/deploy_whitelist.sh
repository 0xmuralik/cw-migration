source .env

ADDR=$(passage keys show "$KEY" -a)

# echo "Deploying $name nft contract..."
# RESULT=$(passage tx wasm store "$PATH_TO_CONTRACTS"/artifacts/whitelist.wasm --from "$KEY" --gas 100000000 --gas-adjustment 1.8 -y -b block)


# CODE=$(echo $RESULT | jq -r '.code')
# if [ $CODE != 0 ]; then
#     echo "Something went wrong"
#     echo $RESULT
#     exit 1
# fi

# TX_HASH=$(echo $RESULT | jq -r '.txhash')
# echo "tx-hash=$TX_HASH"


# sleep 6

# WHITELIST_CODE_ID=$(passage q tx "$TX_HASH" | jq -r '.logs[0]["events"][-1]["attributes"][-1]["value"]')

WHITELIST_CODE_ID=71
echo $WHITELIST_CODE_ID

WHITELIST_INIT=$(<./init_msgs/whitelist/$name.json)

passage tx wasm instantiate "$WHITELIST_CODE_ID" "$WHITELIST_INIT" --from "$KEY" --label "whitelist" --admin "$ADDR" --gas auto --gas-adjustment 1.15 -y -b block



WHITELIST_CONTRACT=$(passage query wasm list-contract-by-code "$WHITELIST_CODE_ID" --output json | jq -r '.contracts[-1]')

# echo "$name NFT contract deployed. NFT contract address: $NFT_CONTRACT"
len=$(jq '. | length' ../output/whitelist_addr.json)
batch_size=50
iterations=$(((len + batch_size -1) / batch_size))

# migrations
for ((i=0;i<iterations;i++)); do
    start_index=$((i*batch_size))
    end_index=$((start_index+batch_size))
    ADDRESSES=$(jq ".[$start_index:$end_index]" ../output/whitelist_addr.json)

    echo "{\"add_members\":{\"to_add\":$ADDRESSES}}"
    passage tx wasm execute $WHITELIST_CONTRACT "{\"add_members\":{\"to_add\":$ADDRESSES}}" --from "$KEY" --gas auto --gas-adjustment 1.15 -y -b block

    echo "Migration $((i+1)) / $iterations"

    
done

echo $WHITELIST_CODE_ID
echo $WHITELIST_CONTRACT

