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
    try:
        json_object["key"]=bytes.fromhex(json_object.get("key")).decode()
    except UnicodeDecodeError:
        1+1

    json_object["value"]=base64.b64decode((json_object).get("value")).decode()

    return json_object

def convert_addr(addr):
    _, data = bech32.bech32_decode(addr)
    return bech32.bech32_encode("pasg",data)

def main():
    # Existing JSON array
    # tokens = []
    rest = []
    minters =[]

    # URL with pagination
    url = "https://juno.stakesystems.io/cosmwasm/wasm/v1/contract/juno15yalm0qgg0wzs4etkzzputy7hum8ryzc0rrfzfplnqjeyfrpufwq9u2zwd/state"
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

            if json_object.get("key").startswith("\u0000\u000eminter_address"):
                address=convert_addr(json_object.get("key")[16:])
                minter={"address":address,"mints":json_object.get("value")}
                append_to_json_array(minters,minter)
            else:
                append_to_json_array(rest, json_object)


        # Check if there are more pages
        pagination_key = response.get("pagination").get("next_key")
        if not pagination_key:
            break
    
    models = {"minters":minters,"models":rest}

    # Save the updated JSON array to a file
    with open("mint.json", "w") as file:
        json.dump(models, file,indent=4)

if __name__ == "__main__":
    main()
