---
sidebar_position: 12
title: Run on a VPS
---
# 🚀 Run the Operator on a VPS
#### In this Guide:
1. Install dependencies
2. Install the `drosera-operator` CLI
3. Register your operator
4. Create db directory
5. Configure and Install the systemd service file
6. Enable and start the `drosera-operator` service
7. Configure the `ufw` firewall
8. Run the Delegation Client (Whitelisted Testnet Operators Only)

## Prequisites
- General linux systems knowledge
- General terminal knowledge
- General cloud networking knowledge

## Install dependencies
```console
sudo apt-get install -y curl clang libssl-dev tar ufw
```
- Currently we only officially support Ubuntu 22.04 and newer.  However, it is definitely possible to run drosera-operator on other hardware and OSes.  However, you may have other dependencies and installation steps specific to your OS.  

- On non debian systems, use the package manager of your OS to install dependencies.

- It is possible that your OS will have more dependencies what we have listed here.  You can use your package manager to install whatever missing packages you might need if your `drosera-operator` errors because of a missing package.

## Install the drosera-operator CLI
- First we need to install the `droserup` utility
```bash
curl -L https://app.drosera.io/install | bash
```
- This script installs the `droseraup` utility into your current user's home directory under a `.drosera` directory.  It also adds a line in the current user's shell profile file (e.g. `.bashrc`) that adds the `.drosera/bin` directory to the `$PATH` system variable.
- Follow the terminal prompt to bring the droseraup utility into the $PATH variable. 
```console
## Example terminal output:
Run 'source /home/user/.bashrc' or start a new terminal session to use droseraup.
```

- Next we will install the `drosera` and `drosera-operator` cli
```bash
droseraup
```
- This command installs the `latest` version of the `drosera` and `drosera-operator` cli in the home directory of the current user under a `.drosera` directory right alongside the `droseraup` utility.  If you want a specific version of the cli tools, you can run the droseraup command with a version:
```bash
droseraup -v v1.16.1
```

- Alternatively, (for automation, idempotency needs, and fewer possible failure points) you can install the pre-packaged binaries directly from the releases repository into any location you prefer (e.g. `/usr/bin/`).  Make sure to set `VERSION` variable to the version you are attempting to download.
```bash
mkdir -p /home/${USER}/.drosera/bin
VERSION="v1.16.2"
curl -LO "https://github.com/drosera-network/releases/releases/download/${VERSION}/drosera-operator-${VERSION}-x86_64-unknown-linux-gnu.tar.gz"
tar -xvf "drosera-operator-${VERSION}-x86_64-unknown-linux-gnu.tar.gz"
sudo cp drosera-operator /home/${USER}/.drosera/bin/
```

## Register your operator
- See [Registration documentation](./register.md) for concerns regarding what private key to use or not use.
```bash
drosera-operator register --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com --eth-private-key <<YOUR_ETH_PRIVATE_KEY_HERE>>
```

## Create db directory
- We want a persistent location that is accessible by the service runner.
- These permissions are specific to your use case, so we will make the service runnable by root and the directory accessible by root.  Adjust the permissions and the systemd user as needed.
```
sudo mkdir -p /var/lib/drosera-data
sudo chown -R root:root /var/lib/drosera-data
sudo chmod -R 700 /var/lib/drosera-data
```

## Configuring the systemd Service File
- This step is probably the one that is nearly impossible to fully cover in a guide.  The `drosera-operator` has many customizable features, and until you have determined your use case needs, it is impossible to make this guide fit all possible configurations.
- That said, we will give a good starting configuration with reasonable defaults for the Ethereum Holesky testnet.  Please refer to our [Run the Node](./run-operator.md) guide for all of the configurations, command line argument, and environment variable options and their effects on how the `drosera-operator` runs.
- Before running the command below, we will explain the environment variables and what they configure.  If you need an explanation of the anatomy of a systemd service file, this [DigitalOcean Guide](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files) will get you most of the way there.

    - `DRO_DB_FILE_PATH`: The path to the database file to use for persistence when not in dev mode
    - `DRO__DROSERA_ADDRESS`: The address of the main Drosera proxy contract to interact with
    - `DRO__LISTEN_ADDRESS`: The network interface to bind the Operators RPC and P2P server to
    - `DRO__ETH__CHAIN_ID`: The Ethereum chain id
    - `DRO__ETH__RPC_URL`: The node used for querying and sending transactions. You will want to set this to an Ethereum Holesky RPC that is not rate limited.  Usually public nodes have significant rate limits that will cause your operator to fail RPC calls to the chain.
    - `DRO__ETH__BACKUP_RPC_URL`: A backup Ethereum RPC if the primary RPC node becomes unresponsive. This arg is optional.  Again, this should also be a non rate-limited RPC
    - `DRO__ETH__PRIVATE_KEY`: CHANGE THIS VALUE BELOW. The private key used to sign transactions.  Please keep this secure.
    - `DRO__NETWORK__P2P_PORT`: The TCP port to bind the P2P server to
    - `DRO__NETWORK__EXTERNAL_P2P_ADDRESS`: CHANGE THIS VALUE BELOW. The external address to reach the Operator node at for p2p communications. This is required for the Operator to be discoverable by other nodes. The public address can either be an IP address or a domain name. If a domain name is used, the domain must resolve to the public IP address of the Operator.  It is important to note, that this is the public IPv4 address of your VPS.
    - `DRO__SERVER__PORT`: The TCP port to bind the rpc server to.  This port is the port that must be properly allowed through the firewall in order for liveness data to be visible on the frontend.

