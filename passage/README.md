# Contract Migrations from Juno to Passage

### Setup

* Install Wasm: https://book.cosmwasm.com/setting-up-env.html
* Passage3D CLI
      * Clone https://github.com/envadiv/Passage3D
      * To install run `make install` inside passage3d repo
* Passage Contracts
      * Clone https://github.com/envadiv/passage-contracts
* Migration scripts
       * Clone https://github.com/0xmuralik/cw-migration

### Add contracts to migrate

Go to `cw-migration/contracts.json` and add the name of the contract, Juno NFT contract address, Mint contract address, Marketplace contract address and name of the admin key to the `contracts` array.

Example:

```bash
{
    "name": "metahuahua",
    "nft": "juno10nv5896xx4v6wu2svkghwxd0j5t8c26ehzwhr2y8q959zzwh3m8qyxryw0",
    "mint": "juno15yalm0qgg0wzs4etkzzputy7hum8ryzc0rrfzfplnqjeyfrpufwq9u2zwd",
    "marketplace": "juno1wefnd9l3fl68knhhm445mq9f2v9yyna7q63m9yl2pwkemlsrfmhqlys9p7",
    "adminKey": "murali"
}
```

If there is no Mint contract for the nft, use null as the value for mint field.

Note: the value "name" will be used later to get the init messages of contracts, hence use snake case for contract names. Ex: `strange_clan_eggs`

### Init Messages

The init messages for each of the contract are fetched taken from `cw-migrations/passage/init_msgs`.

Configure these messages as required. Feilds like minter_address, cw721_code_id, cw721_address will be populated at runtime.

The file name should be same as the name of the contract in contracts.json. `<contract_name>.json`

### Env variables

The env variables for each migration are taken from `cw-migrations/passage/.env` .
Inside the .env file, there are 3 sets of variables.

1. Configurable ENVs: Chain ID, Path to contracts and current directory
2. Contract based ENVs: Changes based on current contract migration
3. Runtime ENVs: Temporary store to access variables accross scripts during migrations

Only configurable envs must be set by the user.

* ChainID: chain id of the network
* Path to contracts: absolute path to passage-contracts
* Current Directory: absolute path to `cw-migrations/passage` (pwd).

### Run migrations

After setting up everything as mentioned above; to run migrations run `cw-migrations/migrate_all.sh`.

```bash
./migrate_all.sh
```

This triggers migrations of each contract mentioned in the `contracts.json` file sequentially.

## Steps during migration

1. Export and decode NFT contract data from Juno
2. Deploy and instantiate NFT contract on Passage
3. Run NFT migrations onto passage
4. Mark NFT migration done on passage (enables to execute txs)
5. Export and decode minter contract data from Juno
6. Deploy and instantiate minter contract on Passage
7. Run minter migrations onto passage
8. Mark minter migrations done on passage
9. Upgrade NFT contract to update minter address to minter contract (needs NFT contract version upgrade) via `tx wasm migrate`
10. Deploy and instantiate MarketplaceV2 contract on Passage.

If minter contract doesn't exist on Juno, Steps 5-9 are skipped.
