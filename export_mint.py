import requests
import json
import base64
import bech32
import os
from dotenv import load_dotenv

def fetch_json(url):
    response = requests.get(url)
    response.raise_for_status()
    return response.json()

def append_to_json_array(json_array, json_object):
    json_array.append(json_object)

def decode_obj(json_object):
    try:
        json_object["key"]=bytes.fromhex(json_object.get("key")).decode()
    except UnicodeDecodeError:
        1+1

    json_object["value"]=base64.b64decode((json_object).get("value")).decode()

    return json_object

def convert_addr(addr):
    _, data = bech32.bech32_decode(addr)
    return bech32.bech32_encode("pasg",data)

def create_mint_init(models):
    mint_init={
        "max_num_tokens": models["config"]["max_num_tokens"],
        "cw721_code_id": int(os.getenv("new_nft_code_id")),
        "start_time":os.getenv("start_time"),
        "per_address_limit": models["config"]["per_address_limit"],
        "unit_price": {
            "denom": os.getenv("denom"),
            "amount": os.getenv("unit_price")
        },
        "whitelist": os.getenv("whitelist"),
        "cw721_address": os.getenv("new_nft_address"),
        "cw721_instantiate_msg": None,
        "migration":{
            "tokens":models["tokens"],
            "mintable_tokens":models["mintable_tokens"],
            "minters":models["minters"]
        }
    }

    with open("mint_init.json", "w") as file:
        json.dump(mint_init, file,indent=4)

def main():
    # JSON array
    rest = []
    minters =[]
    tokens=[]
    mintable_tokens=[]
    config={}

    contract_address=os.getenv("mint_address")

    # URL with pagination
    url = f"https://juno.stakesystems.io/cosmwasm/wasm/v1/contract/{contract_address}/state"
    print("Fetching data from ",url)
    total = fetch_json(url).get("pagination").get("total")
    # Pagination loop
    pagination_key = ""
    count=0
    while True:
        # Make the request
        response = fetch_json(f"{url}?pagination.key={pagination_key}")

        # Extract the JSON objects from the response
        json_objects = response.get("models", [])
        count+=len(json_objects)

        print("got "+str(count)+"/"+total+" items")

        # Append each JSON object to the existing array
        for json_object in json_objects:
            type=""
            if json_object.get("key").startswith("000A746F6B656E5F6D696E74"):
                type="token"
            
            json_object=decode_obj(json_object)

            if type == "token":
                token=json.loads(json_object.get("value"))
                append_to_json_array(tokens,token)
            elif json_object.get("key").startswith("\u0000\u000eminter_address"):
                address=convert_addr(json_object.get("key")[16:])
                minter={"address":address,"mints":json_object.get("value")}
                append_to_json_array(minters,minter)
            elif json_object.get("key") == "mintable_token_ids":
                mintable_tokens=json.loads(json_object.get("value"))
            elif json_object.get("key")=="config":
                config=json.loads(json_object.get("value"))
            else:
                append_to_json_array(rest, json_object)


        # Check if there are more pages
        pagination_key = response.get("pagination").get("next_key")
        if not pagination_key:
            break
    
    models = {"tokens":tokens,"minters":minters,"mintable_tokens":mintable_tokens,"config":config,"models":rest}

    create_mint_init(models)

    # Save the updated JSON array to a file
    with open("mint.json", "w") as file:
        json.dump(models, file,indent=4)

if __name__ == "__main__":
     # Load the environment variables from the .env file
    load_dotenv()

    main()