- It is also important to understand what the `ExecStart` directive is doing.
```
ExecStart=/home/user/.drosera/bin/drosera-operator node
```
- This start directive is telling systemd how to start the service.  In our case, we are giving it the path to the `drosera-operator` binary and the subcommand `node`.
- IMPORTANT: If you installed your `drosera-operator` binary into a different location, or your current username is not `user` you need to change the path to be the path of your `drosera-operator` binary location. You can figure out this information by running `whereis drosera-operator` in your terminal.
- Once you've made all of the configuration changes to your systemd service file below, you are ready to create a systemd service file in the `/etc/systemd/system/` directory with the name `drosera-operator.service`
```bash
sudo tee /etc/systemd/system/drosera-operator.service > /dev/null <<EOF

[Unit]
Description=Service for Drosera Operator
Requires=network.target
After=network.target

[Service]
Type=simple
Restart=always

Environment="DRO__DB_FILE_PATH=/var/lib/drosera-data/drosera.db"
Environment="DRO__DROSERA_ADDRESS=0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8"
Environment="DRO__LISTEN_ADDRESS=0.0.0.0"
Environment="DRO__ETH__CHAIN_ID=17000"
Environment="DRO__ETH__RPC_URL=https://ethereum-holesky-rpc.publicnode.com"
Environment="DRO__ETH__BACKUP_RPC_URL=https://1rpc.io/holesky"
Environment="DRO__ETH__PRIVATE_KEY=<<YOUR_ETH_PRIVATE_KEY_HERE>>"
Environment="DRO__NETWORK__P2P_PORT=31313"
Environment="DRO__NETWORK__EXTERNAL_P2P_ADDRESS=<<YOUR-PUBLIC-VPS-IP-ADDRESS>>"
Environment="DRO__SERVER__PORT=31314"

ExecStart=/home/${USER}/.drosera/bin/drosera-operator node

[Install]
WantedBy=multi-user.target
EOF
```

## Enable and start the drosera-operator service
- Load the systemd service file
```bash
sudo systemctl daemon-reload
```
- Start the `drosera-operator` service
```bash
sudo systemctl start drosera-operator.service
```
- Enable the `drosera-operator` service so it will restart on system reboot
```bash
sudo systemctl enable drosera-operator.service
```
- Confirm `drosera-operator` status
```bash
sudo systemctl status drosera-operator.service
```
- Follow logs
```bash
sudo journalctl -u drosera-operator.service -f
```
- Stop following logs
```
Ctrl+C
```
- NOTE: the `WARN drosera_services::network::service: Failed to gossip message: InsufficientPeers` warning can be ignored.
- If your `drosera-operator` is not opted into any traps, you will not see very many logs.  We will cover opting into traps in another section.

At this point, you can confirm that public RPC communication is properly configured on your drosera-operator with the following `curl` command.  Run this command from a terminal that is not on the same network as the VPS.

```bash
curl --location 'http://${YOUR_EXTERNAL_ADDRESS}:${SERVER_PORT}' \
--header 'Content-Type: application/json' \
--data '{
    "jsonrpc": "2.0",
    "method": "drosera_healthCheck",
    "params": [],
    "id": 1
}'
```
- In the command `${YOUR_EXTERNAL_ADDRESS}` should be the same as what you set for the value of `DRO__NETWORK__EXTERNAL_P2P_ADDRESS` in the service file.  And `${SERVER_PORT}` should be what you set for the value of `DRO__SERVER__PORT` in the service file.

## Configure the `ufw` firewall
- Finally, we need to secure the VPS with a software firewall. It should be noted that you can achieve similar security using your cloud provider's network firewall that is configured outside of the VPS.  Since we don't know what cloud provider you are using, we will demonstrate the firewall using `ufw` as our software firewall.
- Allow `ssh` traffic
```bash
sudo ufw allow ssh
sudo ufw allow 22
```

