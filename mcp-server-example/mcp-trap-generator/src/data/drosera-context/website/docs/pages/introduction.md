---
sidebar_position: 1
---

# Introduction

[Drosera App](https://app.drosera.io)

Welcome to the **Drosera** developer documentation! This site contains documentation for:

- [Litepaper](/litepaper) - A high-level overview of Drosera and its core components.
- [Trappers](/trappers/getting-started) - Developers that create Traps. Traps are smart contracts responsible for gathering on-chain data and performing analysis over the collected data. Protocols can use Traps to monitor their on-chain state and signal the execution of an on-chain response function.
- [Operators](/operators/installation) - Decentralized nodes that are responsible for executing Traps and performing on-chain response actions. Operators can opt into a Trap to gain permission to execute it and earn rewards.
- [Seed Nodes](/introduction#seed-nodes) - Nodes that are responsible for hosting Traps and bootstrapping Operators into a decentralized network.

## What is Drosera?

Drosera is a passionate team of developers and researchers who are dedicated to building trustless and decentralized infrastructure for detecting exploits and mitigating financial loss. Drosera is an automation protocol that simplifies the process of creating monitoring systems for decentralized applications. It provides a framework for creating and executing automated responses to events on the Ethereum network, enabling developers to create more robust and secure applications.

Born out of the need for a more robust security systems for DeFi protocols, Drosera is designed to be native to the Ethereum ecosystem with a strong foundation that can be built upon. Simplicity and developer friendliness were paramount in the design of Drosera, ensuring that its straightforward approach will allow for a wide range of use cases for off-chain monitoring and on-chain responses.

As Drosera continues to evolve, we remain committed to providing a secure and user-friendly solution to the DeFi community. Our goal is to empower developers and users alike, fostering a more secure and robust DeFi ecosystem.

## How Does Drosera Work?

![DroseraTrap](../img/drosera-trap.png)

### Traps

Traps are a set of smart contracts that define the conditions for detecting invariants and performing on-chain responses. Traps have an on-chain and off-chain component that are described below:

- **Trap** - An off-chain smart contract that performs data collection and analysis to signal the execution of an on-chain response function.
- **Trap Config** - An on-chain smart contract that configures the trap and defines the on-chain response callback function. Example: "pause(uint256)" , "react(address)", etc.

The Trap Config holds a hash of the Trap contract and the address of the on-chain response function. It is used to help coordinate the execution of the Trap and the on-chain response function with Operators as well as holding them accountable for doing so.

:::info
The term analysis here is used to describe **analysis of on-chain state** and does not mean smart contract code analysis with tools like Slither, etc. A trap is collecting state data every block and analyzing the state data to make a decision if the logical criteria have been met or not to trigger the execution of an on-chain response function.
:::

### Operators

Operators are crucial players in Drosera, consisting of organizations and solo stakers who run the Drosera Operator Client software to help maintain and protect the DeFi ecosystem. These dedicated individuals are responsible for executing Traps and performing on-chain response actions, ensuring the security and stability of the network.

To execute a Trap, an Operator must first gain permission by opting into the specific Trap. Once opted in, the Operator gains access to the off-chain Trap and the current peers in the network. This allows them to actively participate in monitoring and evaluating every new block based on the conditions set by the Trap.

In the event that the conditions of a Trap are met, the Operator will promptly execute the on-chain response function. This swift action helps to mitigate potential threats and exploits.

### Seed Nodes

Seed Nodes are at the core of the Drosera network, providing the infrastructure needed to host Traps and bootstrap Operators into a decentralized network. These nodes are responsible for hosting the Trap bytecode and providing it to Operators when they opt into a Trap.

Only trusted Seed Nodes should be used to ensure the integrity of the Trap bytecode. Trusted Seed Nodes are listed in the [deployments](/deployments) section of the Drosera documentation.

### High Level Architecture

![DroseraHighLevelArchitecture](../img/DroseraHighLevelArchitecture.png)

## Learn More

The Drosera team publishes articles on X. You can find them [here](https://x.com/DroseraNetwork/articles). Follow the Drosera team on X for the latest updates and announcements.
