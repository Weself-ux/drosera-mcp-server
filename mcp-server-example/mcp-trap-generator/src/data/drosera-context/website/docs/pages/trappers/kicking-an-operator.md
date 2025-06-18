---
sidebar_position: 8
title: Kicking an Operator
---

# Kicking an Operator 🥾

If you would like to remove an operator from the set of operators running/monitoring your trap, you can kick them with the `kick-operator` command.

### Lifecycle

#### Operators

1. Operator is whitelisted as either a Drosera [protocol-level whitelisted operator](/trappers/private-traps#protocol-level-operators) or a [trap-level whitelisted operator](/trappers/private-traps#trap-level-operators) that the trap owner has specifically added to the trap's `drosera.toml` `whitelist` field, and has updated the trap on-chain with the `apply` CLI command
2. The operator can opt in because they are whitelisted

#### Trap Owner

1. If you no longer want an operator to monitor/run your trap, here are the steps to take. First...
   - If the operator is a protocol-level operator, you'll need to know their address. If the trap is public, they won't be in the trap's `whitelist`.
   - If the operator is a trap-level operator that you previously added to the trap's `whitelist`, remove their address from the trap's `whitelist` and run the `apply` command to update the trap on-chain.
2. Second, you must run the `kick-operator` CLI command with the operator's address and the trap address to effectively opt out the operator from your trap.

If you only kick a trap-level operator, but don't remove them from the whitelist also, the operator can just opt in again.

To kick an operator from your trap, simply run:

```bash
drosera kick-operator --trap-address <address> --operators <operator> <operator> <operator>
```

You can pass one or more operator addresses, separated by spaces, starting with "0x"

:::info

- Note: If you want to restrict which operators can opt in to your trap, consider setting your trap to [private](/trappers/private-traps) (i.e. `private_trap = true` in your `drosera.toml`) and configure your trap-level `whitelist`.
  :::
