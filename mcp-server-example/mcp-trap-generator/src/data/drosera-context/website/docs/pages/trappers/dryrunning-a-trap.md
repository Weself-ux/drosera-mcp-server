---
sidebar_position: 7
title: Dryrunning a Trap
---

# Dryrunning a Trap ⛓️

Ideally you would be able to test your trap with real block/state data before deploying it for real, on-chain. Well, with the `dryrun` command you can. In normal trap operation, a trap will be "monitored" by one or more opted-in operators, but with the `dryrun` command you can easily test one lifecycle of this same process on your local machine with what is for all intents and purposes, a locally spun-up ad-hoc operator.

## Under The Hood

One lifecycle will be performed with block(s) pulled from your specified evm endpoint, `ethereum_rpc` in your `drosera.toml` config file. The number of blocks pulled is determined by your configured `block_sample_size` (also `drosera.toml`) for the trap.

### Lifecycle

1. The `block_sample_size` latest blocks are fetched from your RPC endpoint, and the traps `collect` function is called for each block with the fetched block as input.
2. The outputs of the `collect` calls are passed as input to one call of the `should_respond` function.
3. `should_respond` will return a value of `false` for do nothing, or `true` for execute the specified `response_function` (`drosera.toml`).

:::info
- Note: This does not actually take any actions to execute the `response_function`.
:::

You've now been able to verify that your trap is functioning end-to-end, as if it was already deployed to the Drosera network.

## Theory-crafting

With the optional `--block-number` argument, `dryrun` can be used to test traps on past state. This allows anything from more robust testing of a trap, all the way to verifying that a trap successfully catches a past exploit. An excellent addition to the security researcher tool belt.

## How To Run

```bash
drosera dryrun --block-number <block_number>
```
where `--block-number` is optional. Without, it defaults to the current block number.
