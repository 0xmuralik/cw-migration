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
    tokens=[]
    mintable_tokens=[]

    # URL with pagination
    url = "http://143.244.137.73:1317/cosmwasm/wasm/v1/contract/pasg1sgv38zd5z4fje0djf7u08t9cdfqe0kx9nl4x3k8rdx7wkr2sttgscfgetk/state"
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

            append_to_json_array(rest, json_object)


        # Check if there are more pages
        pagination_key = response.get("pagination").get("next_key")
        if not pagination_key:
            break
    
    models = {"models":rest}

    # Save the updated JSON array to a file
    with open("../output/output.json", "w") as file:
        json.dump(models, file,indent=4)

if __name__ == "__main__":
    main()
