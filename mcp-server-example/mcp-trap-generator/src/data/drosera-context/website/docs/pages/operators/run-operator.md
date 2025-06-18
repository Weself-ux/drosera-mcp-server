---
sidebar_position: 3
title: Run the Node
---

# Run the Drosera Operator Node 💻

Running the Drosera Operator Node is a simple process. This guide will walk you through the steps to run the Operator Node, enabling you to begin executing Traps and earning rewards.

The Operator Node can quickly be started using the following command:

```bash
drosera-operator node
```



:::note
Access to an EOA private key is required as of now. Remoting signing via AWS KMS and GCP will be supported in the future.
:::

If the Operator Node is configured correctly, you should see the following output:

```bash
INFO drosera_operator::node: Operator Node successfully spawned!
```

## Configuration

The Operator Node can be configured using CLI arguments, a toml config file, or with environment variables. A combination of either can also be used. The order of precedence is as follows:

- Command line arguments
- TOML configuration file `./drosera.toml`
- Environment variables / .env file

### CLI Arguments
| Argument | Default | Description |
| :---: | :---: | :---: |
| `--eth-rpc-url`  | | The node used for querying and sending transactions |
| `--eth-backup-rpc-url`  | | A backup Ethereum RPC if the primary RPC node becomes unresponsive. This arg is optional |
| `--eth-chain-id` | derived from eth rpc | The chain id |
| `--eth-private-key` | | The private key used to sign transactions |
| `--drosera-address` | derived from chain id | The address of the main Drosera proxy contract to interact with |
| `--gas-reimbursement-required` | false | Whether or not gas reimbursement is required to submit a claim. Omitting this flag will default to false. |
| `--db-file-path` | `./data/drosera.db` | The path to the database file to use for persistence when not in dev mode |
| `--dev-mode` | `false` | Runs the Operator node without persisting data |
| `--block-polling-interval-ms` | `1000` | The number of milliseconds to wait between polling for new blocks |
| `--disable-dnr-confirmation` | false |  "Disables the DNR confirmation. Only set this if you are running this node behind a NAT, and you are receiving a 'Failed to confirm DNR' error message. Verify the public address setting is correct and any firewall walls are opened for the configured ports before turning this setting on.|
| `--listen-address` | `0.0.0.0` | The network interface to bind the Operators RPC and P2P server to |
| `--log-level` | `info` | The log level for the Operator Node (info, warn, error, trace, debug). You can also specify directives similar to the `RUST_LOG` env variable. e.g. `"info,drosera_services::network::p2p=debug"`. |
| `--log-format` | `full` | The log format for the Operator Node (full, compact, pretty, json) |
| `--log-output` | `stdout` | The log output for the Operator Node (stdout, file) |
| `-v` | | The verbosity level to use for instrumentation. -v = warn, -vv = info, -vvv = debug, -vvvv = trace |
| `--otel-export-endpoint` | `""` | The OpenTelemetry Collector endpoint to send metrics and trace data too |
| `--otel-export-metadata` | `{}` | The OpenTelemetry Collector metadata to send with metrics and trace data. e.g. Authorization Headers |
| `--otel-resource-attributes` | `""` | Add resource attribute labels to all collected OpenTelemetry metrics, traces and logs. e.g. `"operator_address=0x530719E8fe572C909945Deb045e491865FF2bab0,operator_name=cobra"` |
| `--network-external-p2p-address` | | The external address to reach the Operator node at for p2p communications |
| `--network-external-rpc-address` | `${network-external-p2p-address}`| The external address to reach the Operator node's rpc server. Useful for proxies. Default is the network external p2p address. If provided and starts with either http or https, the value will be used as is by the seed node to retrieve liveness data. Otherwise, if a dns or ip is provided without a protocol, http is assumed and the server port will be appended. |
| `--network-p2p-port` | `31313` | The TCP port to bind the P2P server to |
| `--network-secret-key` | `--eth-private-key` | The secret key used to sign messages sent over the network and generating a peer id |
| `--server-port` | `31314` | The TCP port to bind the rpc server to |
| `--server-concurrency-limit` | `100` | The maximum number of concurrent requests the RPC server can handle |
| `--server-connection-limit` | `500` | The maximum number of concurrent connections the RPC server can handle |
| `--server-requests-per-second ` | `10` | The maximum number of requests per second the RPC server accepts before rate limiting. Only applicable if rate limit by ip is turned on. |
| `--server-rate-limit-by-ip` | `true` | Enable rate limiting by IP address |
| `--server-burst-size` | `10` | The maximum number of requests that can be bursted before rate limiting within the requests per second window. Only applicable if rate limit by ip is turned on. |
| `--help` | | Display the help menu |
| `--version` | | Display the version of the Operator Node |

The `--network-external-p2p-address` is required for the Operator to be discoverable by other nodes. The public address can either be an IP address or a domain name. If a domain name is used, the domain must resolve to the public IP address of the Operator.

### TOML Configuration

The Operator Node can be configured using a TOML configuration file. The configuration file should be named `drosera.toml` and placed in the root directory of the Operator Node. The configuration file should be formatted as follows:

```toml
db_file_path = "./data/drosera.db"
block_polling_interval_ms = 1000
dev_mode = false
listen_address = "127.0.0.1"

[eth]
rpc_url = "http://localhost:8545"
backup_rpc_url = "http://localhost:8546"

[network]
p2p_port = 31313
secret_key = "" # Required, provide your own
external_p2p_address = "" # Required, provide your own
external_rpc_address = "" # Optional if different from external_p2p_address

[server]
port = 31314
concurrency_limit = 100
connection_limit = 500
requests_per_second = 10
rate_limit_by_ip = false
burst_size = 10

[instrumentation]
log_level = "info"
log_format = "full"
log_out = "stdout"
# Requires monitoring setup running. Check the Operator "Monitoring" section of the docs
# otel_export_endpoint = "http://localhost:4317"
# otel_export_metadata = { authorization = "Basic ..." }
# otel_resource_attributes = { operator_address = "0x530719E8fe572C909945Deb045e491865FF2bab0", operator_name = "cobra" }
```

### Environment Variables

All of the CLI arguments can be set as environment variables. The environment variables should be prefixed with `DRO__` and use uppercase letters. For example, the `--eth-rpc-url` argument would be set as `DRO__ETH__RPC_URL`. The `__` indicates a new level in the name spacing.

Example configuration:

```bash
export DRO__ETH__PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export DRO__ETH__RPC_URL=http://localhost:8545
export DRO__ETH__BACKUP_RPC_URL=http://localhost:8546
export DRO__DB_FILE_PATH=./data/drosera.db
export DRO__BLOCK_POLLING_INTERVAL_MS=1000
export DRO__SERVER__PORT=31314
export DRO__NETWORK__P2P_PORT=31313
export DRO__INSTRUMENTATION__LOG_LEVEL=info
export DRO__INSTRUMENTATION__OTEL_EXPORT_ENDPOINT=http://localhost:4317
```

### Private Key

The operators `private_key` that is actually used for signing ethereum transactions, is not allowed in the `drosera.toml` file for security reasons. It can be set as an environment variable or passed as a CLI argument in applicable commands. Setting as an environment variable is the easiest method.
