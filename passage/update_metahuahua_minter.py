# Python program to update json data from csv
# execute script by running
# python3 csv_to json_migration.py <csv_file_path> <json_file_path>
import sys, csv, json


# parse arguments
args = sys.argv

if len(args) < 3:
    print("""Invalid args length, please execute script by running:
python3 csv_to json_migration.py <csv_file_path> <json_file_path>""")
    sys.exit(1)

csv_file_path = args[1]
json_file_path = args[2]

csv_data = {}

with open(csv_file_path, 'r' ) as csv_file:
    reader = csv.DictReader(csv_file)
    for line in reader:
        csv_data[line['TOKEN_ID']] = line

with open(json_file_path, 'r', encoding='utf-8') as json_file:
    json_data = json.load(json_file)

if "tokens" not in json_data:
    print("No tokens found in json data")
    sys.exit(0)

updated_list = []

for data in json_data['tokens']:
    token_id = data['token_id']
    if token_id in csv_data:
        if 'metadata' not in data:
            continue

        data['metadata']['image'] = csv_data[token_id]['IMAGE']
        data['metadata']['name'] = csv_data[token_id]['NAME']

        if 'attributes' not in data['metadata']:
            continue

        for attribute in data['metadata']['attributes']:
            if 'trait_type' not in attribute:
                continue

            if attribute['trait_type'] == 'Name':
                attribute['value'] = csv_data[token_id]['NAME']

            if attribute['trait_type'] == 'Background':
                attribute['value'] = csv_data[token_id]['BACKGROUND']

            if attribute['trait_type'] == 'Cosmos Background':
                attribute['value'] = csv_data[token_id]['COSMOS_BACKGROUND']

            if attribute['trait_type'] == 'Tag':
                attribute['value'] = csv_data[token_id]['TAG']

            if attribute['trait_type'] == 'Cercle':
                attribute['value'] = csv_data[token_id]['CIRCLE']

            if attribute['trait_type'] == 'Mustache':
                attribute['value'] = csv_data[token_id]['MUSTACHE']

            if attribute['trait_type'] == 'Snout':
                attribute['value'] = csv_data[token_id]['SNOUT']

            if attribute['trait_type'] == 'Eyes':
                attribute['value'] = csv_data[token_id]['EYES']

            if attribute['trait_type'] == 'Head':
                attribute['value'] = csv_data[token_id]['HEAD']

            if attribute['trait_type'] == 'Hear':
                attribute['value'] = csv_data[token_id]['HEAR']

            if attribute['trait_type'] == 'Metadataaa':
                attribute['value'] = csv_data[token_id]['METADATAAA']

            if attribute['trait_type'] == 'Exclusive':
                attribute['value'] = csv_data[token_id]['EXCLUSIVE']

with open("updated_minter_migrations.json", 'w', encoding='utf-8') as json_file:
    json.dump(json_data, json_file)
    print('Migrations data updated successfully to updated_migrations.json')