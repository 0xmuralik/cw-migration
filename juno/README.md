# Contract decommission on Juno

### Setup

* Install Wasm: https://book.cosmwasm.com/setting-up-env.html
* Passage Contracts
        * Clone https://github.com/envadiv/passage-contracts
* Migration scripts
        * Clone https://github.com/0xmuralik/cw-migration

### Add contracts to decommission

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

### Env variables

The env variables for each decommission are taken from `cw-migrations/juno/.env` .
Inside the .env file, there are 2 sets of variables.

1. Configurable ENVs: Chain ID, Path to contracts and current directory
2. Contract based ENVs: Changes based on current contract migration

Only configurable envs must be set by the user.

* ChainID: chain id of the network
* Path to contracts: absolute path to passage-contracts
* Current Directory: absolute path to `cw-migrations/passage` (pwd).

### Run migrations

After setting up everything as mentioned above; to migrate contract to new decommissioned code run `cw-migrations/decommission_all.sh`.

```bash
./decommission_all.sh
```

This triggers decommission of each contract mentioned in the `contracts.json` file sequentially.
