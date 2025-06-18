---
sidebar_position: 9
title: Private Traps
---

# Private Traps 🔒

The default for a trap is to be public (i.e. `private_trap = false` in your `drosera.toml`). In this configuration, the only operators who can opt in to your trap and run it are protocol-level operators.

### Protocol-Level Operators

These operators are run by entities hand-picked by the Drosera team that are known and respected node runners in the blockchain space. When you create a trap, automatically, there will already be a set of operators available that are professionally managed with high uptime, as you would expect at an enterprise level. 

If your trap is public, all of these protocol-level operators have the ability to opt in and run your trap. However, if you set your trap to private (`private_trap = true`), then none of these protocol-level operators will be able to opt in unless you explicitly add their operator address to the trap's `whitelist`.

### Trap-Level Operators

For some, only protocol-level operators will be sufficient. Others may want to exclusively run their own infrastructure, or let one of their friends (who loves running nodes but is not a protocol-level whitelisted operator) participate in monitoring their trap. In this case, they can simply add the address of the desired operator to the trap's whitelist and update the trap on-chain. Then the non-protocol-level whitelisted operator will be able to opt in.

|                       | **protocol-level operators**                                      | **trap-level operators**                                          |
|-----------------------|-------------------------------------------------------------------|-------------------------------------------------------------------|
| **Trap is public**    | All protocol-level operators can opt in to the trap                | Can only opt in if they are explicitly added to the trap whitelist |
| **Trap is private**   | Can only opt in if they are explicitly added to the trap whitelist | Can only opt in if they are explicitly added to the trap whitelist |

This allows flexible control for who is allowed to run your trap. You can have plug and play, professionally run operators, or exclusively run your own operators, or utilize some of both. The choice is yours.

:::info
- Note: If you would like to keep your trap bytecode confidential, and not delegate trap operations to other node operators, you can run your trap as private from the beginning and whitelist your own chosen operators such as yourself.
:::