- Allow `drosera-operator` ports
```bash
sudo ufw allow 31313/tcp
sudo ufw allow 31314/tcp
```

- Enable the `ufw` firewall
```bash
sudo ufw enable
```
- After you have enabled the `ufw` firewall, you can again confirm RPC connectivity with your drosera-operator using the following `curl` command.  Run this command from a terminal that is not on the same network as the VPS.
```bash
curl --location 'http://${YOUR_EXTERNAL_ADDRESS}:${SERVER_PORT}' \
--header 'Content-Type: application/json' \
--data '{
    "jsonrpc": "2.0",
    "method": "drosera_healthCheck",
    "params": [],
    "id": 1
}'
```

# Whitelisted Testnet Operators Only

## Run the Delegation Client 
We have a closed set of whitelisted testnet operators that are running public traps.  This section is for you, using systemd and a service file on a cloud VPS.  The instructions for running the `drosera-delegation-client` are very similar to the instructions for running the `drosera-operator` as a systemd service, so we will spin through them pretty quickly without as much explanation of the configurations or possible scenarios you will encounter as we did in the `drosera-operator` section.

## Prequisites
- General linux systems knowledge
- General terminal knowledge
- General cloud networking knowledge

## Install dependencies
```console
sudo apt-get install -y curl clang libssl-dev tar ufw
```
## Install `drosera-delegation-client`

- You can install the pre-packaged binaries directly from the releases repository into any location you prefer (e.g. `/usr/bin/`).  Make sure to set `VERSION` variable to the version you are attempting to download.
```bash
VERSION="v1.16.2"
curl -LO "https://github.com/drosera-network/releases/releases/download/${VERSION}/drosera-delegation-client-${VERSION}-x86_64-unknown-linux-gnu.tar.gz"
tar -xvf "drosera-delegation-client-${VERSION}-x86_64-unknown-linux-gnu.tar.gz"
sudo cp drosera-delegation-client /home/${USER}/.drosera/bin/
```

## Configuring the systemd Service File
- Again, this is a service file with reasonable defaults, and the `drosera-delegation-client` is configured very similarly to the `drosera-operator`.
- There is one variable that is different in this example than the `drosera-operator`:
    - `DRO__DELEGATION_SERVER_URL`: The value for this variable is the location of the Drosera Delegation Server which aids in opting in testnet operators automatically to public traps.
- Please make sure to replace `<<YOUR_ETH_PRIVATE_KEY_HERE>>` with the same ethereum private key you put in the `drosera-operator` service file.
```bash
sudo tee /etc/systemd/system/drosera-delegation-client.service > /dev/null <<EOF
[Unit]
Description=Service for Drosera Delegation Client
Requires=network.target
After=network.target

[Service]
Type=simple
Restart=always

Environment="DRO__DELEGATION_SERVER_URL=https://delegation-server.testnet.drosera.io"
Environment="DRO__DROSERA_ADDRESS=0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8"
Environment="DRO__ETH__CHAIN_ID=17000"
Environment="DRO__ETH__RPC_URL=https://ethereum-holesky-rpc.publicnode.com"
Environment="DRO__ETH__PRIVATE_KEY=<<YOUR_ETH_PRIVATE_KEY_HERE>>"
Environment="DRO__NETWORK_HTTP_PORT=32324"
Environment="DRO__NETWORK__LISTEN__ADDRESS=0.0.0.0"

ExecStart=/home/${USER}/.drosera/bin/drosera-delegation-client 

[Install]
WantedBy=multi-user.target
EOF
```

## Enable and start the drosera-operator service
- Load the systemd service file and run the `drosera-delegation-client`
```bash
sudo systemctl daemon-reload
sudo systemctl start drosera-delegation-client.service
sudo systemctl enable drosera-delegation-client.service
sudo systemctl status drosera-delegation-client.service
```
- Follow logs
```bash
sudo journalctl -u drosera-delegation-client.service -f
```
- Stop following logs
```
Ctrl+C
```
- If your `drosera-delegation-client` is configured properly, you will see only this log, unless it finds a trap to opt into.
```
INFO drosera_delegation_client::delegation: Traps to opt into: []
```


## Configure the `ufw` firewall
- Finally, we need to allow one more port through our firewall
- Allow `ssh` traffic (if you haven't already)
```bash
sudo ufw allow ssh
sudo ufw allow 22
```

- Allow `drosera-delegation-client` ports
```bash
sudo ufw allow 32324/tcp
```

- Enable the `ufw` firewall 
```bash
sudo ufw enable
```
- Or if it was already enabled, reload the configuration
```bash
sudo ufw reload
```
- After you have enabled the `ufw` firewall, you should be completely setup as a testnet whitelisted operator.
