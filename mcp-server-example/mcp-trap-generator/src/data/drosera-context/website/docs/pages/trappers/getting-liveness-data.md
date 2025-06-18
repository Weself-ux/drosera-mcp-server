---
sidebar_position: 11
title: Getting Liveness Data
---

# Getting Liveness Data 🩺

This command allows you to check current liveness of operators opted in to a trap.

## Liveness

At a high level, a trap relies on operators monitoring (`collect` & `shouldRespond` trap functions) it every block. In a centralized service you might be running all infrastructure in-house and maintain everything to a high degree of uptime. However, Drosera is a decentralized system and therefore a trap typically relies on outside entities running and maintaining operators to keep the trap live every block. With Drosera, you have the option to run all of your own operators, but many trappers will opt to use pre-existing operators, such as protocol-level whitelisted operators. In this 2nd case, you may want to monitor the "performance" or monitoring uptime of operators on your trap. In a perfect scenario, every operator opted in to your trap would execute and broadcast the result of the execution to the trap's p2p network every block. In the real world this will likely not be the case though. Some operators may miss trap execution for certain blocks here and there due to network hiccups, etc. Rarely, this may be acceptable, but if it happens often, this operator may not be considered reliable anymore and the trap owner can make the executive decision to kick said operator from it's operator set. Even worse, an operator could simply go down completely and never come back online.

In addition to the `liveness` command, you can also get a higher level graphical view of liveness data on individual trap pages on [Drosera's dapp](https://app.drosera.io/)
![Drosera dapp liveness](../../img/drosera-dapp-liveness.png)

**To summarize**: Liveness encapsulates the idea that, for the set of operators opted in to a given trap, how active or not are they in submitting trap result attestations every block.

## Example

Running the below command with only a trap hash defined will yield the trap results from operators over the number of blocks defined in the trap's `block_sample_size`, ranging from the current block - 1 and going down `block_sample_size` blocks. It is "-1" because for the current block, operator attestations are still moving around over the trap's p2p network and therefore it may yield an incomplete picture. This gives time for network traffic to arrive.

In this example:

- The current block number is 35
- `block_sample_size` = 2
- Therefore trap results for 2 blocks are returned that range from blocks 33-34

If you additionally include an optional block number(`--block-number`), you can look at recent historical trap results at that point in time.

```bash
drosera liveness --trap-address 0xEd3a7f81e91EEB1702274AA4b7e2acc7b0D20f4F
```

Below is the example output from running this command. It fetched liveness data for the latest block - 1, which is `block_number` 35 that can be seen in the trap result from each operator. This trap has two operators opted in and we see both of them have attested their result of executing the given trap for `block_number`'s 33 and 34, as ideally expected.

Importantly, here you can find

- `should_respond`: Whether or not the operator computed that the trap's emergency response function should be called
- `response_data`: Data returned by the `shouldRespond` function to be passed to the emergency response function if `should_respond` is `true`
- `operator`: The address of the operator that authored this trap result
- `non_signers`: An operator expects to receive trap results from all other operators under the trap. If the operator didn't receive a trap result from another operator, that operator's address will be counted here as a non-signer.

```
Liveness Data: [
    [
        TrapResultWithOutput {
            trap_address: 0xfc4df3332bb0379ccd79e1d0874a6fa5196c1aba,
            block_number: 33,
            block_hash: 0x7f0bd423953a3b8448d9d23a79751bbbf339a05ada4fe9a42b26770a1826b034,
            should_respond: false,
            response_data: 0x0000000000000000000000000000000000000000000000000000000000000021,
            trap_hash: 0x73cccd382abf097c44e206d6541ef1ff862c7bcf55c85a56400de0435aead4c0,
            collect_output: 0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000021,
            operator: 0x70997970c51812dc3a010c7d01b50e0d17dc79c8,
            failure: false,
            failure_reason: "",
            non_signers: [],
        },
        TrapResultWithOutput {
            trap_address: 0xfc4df3332bb0379ccd79e1d0874a6fa5196c1aba,
            block_number: 33,
            block_hash: 0x7f0bd423953a3b8448d9d23a79751bbbf339a05ada4fe9a42b26770a1826b034,
            should_respond: false,
            response_data: 0x0000000000000000000000000000000000000000000000000000000000000021,
            trap_hash: 0x73cccd382abf097c44e206d6541ef1ff862c7bcf55c85a56400de0435aead4c0,
            collect_output: 0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000021,
            operator: 0x9d487a765a059f922b4cc4a9492d5cb8e1f33bc1,
            failure: false,
            failure_reason: "",
            non_signers: [],
        },
    ],
    [
        TrapResultWithOutput {
            trap_address: 0xfc4df3332bb0379ccd79e1d0874a6fa5196c1aba,
            block_number: 34,
            block_hash: 0xc3836f31c081d4e0a373b28cca82c6dcbda1dd2070cd48fe74c1a94dc75dde8a,
            should_respond: false,
            response_data: 0x0000000000000000000000000000000000000000000000000000000000000022,
            trap_hash: 0x73cccd382abf097c44e206d6541ef1ff862c7bcf55c85a56400de0435aead4c0,
            collect_output: 0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000022,
            operator: 0x70997970c51812dc3a010c7d01b50e0d17dc79c8,
            failure: false,
            failure_reason: "",
            non_signers: [],
        },
        TrapResultWithOutput {
            trap_address: 0xfc4df3332bb0379ccd79e1d0874a6fa5196c1aba,
            block_number: 34,
            block_hash: 0xc3836f31c081d4e0a373b28cca82c6dcbda1dd2070cd48fe74c1a94dc75dde8a,
            should_respond: false,
            response_data: 0x0000000000000000000000000000000000000000000000000000000000000022,
            trap_hash: 0x73cccd382abf097c44e206d6541ef1ff862c7bcf55c85a56400de0435aead4c0,
            collect_output: 0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000022,
            operator: 0x9d487a765a059f922b4cc4a9492d5cb8e1f33bc1,
            failure: false,
            failure_reason: "",
            non_signers: [],
        },
    ]
]
```

:::info
Please note that at the present time, this data is pulled from cache storage which is pruned at regular intervals, therefore at a certain point, historical data is no longer available. This may change in the future with the possible introduction of a data indexing service.
:::

## Command

```bash
drosera liveness --trap-address <address> --block-number <optional_block_number>
```

Where `--block-number` is optional
