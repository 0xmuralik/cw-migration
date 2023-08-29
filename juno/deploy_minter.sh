#!/bin/bash
CHAINID="junod-1"
KEY="mykey"
PATH_TO_CONTRACTS="/home/vitwit/passage/passage-contracts"
CURRENT_DIR=$(pwd)

source .env
echo "new nft code id: $new_nft_code_id"
echo "new nft address: $new_nft_address"

cd $PATH_TO_CONTRACTS || exit
git switch main
cd "$CURRENT_DIR" || exit

echo "Deploying minter contract..."
junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/minter_metadata_onchain.wasm --from $KEY --gas auto --gas-adjustment 1.15 --chain-id $CHAINID -y -b block



CODE_ID=$(junod query wasm list-code --reverse --output json | jq -r '.code_infos[0].code_id')
CURRENT_TIME=$(($(date +%s)+10))
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

echo "$MINT_INIT"

# instantiate contract
echo "Instantiating contract..."
junod tx wasm instantiate "$CODE_ID" "$MINT_INIT" --from $KEY --chain-id $CHAINID --label "minter metadata onchain" --admin $KEY --gas auto --gas-adjustment 1.15 -y -b block

MINT_CONTRACT=$(junod query wasm list-contract-by-code "$CODE_ID" --output json | jq -r '.contracts[-1]')

echo "Minter contract deployed. Minter contract address: $MINT_CONTRACT"
sed -i "s/^new_minter_contract=.*/new_minter_contract=$MINT_CONTRACT/" .env

