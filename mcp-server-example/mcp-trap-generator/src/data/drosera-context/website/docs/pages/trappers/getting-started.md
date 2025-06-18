---
sidebar_position: 1
title: Getting Started
---

# Getting Started ⚡

## Installing Droseraup

Droseraup is the Drosera CLI installer. It is a simple command line tool that allows you to install the Drosera CLI globally on your machine.

Open your terminal and run the following command:

```bash
curl -L https://app.drosera.io/install | bash
```

This will install Droseraup, then follow the instructions on-screen, which will make the `droseraup` command available in your CLI.

Running `droseraup` by itself will install the latest precompiled `drosera` binary. See `droseraup --h` for more options, like installing from a specific version.

:::note
If you’re on Windows, you will need to install and use WSL, as your terminal, since Droseraup currently does not support the Windows OS.
:::

# Project Setup with Foundry

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Initialize Drosera project

Use the Drosera Trap Foundry Template repo to easily create a new Drosera project.

```bash
mkdir my-drosera-trap
cd my-drosera-trap
forge init -t drosera-network/trap-foundry-template
```

### Quick Start

[Drosera Trap Foundry Template Repo](https://github.com/drosera-network/trap-foundry-template)
