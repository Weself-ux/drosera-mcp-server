---
sidebar_position: 1
description: Instructions for installing the Drosera Operator.
title: Installation
---

# Installation 📀

The Drosera Operator runs on Linux.

There are two core methods to obtain the Drosera Operator application:

- Pre-built binaries
- Docker Images

## Pre-built Binaries

Each Drosera Operator release includes pre-built binaries. You can download the latest release from the [Drosera Operator GitHub Releases page](https://github.com/drosera-network/releases/releases).

### Platforms

Binaries are supported on the following platforms:

- x86_64-unknown-linux-gnu: AMD/Intel 64-bit processors (most desktops, laptops, servers)

:::note
Currently, only Ubuntu 22.04 and greater is officially supported. The Drosera team will work on supporting more Linux distributions out-of-the-box in the future.
:::

### Usage

Each binary is contained in a .tar.gz archive. To use the Drosera Operator binary, follow the following steps:

#### Steps

1. Go to the [Releases](https://github.com/drosera-network/releases/releases) page and select the latest release.
2. Download the `drosera-operator-${VERSION}-x86_64-unknown-linux-gnu.tar.gz` binary. For example, to obtain the binary file for v1.0.0-main.1 (the latest version at the time of writing), a user can run the following commands in a linux terminal:

```bash
cd ~
curl -LO https://github.com/drosera-network/releases/releases/download/v1.0.2/drosera-operator-v1.0.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.0.2-x86_64-unknown-linux-gnu.tar.gz
```

> The "main.1" suffix indicates a pre-release.

3. Test the binary with `./drosera-operator --version` to verify the binary is working and the version matches the expected version.
4. (Optional) Move the drosera-operator binary to a location in your PATH, so the drosera-operator command can be called from anywhere. For example, to copy drosera-operator from the current directory to usr/bin, run `sudo cp drosera-operator /usr/bin`.

## Docker

We also provide Docker images for the Drosera Operator. The Docker image can be obtained by pulling from our public registry:

```bash
docker pull ghcr.io/drosera-network/drosera-operator:latest
```

Test the Docker image by running the following command:

```bash
docker run ghcr.io/drosera-network/drosera-operator --help
```

## Recommended System Requirements

The Drosera Operator is a lightweight application that can run on most modern systems. However, we recommend the following system requirements for optimal performance:

- 2 CPU Cores
- 4 GB RAM
- 20 GB Disk Space

The more traps you are opted into, the more resources the Drosera Operator will consume. We recommend starting with the above requirements and scaling up as needed.

:::note
The Drosera Operator is still in development and these requirements may change in the future after further benchmarking.
:::

:::note
A self-managed Ethereum node is recommended for optimal performance. However, a 3rd party node such as Infura can be used as well but beware, the Drosera Operator will cause significant usage spikes.
:::
