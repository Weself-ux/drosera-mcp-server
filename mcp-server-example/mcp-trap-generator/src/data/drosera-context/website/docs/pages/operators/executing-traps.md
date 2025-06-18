---
sidebar_position: 4
title: Executing Traps
---

# Executing Traps 🪤

Executing traps is a crucial part of the Drosera ecosystem. Traps are smart contracts that define the conditions for detecting on-chain invariants and performing on-chain responses. Operators are responsible for executing Traps and performing on-chain response actions, ensuring the security and stability of the network.

Operators can opt into a Trap to gain permission to execute it and earn rewards. Once opted in, the Operator gains access to the off-chain Trap and the current peers in the network. This allows them to actively participate in monitoring and evaluating every new block based on the conditions set by the Trap.

In the event that the conditions of a Trap are met, the Operator will promptly execute the on-chain response function. This swift action helps to mitigate potential threats and exploits.

To opt in into a trap, the following steps are required:

1. Register as an Operator
2. Get whitelisted by the Drosera team. (Permission-less operators will be available in the future)
3. Run the Drosera Operator Node
4. Opt into the Trap

## Opting into a Trap

You can opt into a Trap by running the following command:

```bash
drosera-operator optin --eth-rpc-url <rpc-url> --eth-private-key <private-key> --trap-config-address <trap-address>
```

The trap-config-address is the address of the Trap Config contract that you want to opt into. The Trap Config contract holds a hash of the Trap contract and the address of the on-chain response function. It is used to help coordinate the execution of the Trap and the on-chain response function with Operators as well as holding them accountable for doing so. **The config address can be found on Drosera's website or by querying the Drosera contract**.

After successfully opting into a Trap, you should see the following output:

```bash
INFO drosera_operator::opt_in: Opted in successfully!
```

If your Operator node has been running, it will pick up the opt in event and start executing the Trap. You can monitor the execution of the Trap by checking the logs of the Operator node. If your Operator node is not running, it will begin executing the Trap once it is started.

The Operator node can opt into multiple Traps and will be rewarded for each based on the Hydration streams configured by the Trap creator.

## Opting Out of a Trap

To opt out of a Trap, you can run the following command:

```bash
drosera-operator optout --eth-rpc-url <rpc-url> --eth-private-key <private-key> --trap-config-address 0x<trap-address>
```

After successfully opting out of a Trap, you should see the following output:

```bash
INFO drosera_operator::opt_out: Opted out successfully!
```

The Operator node will stop executing the Trap and will no longer be rewarded for its execution.

## Root Operators

If you plan on running multiple operators, you may want to take advantage of setting up a root operator. This requires a little bit more work to setup at the beginning, but saves time after that when it comes to claiming earned funds from hydration streams. If, for example, you run ten operators, instead of having to claim rewards ten different times, you can set them up with a root operator and all of the rewards for all 10 operators will go to the account of the root operator. Only one claim required now.

There are two ways to set up a root operator for an operator
1. When registering the operator, specify the optional `--root-operator-address` with the address of your desired account
```bash
drosera-operator register --eth-rpc-url <rpc-url> --eth-private-key <private-key> --root-operator-address 0x<root_operator_address>
```

2. If your operator is already registered, you can update the root operator address with the Operator CLI `update-root-operator` command. You can set the root operator for a list of operators (addresses separated by commas). 
```bash
drosera-operator update-root-operator --eth-rpc-url <rpc-url> --eth-private-key <private-key> --operator-addresses 0x<operator_address>,0x<operator_address>,0x<operator_address> --root-operator-address 0x<root_operator_address>
```