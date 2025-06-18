---
sidebar_position: 13
title: Run with Docker
---
# 🚀 Run the Operator with Docker

#### In this Guide:
1. Install dependencies
2. Register your operator
3. Create db directory
4. Configure and Install Docker Compose files
5. Start the drosera-operator docker compose service
6. Configure the `ufw` firewall
7. Add the Delegation Client (Whitelisted Testnet Operators Only)

## Prerequisites

- General systems knowledge
- General terminal knowledge
- General cloud networking knowledge

## Install dependencies

```console
sudo apt-get install -y ufw
```
- Follow the [docker installation](https://docs.docker.com/engine/install/) guide for your OS.
- Add current user to the docker group
```bash
sudo usermod -aG docker $USER
newgrp docker
```
## Register your operator
- See [Registration documentation](./register.md) for concerns regarding what private key to use or not use.
```bash
docker run ghcr.io/drosera-network/drosera-operator:latest register --eth-rpc-url https://ethereum-holesky-rpc.publicnode.com --eth-private-key <<YOUR_ETH_PRIVATE_KEY_HERE>>
```

## Create db directory
- We want a persistent location that is accessible by the service runner.
- These permissions are specific to your use case, so we will make the service runnable by root and the directory accessible by root.  Adjust the permissions and the systemd user as needed.
```
sudo mkdir -p /var/lib/drosera-data
sudo chown -R root:root /var/lib/drosera-data
sudo chmod -R 700 /var/lib/drosera-data
```

## Configure and Install Docker Compose files
- This step is probably the one that is nearly impossible to fully cover in a guide.  The `drosera-operator` has many customizable features, and until you have determined your use case needs, it is impossible to make this guide fit all possible configurations.
- That said, we will give a good starting configuration with reasonable defaults for the Ethereum Holesky testnet.  Please refer to our [Run the Node](./run-operator.md) guide for all of the configurations, command line argument, and environment variable options and their effects on how the `drosera-operator` runs.
- Before running the command below, we will explain the environment variables and what they configure.  If you need an explanation of the anatomy of a `docker-compose.yml` file, [Docker's documentation](https://docs.docker.com/compose/) will get you there.

    - `DRO_DB_FILE_PATH`: The path to the database file to use for persistence when not in dev mode
    - `DRO__DROSERA_ADDRESS`: The address of the main Drosera proxy contract to interact with
    - `DRO__LISTEN_ADDRESS`: The network interface to bind the Operators RPC and P2P server to
    - `DRO__DISABLE_DNR_CONFIRMATION`: Disables the DNR confirmation. Only set this if you are running this node behind a NAT, and you are receiving a 'Failed to confirm DNR' error message. Verify the public address setting is correct and any firewall walls are opened for the configured ports before turning this setting on.
    - `DRO__ETH__CHAIN_ID`: The Ethereum chain id
    - `DRO__ETH__RPC_URL`: The node used for querying and sending transactions. You will want to set this to an Ethereum Holesky RPC that is not rate limited.  Usually public nodes have significant rate limits that will cause your operator to fail RPC calls to the chain.
    - `DRO__ETH__BACKUP_RPC_URL`: A backup Ethereum RPC if the primary RPC node becomes unresponsive. This arg is optional.  Again, this should also be a non rate-limited RPC
    - `DRO__ETH__PRIVATE_KEY`:  The private key used to sign transactions.  Please keep this secure.
    - `DRO__NETWORK__P2P_PORT`: The TCP port to bind the P2P server to
    - `DRO__NETWORK__EXTERNAL_P2P_ADDRESS`: The external address to reach the Operator node at for p2p communications. This is required for the Operator to be discoverable by other nodes. The public address can either be an IP address or a domain name. If a domain name is used, the domain must resolve to the public IP address of the Operator.  It is important to note, that this is the public IPv4 address of your VPS.
    - `DRO__SERVER__PORT`: The TCP port to bind the rpc server to.  This port is the port that must be properly allowed through the firewall in order for liveness data to be visible on the frontend.
- At this point you're ready to run the command below.  A good process is to copy this command into a text editor in order to replace `<<YOUR_ETH_PRIVATE_KEY_HERE>>` and `<<YOUR_PUBLIC_VPS_IP_ADDRESS>>` with the actual values.  A more secure way of doing this would be to create the `.env` file in the `drosera-operator` directory and edit it with a terminal text editor like nano or vim.  You can also run `history -c` in your terminal session after you're done, to clear the current terminal history so that the secrets don't show up.  Please don't forget to update the version to the most recent version, which can be found in our [Releases Repo](https://github.com/drosera-network/releases).
```bash
mkdir drosera-operator
cd drosera-operator
tee .env > /dev/null <<EOF
VERSION=v1.17.2
ETH_PRIVATE_KEY=<<YOUR_ETH_PRIVATE_KEY_HERE>>
VPS_PUBLIC_IP=<<YOUR_PUBLIC_VPS_IP_ADDRESS>>
DRO__NETWORK__P2P_PORT=31313
DRO__SERVER__PORT=31314
EOF
tee docker-compose.yml > /dev/null <<'EOF' 
version: '3'
services:
  drosera-operator:
    image: ghcr.io/drosera-network/drosera-operator:${VERSION}
    container_name: drosera-operator
    network_mode: host
    environment:
      - DRO__DB_FILE_PATH=/data/drosera.db
      - DRO__DROSERA_ADDRESS=0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8
      - DRO__LISTEN_ADDRESS=0.0.0.0
      - DRO__DISABLE_DNR_CONFIRMATION=true
      - DRO__ETH__CHAIN_ID=17000
      - DRO__ETH__RPC_URL=https://ethereum-holesky-rpc.publicnode.com
      - DRO__ETH__BACKUP_RPC_URL=https://1rpc.io/holesky
      - DRO__ETH__PRIVATE_KEY=${ETH_PRIVATE_KEY}
      - DRO__NETWORK__P2P_PORT=${DRO__NETWORK__P2P_PORT}$
      - DRO__NETWORK__EXTERNAL_P2P_ADDRESS=${VPS_PUBLIC_IP}
      - DRO__SERVER__PORT=${DRO__SERVER__PORT}
    volumes:
      - /var/lib/drosera-data:/data
    command: ["node"]
    restart: always
EOF
```

## Start the drosera-operator docker compose service
- Start the docker compose service

```bash
docker compose up -d
```

- Check logs:
```bash
docker compose logs -f
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

## Securing your operator
Since we are using docker, ufw is not a compatible software firewall.  Because of the Docker networking, any incoming traffic will not hit network firewall at all.   We recommend securing the operator node with a firewall external to the vm.  Something like an AWS VPC firewall, or a GCP Compute Firewall would be a better way of closing off all access to this machine except for the ports needed for the operator to run and ssh access.  Please see the cloud provider firewall documentation for setting up your cloud firewall.

- After you have enabled the network firewall, you can again confirm RPC connectivity with your drosera-operator using the following `curl` command.  Run this command from a terminal that is not on the same network as the VPS.
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

## Prerequisites
- General systems knowledge
- General terminal knowledge
- General cloud networking knowledge
- [Previous `drosera-operator` instructions for docker](#in-this-guide)

#### Configuring the docker-compose.yml file
- Again, this is a docker-compose.yml file with reasonable defaults, and the `drosera-delegation-client` is configured very similarly to the `drosera-operator`. Please don't forget to update the version to the most recent version, which can be found in our [Releases Repo](https://github.com/drosera-network/releases).
- There is one variable that is different in this example than the `drosera-operator`:
    - `DRO__DELEGATION_SERVER_URL`: The value for this variable is the location of the Drosera Delegation Server which aids in opting in testnet operators automatically to public traps.
```bash
tee .env > /dev/null <<EOF 
VERSION=v1.17.2
ETH_PRIVATE_KEY=<<YOUR_ETH_PRIVATE_KEY_HERE>>
VPS_PUBLIC_IP=<<YOUR_PUBLIC_VPS_IP_ADDRESS>>
DRO__NETWORK__P2P_PORT=31313
DRO__SERVER__PORT=31314
DRO__NETWORK__HTTP_PORT=32324
EOF
tee docker-compose.yml > /dev/null <<'EOF' 
version: '3'
services:
  drosera-operator:
    image: ghcr.io/drosera-network/drosera-operator:${VERSION}
    container_name: drosera-operator
    network_mode: host
    environment:
      - DRO__DB_FILE_PATH=/data/drosera.db
      - DRO__DROSERA_ADDRESS=0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8
      - DRO__LISTEN_ADDRESS=0.0.0.0
      - DRO__ETH__CHAIN_ID=17000
      - DRO__ETH__RPC_URL=https://ethereum-holesky-rpc.publicnode.com
      - DRO__ETH__BACKUP_RPC_URL=https://1rpc.io/holesky
      - DRO__ETH__PRIVATE_KEY=${ETH_PRIVATE_KEY}
      - DRO__NETWORK__P2P_PORT=${DRO__NETWORK__P2P_PORT}
      - DRO__NETWORK__EXTERNAL_P2P_ADDRESS=${VPS_PUBLIC_IP}
      - DRO__SERVER__PORT=${DRO__SERVER__PORT}
    volumes:
      - /var/lib/drosera-data:/data
    command: ["node"]
    restart: always
  drosera-delegation-client:
    image: ghcr.io/drosera-network/drosera-delegation-client:${VERSION}
    container_name: drosera-delegation-client
    network_mode: host
    environment:
      - DRO__DELEGATION_SERVER_URL=https://delegation-server.testnet.drosera.io
      - DRO__DROSERA_ADDRESS=0xea08f7d533C2b9A62F40D5326214f39a8E3A32F8
      - DRO__ETH__CHAIN_ID=17000
      - DRO__ETH__RPC_URL=https://ethereum-holesky-rpc.publicnode.com
      - DRO__ETH__PRIVATE_KEY=${ETH_PRIVATE_KEY}
      - DRO__NETWORK__HTTP_PORT=${DRO__NETWORK__HTTP_PORT}
    restart: always
EOF
```

## Enable and start the drosera-operator service
## Start the drosera-operator and drosera-delegation-client docker compose service
- Start the docker compose service

```bash
docker compose up -d
```

- Follow logs
```bash
docker compose logs -f drosera-delegation-client
```
- Stop following logs
```
Ctrl+C
```
- If your `drosera-delegation-client` is configured properly, you will see only this log, unless it finds a trap to opt into.
```
INFO drosera_delegation_client::delegation: Traps to opt into: []
```
## Securing your operator and delegation-client
Since we are using docker, ufw is not a compatible software firewall.  Because of the Docker networking, any incoming traffic will not hit network firewall at all.   We recommend securing the operator node with a firewall external to the vm.  Something like an AWS VPC firewall, or a GCP Compute Firewall would be a better way of closing off all access to this machine except for the ports needed for the operator and delegation client to run as well as ssh access.  Please see the cloud provider firewall documentation for setting up your cloud firewall.

# Running multiple operators on one machine
Running multiple operators on one vm with one or multiple docker compose files is doable, but it requires careful attention to your port assignments and database volumes.  Please ensure the following is true when building out your second operator service:
- The `DRO__NETWORK__P2P_PORT` needs to be different for each operator.  This is present in the docker compose service of the operator as the environment variable key `DRO__NETWORK__P2P_PORT`
- The `DRO__SERVER__PORT` needs to be different for each operator.  This is present in the docker compose service of the operator as the environment variable key `DRO__SERVER__PORT`
- If you are running multiple delegation clients (Whitelisted Testnet Operators Only), the `DRO__NETWORK__HTTP_PORT` needs to be different for each operator.  This is present in the docker compose service of the delegation-client as the environment variable key `DRO__NETWORK__HTTP_PORT`
- The operators need different mount locations for their volumes.  You can change the path on the left side of the colon (i.e. `/var/lib/drosera-data2`) to set a different system volume location for each operator you are running.
```
    volumes:
      - /var/lib/drosera-data:/data
```
- You will also need to create this directory on the system like we did for the first operator, using the path you set in the volume section of the docker compose file for the second operator.
```
sudo mkdir -p /var/lib/drosera-data2
sudo chown -R root:root /var/lib/drosera-data2
sudo chmod -R 700 /var/lib/drosera-data2
```
