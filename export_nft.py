import requests
import json
import base64
import bech32

def fetch_json(url):
    response = requests.get(url)
    response.raise_for_status()
    return response.json()

def append_to_json_array(json_array, json_object):
    json_array.append(json_object)

def decode_obj(json_object):
    json_object["key"]=bytes.fromhex(json_object.get("key")).decode()
    json_object["value"]=base64.b64decode((json_object).get("value")).decode()
    return json_object

def convert_addr(addr):
    _, data = bech32.bech32_decode(addr)
    return bech32.bech32_encode("pasg",data)

def main():
    # Existing JSON array
    tokens = []
    rest = []

    # URL with pagination
    url = "https://juno.stakesystems.io/cosmwasm/wasm/v1/contract/juno10nv5896xx4v6wu2svkghwxd0j5t8c26ehzwhr2y8q959zzwh3m8qyxryw0/state"
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
            json_object=decode_obj(json_object)

            # Replace Juno address with pasg address in keys
            key=json_object.get("key")
            i=key.find("juno")
            if i != -1 :
                juno_addr=key[i:i+43]
                pasg_addr=convert_addr(juno_addr)
                key=key.replace(juno_addr,pasg_addr)
                json_object["key"]=key
                append_to_json_array(rest, json_object)
            
            elif key.startswith("\u0000\u0006tokens"):
                val=json.loads(json_object.get("value"))
                val["owner"]=convert_addr(val["owner"])
                    
                token={"token_id":key[8:],"owner":val["owner"],"token_uri":val["token_uri"],"extension":val["extension"]}
                append_to_json_array(tokens,token) 

            
            elif "minter" == key:
                val=json.loads(json_object.get("value"))
                json_object["value"]=json.dumps(convert_addr(val))
                append_to_json_array(rest, json_object)
            
            else: 
                append_to_json_array(rest, json_object)

        # Check if there are more pages
        pagination_key = response.get("pagination").get("next_key")
        if not pagination_key:
            break
    
    models = {"tokens": tokens,"rest": rest}

    # Save the updated JSON array to a file
    with open("nft.json", "w") as file:
        json.dump(models, file,indent=4)

if __name__ == "__main__":
    main()
