---
sidebar_position: 7
title: Testnet Guide
---

# Testnet Guide 🧪

Drosera operates on the Holesky testnet. This guide will walk through the steps to get your Operator node onboarded into Drosera's Testnet.

It is recommended a new ECDSA key-pair is generated for the Operator node and is funded with testnet ETH. You can obtain testnet ETH from the following Holesky Testnet Faucets:

- [Covalent](https://goldrush.dev/faucet/#form)
- [Infura](https://www.infura.io/faucet/sepolia)
- [Quicknode](https://faucet.quicknode.com/ethereum/sepolia)
- [Google](https://cloud.google.com/application/web3/faucet/ethereum/holesky)

1. Download and install the latest release of the Drosera Operator Node by following the instructions in the [Installation](/operators/installation) guide.
2. Download and install the latest release of the Drosera Delegation Client. The Delegation client is used to automatically opt your Operator node into Traps.

```bash
cd ~
curl -LO https://github.com/drosera-network/releases/releases/download/v1.0.2/drosera-delegation-client-v1.0.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-delegation-client-v1.0.2-x86_64-unknown-linux-gnu.tar.gz
```

More information on the Delegation Client can be found in the [Delegation Client](/operators/testnet-guide#delegation-client) section.

3. Configure the Operator node by following the instructions in the [Run the Node](/operators/run-operator) guide. Testnet Operators will need to use an RPC endpoint for a Holesky Ethereum node.
4. Register your Operator node by following the instructions in the [Register](/operators/register) guide.
5. Start the Operator node by running the following command:

```bash
drosera-operator node --eth-rpc-url <rpc-url> --eth-private-key <private-key> --network-public-address <public-address>
```

6. Start the Delegation Client by running the following command:

```bash
./drosera-delegation-client --eth-rpc-url <eth-rpc-url> --eth-private-key <eth-private-key> --delegation-server-url https://delegation-server.testnet.drosera.io
```

> Note: The same private key used for the Operator node must be used for the Delegation Client. The Delegation Client will automatically opt your Operator node into Traps.

7. That's it! Your Operator node is now onboarded into Drosera's Testnet. You can monitor the execution of Traps by checking the logs of the Operator node.

### Both the `drosera-operator` and `drosera-delegation-client` can also be run as docker containers.

[drosera-operator](https://github.com/orgs/drosera-network/packages/container/package/drosera-operator): `ghcr.io/drosera-network/drosera-operator:latest`

[drosera-delegation-client](https://github.com/orgs/drosera-network/packages/container/package/drosera-delegation-client): `ghcr.io/drosera-network/drosera-delegation-client:latest`

## Delegation Client

The Delegation Client is a tool used to automatically opt your Operator node into Traps. The Delegation Client is a separate application from the Operator node and requires the same private key used for the Operator node.

It works by querying Drosera's Delegation server which delegates traps to registered Operators as they are created. It is a convenience service that is only used in the testnet environment because it is expected for Operators to manually opt into Traps in a mainnet environment that is based on real value incentives.

### Configuration

The Delegation Client can be configured using CLI arguments, a toml config file, or with environment variables. A combination of either can also be used. The order of precedence is as follows:

- Command line arguments
- TOML configuration file `./drosera.toml`
- Environment variables / .env file

#### CLI Arguments

|           Argument            |       Default        |                                             Description                                              |
| :---------------------------: | :------------------: | :--------------------------------------------------------------------------------------------------: |
|        `--eth-rpc-url`        |                      |                    The Ethereum node used for RPC calls and sending transactions                     |
|       `--eth-chain-id`        | derived from eth rpc |                                        The Ethereum chain id                                         |
|      `--eth-private-key`      |                      |                              The private key used to sign transactions                               |
|      `--drosera-address`      | derived from eth rpc |                   The address of the main Drosera proxy contract to interact with                    |
|   `--delegation-server-url`   |                      |                            The URL of the delegation server to connect to                            |
| `--block-polling-interval-ms` |        `1000`        |                  The number of milliseconds to wait between polling for new blocks                   |
|         `--log-level`         |        `info`        |                                 The log level for the Operator Node                                  |
|        `--log-format`         |        `full`        |                                 The log format for the Operator Node                                 |
|        `--log-output`         |       `stdout`       |                                 The log output for the Operator Node                                 |
|             `-v`              |                      |  The verbosity level to use for instrumentation. -v = warn, -vv = info, -vvv = debug, -vvvv = trace  |
|   `--otel-export-endpoint`    |         `""`         |               The OpenTelemetry Collector endpoint to send metrics and trace data too                |
|   `--otel-export-metadata`    |         `{}`         | The OpenTelemetry Collector metadata to send with metrics and trace data. e.g. Authorization Headers |
|  `--network-listen-address`   |      `0.0.0.0`       |      The network interface to bind the HTTP server to. Server is only used for liveness checks       |
|     `--network-http-port`     |       `32324`        |           The port to bind the HTTP server to (server used for liveness checks /liveness)            |
|           `--help`            |                      |                                        Display the help menu                                         |
|          `--version`          |                      |                             Display the version of the Delegation Client                             |

#### TOML Configuration

The Drosera Delegation Client can be configured using a TOML configuration file. The configuration file should be named `drosera.toml` and placed in the root directory of the Delegation Client. The configuration file should be formatted as follows:

Note: Update the toml with your own values. This is an example configuration.

```toml
drosera_address = 0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8
block_polling_interval_ms = 1000
delegation_server_url = "https://delegation-server.testnet.drosera.io"

[eth]
private_key = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
chain_id = 17000
rpc_url = http://localhost:8545

[network]
listen_address = 0.0.0.0
http_port = 32324

[instrumentation]
log_level = "info"
log_format = "full"
log_out = "stdout"
otel_export_endpoint = ""
otel_export_metadata = {}
```

#### Environment Variables

Example configuration:

```bash
export DRO__DROSERA_ADDRESS=0x
export DRO__BLOCK_POLLING_INTERVAL_MS=1000
export DRO__ETH__RPC_URL=
export DRO__ETH__CHAIN_ID=17000
export DRO__ETH__PRIVATE_KEY=0x
export DRO__NETWORK__HTTP_PORT=32324
export DRO__INSTRUMENTATION__LOG_LEVEL=info
```
