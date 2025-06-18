---
sidebar_position: 4
title: Updating a Trap
---

# Updating a Trap ⚙️

After a Trap has been deployed to the Drosera Network, it is possible to update the Trap's bytecode and other configuration values such as the response contract and function. This is useful when a Trap needs to be updated with new logic or bug fixes.

To apply the new changes after updating a Trap, simply run:

```bash
drosera apply
```

If the Trap's bytecode, Seed Node DNR, or block sample size has changed, the Operators will need to restart the execution of the trap. This is an automatic process that will occur once the Trap update event has been detected by the Operators.

The Seed Node DNR contains connection information of the Seed Node that the Operators use to retrieve the Trap bytecode and bootstrap into a decentralized network of other Operators. This is determined automatically when creating or updating the Trap. This values changes when the `drosera-rpc` argument is changed to a different Seed Node.

:::info
Trap updates have a cooldown period associated with them. Currently this value is set to 32 blocks. This means that after a Trap has been updated, the Trap will be executed for 32 blocks before it can be updated again. This is to prevent the Trap from being updated too frequently and to allow Operators to adjust to the new bytecode.
:::
