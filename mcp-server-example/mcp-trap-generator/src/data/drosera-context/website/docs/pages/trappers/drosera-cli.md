---
sidebar_position: 2
title: Drosera CLI
---

# Drosera CLI 🖥️

The Drosera CLI is a command line tool used to create, manage, and monitor Traps on the Drosera Network. It utilizes a configuration file to manage your Traps and their configurations. It can be installed by following the getting started guide [here](/trappers/getting-started#installing-droseraup).

## Configuration

### Drosera.toml

The `drosera.toml` file is used to configure the Drosera CLI. The file is used to define Drosera and chain connection info as well as the traps that are being managed and the response contracts that are triggered when a trap is triggered.

```toml
ethereum_rpc = "http://examplerpc.io"
drosera_rpc = "https://relayer.testnet.drosera.io"

[traps]

[traps.hello_world]
path = "out/HelloWorldTrap.sol/HelloWorldTrap.json"
response_contract = "0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8"
response_function = "pause(uint256)"
cooldown_period_blocks = 33
min_number_of_operators = 1
max_number_of_operators = 2
block_sample_size = 10
private_trap = false
whitelist = []
```

#### Connection Info

- `ethereum_rpc`: The ethereum RPC URL to send transactions with and read chain state. URL must be prepended with "http://". _Pointing to an ethereum archive node may be necessary for using the `dryrun` command historically_.
- `drosera_rpc`: The URL of the seed node you wish to use. You can find seed nodes hosted by the Drosera team [here](/deployments#seed-nodes). URL must be prepended with "http://"
- (Optional) `eth_chain_id`: The chain ID that corresponds to the `ethereum_rpc`. **If this field is not included, the chain ID will be determined for you**.
- (Optional) `drosera_address`: The address of the core Drosera contract on-chain. **If this field is not included, the address will be determined for you**.

#### Trap(s) Info

- `traps`: The section where all the traps are defined.
- `traps.<name>`: The name of the trap.
- `path`: The path to the trap's JSON file that contains the ABI and bytecode.
- `response_contract`: The address of the contract to call when a response is triggered.
- `response_function`: The function signature to call on the response contract.
- `cooldown_period_blocks`: The number of blocks to wait before triggering another response.
- `min_number_of_operators`: The minimum number of operators to execute the trap and trigger a response.
- `max_number_of_operators`: The maximum number of operators that can opt into the trap.
- `block_sample_size`: The number of blocks required by the `shouldRespond` function to make a decision.
- `private_trap`: A boolean value that determines if the trap is private or public. Private traps can only be opted-into by trap-whitelisted operators. Default is `false`.
- `whitelist`: A list of operator addresses that are allowed to opt into the trap. ["0x..", "0x.."].

### Private Key

Most CLI commands require a private key as they are executing transactions. Your private key can be set as either an environment variable or as a CLI argument in applicable commands. Setting as an environment variable is the easiest method.

Example

```bash
export DROSERA_PRIVATE_KEY=ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

### CLI Arguments

|         Argument         |                 Default                 |                                Description                                |
| :----------------------: | :-------------------------------------: | :-----------------------------------------------------------------------: |
|   `--config-path (-c)`   | Looks in current and parent directories |                     The path to the drosera.toml file                     |
| `--non-interactive (-n)` |                  False                  | Determines if a user prompt is required before creating or updating traps |

### Commands

The CLI command options can be configured using CLI arguments, the drosera.toml config file, or with environment variables. A combination of either can also be used. The order of precedence is as follows:

- Command line arguments
- TOML configuration file `./drosera.toml`
- Environment variables / .env file

NOTE: Make sure to run the CLI from the same directory as the `drosera.toml` file. The `DROSERA_PRIVATE_KEY` environment variable is required to deploy or update a trap.

#### `config`

Displays the current configuration file.

#### `plan`

Displays the traps that will be created or updated based on the configuration file.

##### Args

|      Argument       |            Default            |                           Description                           |
| :-----------------: | :---------------------------: | :-------------------------------------------------------------: |
|   `--eth-rpc-url`   |                               |       The node used for querying and sending transactions       |
| `--drosera-rpc-url` |                               |      The url of the seed node to send the trap bytecode to      |
|  `--eth-chain-id`   | derived from the ethereum rpc |                          The chain id                           |
|   `--private-key`   |                               |            The private key used to sign transactions            |
| `--drosera-address` |     derived from chain id     | The address of the main Drosera proxy contract to interact with |

#### `dryrun`

Runs all traps in the `drosera.toml` file on a local ad-hoc operator, testing the `collect` and `shouldRespond` functions. This is also run for you automatically in the `apply` command. Additionally you can theory-craft by testing traps historically.

:::info

- Note: If you are testing traps historically with `--block-number`, the `ethereum_rpc` you are using must have that block. If the specified block number is far enough back you will need to make sure you are pointing to an ethereum archive node.
  :::

##### Args

|      Argument       |            Default            |                                        Description                                         |
| :-----------------: | :---------------------------: | :----------------------------------------------------------------------------------------: |
|   `--eth-rpc-url`   |                               |                    The node used for querying and sending transactions                     |
|  `--eth-chain-id`   | derived from the ethereum rpc |                                        The chain id                                        |
| `--drosera-address` |     derived from chain id     |              The address of the main Drosera proxy contract to interact with               |
|  `--block-number`   |     current block number      | The block number to perform the dryrun on. This allows historical testing of trap behavior |

#### `apply`

Creates or updates traps based on the configuration file. If an address field is specified in the configuration file, the trap is updated. If the address field is not specified, the trap is created and the address of the deployed Trap Config address is set in the config file by the CLI.

##### Args

|      Argument       |            Default            |                                              Description                                               |
| :-----------------: | :---------------------------: | :----------------------------------------------------------------------------------------------------: |
|   `--eth-rpc-url`   |                               |                          The node used for querying and sending transactions                           |
| `--drosera-rpc-url` |                               |                         The url of the seed node to send the trap bytecode to                          |
|  `--eth-chain-id`   | derived from the ethereum rpc |                                              The chain id                                              |
|   `--private-key`   |                               |                               The private key used to sign transactions                                |
| `--drosera-address` |     derived from chain id     |                    The address of the main Drosera proxy contract to interact with                     |
| `--non-interactive` |             false             | Normally the command will prompt you for final approval before executing. This will bypass that check. |

#### `hydrate`

Hydrate the specified trap. This is how you incentivize operators to monitor your trap. This sends DRO to the traps' `trap_rewards` contract.

##### Args

|      Argument       |            Default            |                                                                                     Description                                                                                     |
| :-----------------: | :---------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|   `--eth-rpc-url`   |                               |                                                                 The node used for querying and sending transactions                                                                 |
| `--drosera-rpc-url` |                               |                                                                The url of the seed node to send the trap bytecode to                                                                |
|  `--eth-chain-id`   | derived from the ethereum rpc |                                                                                    The chain id                                                                                     |
|   `--private-key`   |                               |                                                                      The private key used to sign transactions                                                                      |
| `--drosera-address` |     derived from chain id     |                                                           The address of the main Drosera proxy contract to interact with                                                           |
| `--non-interactive` |             false             |                                       Normally the command will prompt you for final approval before executing. This will bypass that check.                                        |
|  `--trap-address`   |                               | The address of the on-chain trap (config) to hydrate. This is the address you see output when you create a new trap or that you will have for your trap in your `drosera.toml` file |
|   `--dro-amount`    |                               |                                     The amount of DRO you want to hydrate your trap with. Amount is expected in human form (not on-chain form)                                      |

#### `bloomboost`

Bloom boost the specified trap. This is how you boost a trap's emergency response execution with ETH to entice block builders to include the tx in the mempool. This sends ETH to the traps' `trap_rewards` contract.

##### Args

|      Argument       |            Default            |                                                                                    Description                                                                                    |
| :-----------------: | :---------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|   `--eth-rpc-url`   |                               |                                                                The node used for querying and sending transactions                                                                |
| `--drosera-rpc-url` |                               |                                                               The url of the seed node to send the trap bytecode to                                                               |
|  `--eth-chain-id`   | derived from the ethereum rpc |                                                                                   The chain id                                                                                    |
|   `--private-key`   |                               |                                                                     The private key used to sign transactions                                                                     |
| `--drosera-address` |     derived from chain id     |                                                          The address of the main Drosera proxy contract to interact with                                                          |
| `--non-interactive` |             false             |                                      Normally the command will prompt you for final approval before executing. This will bypass that check.                                       |
|  `--trap-address`   |                               | The address of the on-chain trap (config) to boost. This is the address you see output when you create a new trap or that you will have for your trap in your `drosera.toml` file |
|   `--eth-amount`    |                               |                                             The amount of ETH you want to boost your trap with. Amount is expected in ETHER (not WEI)                                             |

#### `dispute`

Dispute an optimistic claim using a ZK proof. A Bonsai API Key and Bonsai URL are required, otherwise local proving can be performed if your machine has docker and x86_64 architecture.

```bash
export BONSAI_API_KEY=
export BONSAI_API_URL="https://api.bonsai.xyz/"
```

##### Args

|      Argument       |            Default            |                                                                                                          Description                                                                                                           |
| :-----------------: | :---------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|   `--eth-rpc-url`   |                               |                                                                                      The node used for querying and sending transactions                                                                                       |
| `--drosera-rpc-url` |                               |                                                                                     The url of the seed node to send the trap bytecode to                                                                                      |
|  `--eth-chain-id`   | derived from the ethereum rpc |                                                                                                          The chain id                                                                                                          |
|   `--private-key`   |                               |                                                                                           The private key used to sign transactions                                                                                            |
| `--drosera-address` |     derived from chain id     |                                                                                The address of the main Drosera proxy contract to interact with                                                                                 |
| `--non-interactive` |             false             |                                                             Normally the command will prompt you for final approval before executing. This will bypass that check.                                                             |
|  `--trap-address`   |                               | The address of the on-chain trap (config) to dispute. This is the `address` you see output when you create a new trap, or that you will have for your trap in your drosera.toml file, or that you will see on the drosera dapp |
|  `--block-number`   |                               |                                                                                            The block number to perform a dispute on                                                                                            |

### `zkclaim`

Perform ZK incident response for a trap. A Bonsai API Key and Bonsai URL are required, otherwise local proving can be performed if your machine has docker and x86_64 architecture.

```bash
export BONSAI_API_KEY=
export BONSAI_API_URL="https://api.bonsai.xyz/"
```

#### Args

|      Argument       |            Default            |                                                                                                         Description                                                                                                          |
| :-----------------: | :---------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|   `--eth-rpc-url`   |                               |                                                                                     The node used for querying and sending transactions                                                                                      |
| `--drosera-rpc-url` |                               |                                                                                    The url of the seed node to send the trap bytecode to                                                                                     |
|  `--eth-chain-id`   | derived from the ethereum rpc |                                                                                                         The chain id                                                                                                         |
|   `--private-key`   |                               |                                                                                          The private key used to sign transactions                                                                                           |
| `--drosera-address` |     derived from chain id     |                                                                               The address of the main Drosera proxy contract to interact with                                                                                |
| `--non-interactive` |             false             |                                                            Normally the command will prompt you for final approval before executing. This will bypass that check.                                                            |
|  `--trap-address`   |                               | The address of the on-chain trap (config) to claim. This is the `address` you see output when you create a new trap, or that you will have for your trap in your drosera.toml file, or that you will see on the drosera dapp |
|  `--block-number`   |                               |                                                                                              The block number to perform claim                                                                                               |

#### `kick-operator`

Kick one or more operators from a trap so they are no longer opted in. If you do not also remove the operator from the trap's whitelist, they will simply be able to opt back in.

##### Args

|      Argument       |            Default            |                                                                                                                Description                                                                                                                 |
| :-----------------: | :---------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|   `--eth-rpc-url`   |                               |                                                                                            The node used for querying and sending transactions                                                                                             |
| `--drosera-rpc-url` |                               |                                                                                           The url of the seed node to send the trap bytecode to                                                                                            |
|  `--eth-chain-id`   | derived from the ethereum rpc |                                                                                                                The chain id                                                                                                                |
|   `--private-key`   |                               |                                                                                                 The private key used to sign transactions                                                                                                  |
| `--drosera-address` |     derived from chain id     |                                                                                      The address of the main Drosera proxy contract to interact with                                                                                       |
| `--non-interactive` |             false             |                                                                   Normally the command will prompt you for final approval before executing. This will bypass that check.                                                                   |
|  `--trap-address`   |                               | The address of the on-chain trap (config) to kick operators from. This is the `address` you see output when you create a new trap, or that you will have for your trap in your drosera.toml file, or that you will see on the drosera dapp |
|    `--operators`    |                               |                                  The address of one or more operators to kick from the given trap. Ex: --operators 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 0xa85233C63b9Ee964Add6F2cffe00Fd84eb32338f                                   |

#### `set-bloomboost-limit`

Update the percentage of a trap's ETH balance that can be used for bloom boosting a response action. Default value is 0 bps (0%).

##### Args

|      Argument       |            Default            |                                                                                                                Description                                                                                                                 |
| :-----------------: | :---------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|   `--eth-rpc-url`   |                               |                                                                                            The node used for querying and sending transactions                                                                                             |
| `--drosera-rpc-url` |                               |                                                                                           The url of the seed node to send the trap bytecode to                                                                                            |
|  `--eth-chain-id`   | derived from the ethereum rpc |                                                                                                                The chain id                                                                                                                |
|   `--private-key`   |                               |                                                                                                 The private key used to sign transactions                                                                                                  |
| `--drosera-address` |     derived from chain id     |                                                                                      The address of the main Drosera proxy contract to interact with                                                                                       |
| `--non-interactive` |             false             |                                                                   Normally the command will prompt you for final approval before executing. This will bypass that check.                                                                   |
|  `--trap-address`   |                               | The address of the on-chain trap (config) to kick operators from. This is the `address` you see output when you create a new trap, or that you will have for your trap in your drosera.toml file, or that you will see on the drosera dapp |
|      `--limit`      |                               |                                                           The new bloom boost limit as a percentage in basis points i.e 10000 bps = 100%, 3100 bps = 31%. Default is 0 bps (0%)                                                            |

#### `liveness`

Get liveness data for a trap, showing recent results computed by opted in operators.

##### Args

|      Argument       |            Default            |                                                                                                                   Description                                                                                                                    |
| :-----------------: | :---------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|   `--eth-rpc-url`   |                               |                                                                                               The node used for querying and sending transactions                                                                                                |
| `--drosera-rpc-url` |                               |                                                                                              The url of the seed node to send the trap bytecode to                                                                                               |
|  `--eth-chain-id`   | derived from the ethereum rpc |                                                                                                                   The chain id                                                                                                                   |
|   `--private-key`   |                               |                                                                                                    The private key used to sign transactions                                                                                                     |
| `--drosera-address` |     derived from chain id     |                                                                                         The address of the main Drosera proxy contract to interact with                                                                                          |
|  `--trap-address`   |                               | The address of the on-chain trap (config) to query for liveness data. This is the `address` you see output when you create a new trap, or that you will have for your trap in your `drosera.toml` file, or that you will see on the drosera dapp |
|  `--block-number`   |   current block number - 1    |             (optional) Specifies at which historical block to fetch trap results from. Historical data is only maintained for a limited period of time so recent blocks may have data, but further blocks data may not exist anymore             |

#### `recover`

Reconstruct a trapper's `drosera.toml` from on-chain state data, using the provided private key.

##### Args

|      Argument       |            Default            |                                                                                                                   Description                                                                                                                    |
| :-----------------: | :---------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|   `--eth-rpc-url`   |                               |                                                                                               The node used for querying and sending transactions                                                                                                |
|   `--private-key`   |                               |                                                                                                    The private key used to find trap data                                                                                                        |
|  `--eth-chain-id`   | derived from the ethereum rpc |                                                                                                        (Optional) The chain id                                                                                                                   |
| `--drosera-address` |     derived from chain id     |                                                                              (Optional) The address of the main Drosera proxy contract to interact with                                                                                          |
|   `--write-path`    |   ./recovered_drosera.toml    |             (Optional) The path to write the recovered drosera.toml file to, ex `--write-path /path/to/drosera.toml`. If not provided, the CLI will write the file to the current working directory and call it recovered_drosera.toml.          |

