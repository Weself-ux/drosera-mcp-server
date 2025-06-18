---
sidebar_position: 3
title: Creating a Trap
---

# Creating a Trap 🌱

The section below outlines the anatomy of a Trap and how to deploy a Trap to the Drosera Network.

## Trap Anatomy

```javascript
import "./ITrap.sol";

contract ExampleTrap is ITrap {

  // Monitored data points defined here
    struct CollectOutput {
      uint256 x;
      uint256 y;
    }

    // Initialization logic defined here but without constructor arguments
    constructor() {}

    // Data collection and monitoring logic defined here
    function collect() external view returns (bytes memory) {
        return abi.encode(CollectOutput({x: 0, y: 0}));
    }

    // Validation logic defined here
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        // Decode the most recent collect data
        CollectOutput memory current = abi.decode(data[0], (CollectOutput));

        // Incident detected: Trigger response if x is 1
        if (current.x == 1) {
            return (true, bytes(""));
        }

        // State is valid: Do not trigger response
        return (false, bytes(""));
    }
}
```

### Constructor

The constructor is used to initialize the Trap with any necessary data such as addresses of smart contracts to monitor. The constructor is called once when the Trap is deployed to a shadow fork **without** arguments.

### Collect Function

The `collect` function is responsible for gathering data from the blockchain and returning it in a standardized format. This function is called by Operators on every new block and the output is stored off-chain.

:::info
The `collect` function is constrained to the `view` modifier because it is executed over a shadow fork of the evm state data and any state changes will not be persisted. State must only be viewed, not modified.
:::

### Collect Output

The `CollectOutput` struct is an example of a standardized format for returning data from the `collect` function. This struct is defined by the developer and can contain any data points that are relevant to the Trap. The name of the struct can be anything and the `collect` function must encode the struct into bytes on return.

### ShouldRespond Function

The `shouldRespond` function is responsible for validating the data returned by the `collect` function. This function is called by the Operator on every new block and is used to determine whether or not the Trap response should be executed. The `collect` function is called first followed by the `shouldRespond` function.

The `shouldRespond` function takes an array of bytes as an argument. The Operator will call the `shouldRespond` function with the previous data returned by the `collect` function.

The outputs are ordered from newest to oldest. The last element in the array is the oldest block of data returned by the `collect` function. The first element in the array is the most recent block of data returned by the `collect` function.

The `shouldRespond` function must return a tuple `(bool, bytes memory)`. If the tuple returns `true` then the Trap response **will** be executed. If the tuple returns `false` then the Trap response **will not** be executed by the Operators. The second element of the tuple is passed as an argument to the defined incident response function.
Example:

- `(true, bytes(""))` will trigger the response function with no arguments.
- `(true, bytes("0x1234"))` will trigger the response function with the argument `0x1234`.

:::info
The `shouldRespond` function is constrained to the `pure` modifier because all relevant state is passed to the function as an argument.
:::

## Deploying a Trap

Once you have created and tested your Trap, you can deploy it to the Drosera Network. Run the drosera apply command to deploy your Trap to the network.

```bash
drosera apply
```

A successful Trap creation will output the following:

```bash
1. Created Trap Config for basic_trap: (Gas Used: 1,678,320)
  - address: 0x7ab4C4804197531f7ed6A6bc0f0781f706ff7953
  - block: 321
```

The address represents the address of the Trap Config contract on the blockchain. The address will be used to interact with the Trap Config contract in the future.

The Trap Config is used to store the hash of the Trap bytecode and the configuration of the Trap. The Trap Config is used by the Operators to determine which Traps to opt into and execute. The hash of the Trap bytecode is used to verify the Trap bytecode has not been tampered with and to request it from the configured Drosera RPC node.

The response contract address and function signature are also stored in the Trap Config. Once a Trap indicates a response should be triggered, the Operators will submit a claim on-chain which will subsequently trigger the response function.

Once the Trap Config has been created, the Trap bytecode will be sent to the configured Drosera RPC node. The Drosera RPC node will store the Trap bytecode and provide it to Operators when they opt into the Trap. The hash of the Trap bytecode is verified against the hash stored in the Trap Config to ensure the bytecode has not been tampered with.

:::info

- At this time we have an artificial limit put in place for the number of account queries and storage queries a Trap can perform in a single block. 300 account limit and 300 storage slot limit. This means Operators will drop Traps that perform these excessive query traces. We will continue to lift these limits as we optimize and benchmark.
- Currently the BLOCKHASH opcode returns 0x0 on Drosera Traps. This will be fixed when the EIP for "Read BLOCKHASH from storage" is implemented.
- Only Operators that have opted into the Trap will have access to the raw bytecode. The bytecode is not stored on-chain.

:::
