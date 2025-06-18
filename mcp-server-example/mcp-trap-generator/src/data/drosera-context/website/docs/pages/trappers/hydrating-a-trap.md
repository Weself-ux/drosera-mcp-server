---
sidebar_position: 5
title: Hydrating a Trap
---

# Hydrating a Trap 💧

Drosera acts as a marketplace between Trappers and Operators. Operators are looking for the most incentivized traps to run, while Trappers are looking for Operators to run their traps.
Hydration Streams are the main reward mechanism in the Drosera protocol. When a User creates a hydration stream, they fund the trap with any amount of Drosera's native token, and then the hydration balance is streamed out from the trap over-time to operators that have opted-into the trap.

## Passive Rewards

A majority of the hydration stream is distributed to the Operators that have opted into the trap. The rewards are split evenly between Operators.

## Active Rewards

Every trap has a bonus reward pool that continuously accumulates rewards from hydration streams. This pool is used as an active reward for Operators that submitted a response on-chain first. Operators that signed the claim via peer-to-peer communication also receive a portion of the bonus reward for participation.

## Staking Rewards

Lastly, a portion of the hydration stream is streamed to the Drosera staking rewards pool. This pool is used to reward users that stake Drosera's native token.

## Creating a Hydration Stream

Hydration Streams can be created at any time by multiple users. To create a hydration stream on a Trap, simply run:

```bash
drosera hydrate --trap-address <address> --dro-amount <amount>
```

:::info

- A Hydration Stream has a vesting schedule of 30 days, once the 30 days have elapsed, the hydration stream will complete.
- The minimum amount of tokens required to create a hydration stream is set by the Drosera team.
- The Drosera CLI and frontend are both places for any user to create a hydration stream.
:::