UPSERT_TOKENS='{
    "upsert_token_metadatas":{
        "token_metadatas": [
    {
      "token_id": 701,
      "metadata": {
        "attributes": [
          {
            "trait_type": "Name",
            "value": "MetaHuahua #701",
            "display_type": "String"
          },
          {
            "trait_type": "Background",
            "value": "Sky",
            "display_type": "String"
          },
          {
            "trait_type": "Cosmos Background",
            "value": "Peaceful",
            "display_type": "String"
          },
          {
            "trait_type": "Tag",
            "value": "HODL",
            "display_type": "String"
          },
          {
            "trait_type": "Cercle",
            "value": "Purplechill",
            "display_type": "String"
          },
          {
            "trait_type": "Mustache",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Snout",
            "value": "Pixel_Smoke",
            "display_type": "String"
          },
          {
            "trait_type": "Eyes",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Head",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Hear",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Metadataaa",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Exclusive",
            "value": "None",
            "display_type": "String"
          }
        ],
        "name": "MetaHuahua #701",
        "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/701.png",
        "description": null,
        "background_color": null,
        "external_url": null,
        "image_data": null,
        "animation_url": null,
        "youtube_url": null
      }
    },
    {
      "token_id": 702,
      "metadata": {
        "attributes": [
          {
            "trait_type": "Name",
            "value": "MetaHuahua #702",
            "display_type": "String"
          },
          {
            "trait_type": "Background",
            "value": "Saphire",
            "display_type": "String"
          },
          {
            "trait_type": "Cosmos Background",
            "value": "Calm",
            "display_type": "String"
          },
          {
            "trait_type": "Tag",
            "value": "DYOR",
            "display_type": "String"
          },
          {
            "trait_type": "Cercle",
            "value": "AAAPop_Yellow",
            "display_type": "String"
          },
          {
            "trait_type": "Mustache",
            "value": "Gallic",
            "display_type": "String"
          },
          {
            "trait_type": "Snout",
            "value": "Rose",
            "display_type": "String"
          },
          {
            "trait_type": "Eyes",
            "value": "Cute_Blue",
            "display_type": "String"
          },
          {
            "trait_type": "Head",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Hear",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Metadataaa",
            "value": "PASG_Airdrop",
            "display_type": "String"
          },
          {
            "trait_type": "Exclusive",
            "value": "None",
            "display_type": "String"
          }
        ],
        "name": "MetaHuahua #702",
        "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/702.png",
        "description": null,
        "background_color": null,
        "external_url": null,
        "image_data": null,
        "animation_url": null,
        "youtube_url": null
      }
    },
    {
      "token_id": 703,
      "metadata": {
        "attributes": [
          {
            "trait_type": "Name",
            "value": "MetaHuahua #703",
            "display_type": "String"
          },
          {
            "trait_type": "Background",
            "value": "Sky",
            "display_type": "String"
          },
          {
            "trait_type": "Cosmos Background",
            "value": "Atmospheric",
            "display_type": "String"
          },
          {
            "trait_type": "Tag",
            "value": "DYOR",
            "display_type": "String"
          },
          {
            "trait_type": "Cercle",
            "value": "AAAPop_Red",
            "display_type": "String"
          },
          {
            "trait_type": "Mustache",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Snout",
            "value": "Desire",
            "display_type": "String"
          },
          {
            "trait_type": "Eyes",
            "value": "Cute_Pink",
            "display_type": "String"
          },
          {
            "trait_type": "Head",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Hear",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Metadataaa",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Exclusive",
            "value": "None",
            "display_type": "String"
          }
        ],
        "name": "MetaHuahua #703",
        "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/703.png",
        "description": null,
        "background_color": null,
        "external_url": null,
        "image_data": null,
        "animation_url": null,
        "youtube_url": null
      }
    },
    {
      "token_id": 704,
      "metadata": {
        "attributes": [
          {
            "trait_type": "Name",
            "value": "MetaHuahua #704",
            "display_type": "String"
          },
          {
            "trait_type": "Background",
            "value": "Salmon",
            "display_type": "String"
          },
          {
            "trait_type": "Cosmos Background",
            "value": "Peaceful",
            "display_type": "String"
          },
          {
            "trait_type": "Tag",
            "value": "LOVE",
            "display_type": "String"
          },
          {
            "trait_type": "Cercle",
            "value": "Creativity",
            "display_type": "String"
          },
          {
            "trait_type": "Mustache",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Snout",
            "value": "Joker_Blue",
            "display_type": "String"
          },
          {
            "trait_type": "Eyes",
            "value": "Robot_Blue",
            "display_type": "String"
          },
          {
            "trait_type": "Head",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Hear",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Metadataaa",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Exclusive",
            "value": "None",
            "display_type": "String"
          }
        ],
        "name": "MetaHuahua #704",
        "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/704.png",
        "description": null,
        "background_color": null,
        "external_url": null,
        "image_data": null,
        "animation_url": null,
        "youtube_url": null
      }
    },
    {
      "token_id": 705,
      "metadata": {
        "attributes": [
          {
            "trait_type": "Name",
            "value": "MetaHuahua #705",
            "display_type": "String"
          },
          {
            "trait_type": "Background",
            "value": "Sky",
            "display_type": "String"
          },
          {
            "trait_type": "Cosmos Background",
            "value": "Atmospheric",
            "display_type": "String"
          },
          {
            "trait_type": "Tag",
            "value": "FOMO",
            "display_type": "String"
          },
          {
            "trait_type": "Cercle",
            "value": "Dynamic",
            "display_type": "String"
          },
          {
            "trait_type": "Mustache",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Snout",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Eyes",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Head",
            "value": "King_Blue",
            "display_type": "String"
          },
          {
            "trait_type": "Hear",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Metadataaa",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Exclusive",
            "value": "None",
            "display_type": "String"
          }
        ],
        "name": "MetaHuahua #705",
        "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/705.png",
        "description": null,
        "background_color": null,
        "external_url": null,
        "image_data": null,
        "animation_url": null,
        "youtube_url": null
      }
    },
    {
      "token_id": 706,
      "metadata": {
        "attributes": [
          {
            "trait_type": "Name",
            "value": "MetaHuahua #706",
            "display_type": "String"
          },
          {
            "trait_type": "Background",
            "value": "Salmon",
            "display_type": "String"
          },
          {
            "trait_type": "Cosmos Background",
            "value": "Calm",
            "display_type": "String"
          },
          {
            "trait_type": "Tag",
            "value": "HODL",
            "display_type": "String"
          },
          {
            "trait_type": "Cercle",
            "value": "Dynamic",
            "display_type": "String"
          },
          {
            "trait_type": "Mustache",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Snout",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Eyes",
            "value": "Cute_Blue",
            "display_type": "String"
          },
          {
            "trait_type": "Head",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Hear",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Metadataaa",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Exclusive",
            "value": "None",
            "display_type": "String"
          }
        ],
        "name": "MetaHuahua #706",
        "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/706.png",
        "description": null,
        "background_color": null,
        "external_url": null,
        "image_data": null,
        "animation_url": null,
        "youtube_url": null
      }
    },
    {
      "token_id": 707,
      "metadata": {
        "attributes": [
          {
            "trait_type": "Name",
            "value": "MetaHuahua #707",
            "display_type": "String"
          },
          {
            "trait_type": "Background",
            "value": "Cream",
            "display_type": "String"
          },
          {
            "trait_type": "Cosmos Background",
            "value": "Atmospheric",
            "display_type": "String"
          },
          {
            "trait_type": "Tag",
            "value": "ANON",
            "display_type": "String"
          },
          {
            "trait_type": "Cercle",
            "value": "Greenpece",
            "display_type": "String"
          },
          {
            "trait_type": "Mustache",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Snout",
            "value": "Entice",
            "display_type": "String"
          },
          {
            "trait_type": "Eyes",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Head",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Hear",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Metadataaa",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Exclusive",
            "value": "None",
            "display_type": "String"
          }
        ],
        "name": "MetaHuahua #707",
        "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/707.png",
        "description": null,
        "background_color": null,
        "external_url": null,
        "image_data": null,
        "animation_url": null,
        "youtube_url": null
      }
    },
    {
      "token_id": 708,
      "metadata": {
        "attributes": [
          {
            "trait_type": "Name",
            "value": "MetaHuahua #708",
            "display_type": "String"
          },
          {
            "trait_type": "Background",
            "value": "Cream",
            "display_type": "String"
          },
          {
            "trait_type": "Cosmos Background",
            "value": "Peaceful",
            "display_type": "String"
          },
          {
            "trait_type": "Tag",
            "value": "BTFD",
            "display_type": "String"
          },
          {
            "trait_type": "Cercle",
            "value": "Infinity",
            "display_type": "String"
          },
          {
            "trait_type": "Mustache",
            "value": "Master_Sushi",
            "display_type": "String"
          },
          {
            "trait_type": "Snout",
            "value": "Rose",
            "display_type": "String"
          },
          {
            "trait_type": "Eyes",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Head",
            "value": "Berret_Red",
            "display_type": "String"
          },
          {
            "trait_type": "Hear",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Metadataaa",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Exclusive",
            "value": "None",
            "display_type": "String"
          }
        ],
        "name": "MetaHuahua #708",
        "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/708.png",
        "description": null,
        "background_color": null,
        "external_url": null,
        "image_data": null,
        "animation_url": null,
        "youtube_url": null
      }
    },
    {
      "token_id": 709,
      "metadata": {
        "attributes": [
          {
            "trait_type": "Name",
            "value": "MetaHuahua #709",
            "display_type": "String"
          },
          {
            "trait_type": "Background",
            "value": "Saphire",
            "display_type": "String"
          },
          {
            "trait_type": "Cosmos Background",
            "value": "Lab",
            "display_type": "String"
          },
          {
            "trait_type": "Tag",
            "value": "HODL",
            "display_type": "String"
          },
          {
            "trait_type": "Cercle",
            "value": "AAAPop_Yellow",
            "display_type": "String"
          },
          {
            "trait_type": "Mustache",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Snout",
            "value": "Vampire",
            "display_type": "String"
          },
          {
            "trait_type": "Eyes",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Head",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Hear",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Metadataaa",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Exclusive",
            "value": "None",
            "display_type": "String"
          }
        ],
        "name": "MetaHuahua #709",
        "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/709.png",
        "description": null,
        "background_color": null,
        "external_url": null,
        "image_data": null,
        "animation_url": null,
        "youtube_url": null
      }
    },
    {
      "token_id": 710,
      "metadata": {
        "attributes": [
          {
            "trait_type": "Name",
            "value": "MetaHuahua #710",
            "display_type": "String"
          },
          {
            "trait_type": "Background",
            "value": "Sky",
            "display_type": "String"
          },
          {
            "trait_type": "Cosmos Background",
            "value": "Atmospheric",
            "display_type": "String"
          },
          {
            "trait_type": "Tag",
            "value": "HODL",
            "display_type": "String"
          },
          {
            "trait_type": "Cercle",
            "value": "AAAPop_Red",
            "display_type": "String"
          },
          {
            "trait_type": "Mustache",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Snout",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Eyes",
            "value": "Cute_Red",
            "display_type": "String"
          },
          {
            "trait_type": "Head",
            "value": "Born_To_Be_Alive_Human",
            "display_type": "String"
          },
          {
            "trait_type": "Hear",
            "value": "None",
            "display_type": "String"
          },
          {
            "trait_type": "Metadataaa",
            "value": "Beta_Test",
            "display_type": "String"
          },
          {
            "trait_type": "Exclusive",
            "value": "None",
            "display_type": "String"
          }
        ],
        "name": "MetaHuahua #710",
        "image": "ipfs://bafybeideczllcb5kz75hgy25irzevarybvazgdiaeiv2xmgqevqgo6d3ua/710.png",
        "description": null,
        "background_color": null,
        "external_url": null,
        "image_data": null,
        "animation_url": null,
        "youtube_url": null
      }
    }
  ]
    }
}'

echo "Upserting token metadata"
junod tx wasm execute "$MINT_CONTRACT" "$UPSERT_TOKENS" --amount 100stake --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block

cd $PATH_TO_CONTRACTS || exit
git switch murali/nft_version
cd "$CURRENT_DIR" || exit

echo "Deploying pg721 metadata onchain contract..."
junod tx wasm store "$PATH_TO_CONTRACTS"/artifacts/pg721_metadata_onchain.wasm --from $KEY --gas auto --gas-adjustment 1.15 --chain-id $CHAINID -y -b block

NFT_CODE_ID=$(junod query wasm list-code --reverse --output json | jq -r '.code_infos[0].code_id')
sed -i "s/^new_nft_code_id=.*/new_nft_code_id=$NFT_CODE_ID/" .env

migrate_msg='{"minter":"'"$MINT_CONTRACT"'"}'
echo "Change minter to minting contract...."
junod tx wasm migrate "$new_nft_address" "$NFT_CODE_ID" "$migrate_msg" --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block

# wait for minting to start
sleep 10

echo "Minting token"
junod tx wasm execute "$MINT_CONTRACT" '{"mint":{}}' --amount 100stake --from $KEY --chain-id $CHAINID --gas auto --gas-adjustment 1.15 -y -b block
