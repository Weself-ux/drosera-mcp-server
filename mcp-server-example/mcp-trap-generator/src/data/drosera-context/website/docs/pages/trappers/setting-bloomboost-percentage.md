---
sidebar_position: 10
title: Setting Bloomboost Percentage
---

# Setting Bloomboost Percentage 🪄

:::info

- Only applicable on Ethereum at the moment
- Note: The default starting value is 0 BPS / 0%
  :::

This command pairs with the `bloomboost` CLI command. You can run the `set-bloomboost-limit` CLI command at any time.

When your trap is triggered and the response function is called, if the bloomboost limit is set above 0%, then that percentage of the the trap config's trap-reward contract ETH balance will be sent to the block builder to incentivize inclusion of the transaction in the current block being built (important especially in times of high congestion and fees). The `set-bloomboost-limit` CLI command updates this percentage.

### Example

1. Trap (trap-reward contract) is bloomboosted with 10 ETH
2. Trap gets triggered at some point and the gas cost is 1 ETH
3. Operator pays the 1 ETH gas and at the end of the tx is reimbursed for the 1 ETH plus a little extra
4. The trap-reward contract now has 9 ETH left after gas payment
5. 50% (5000 BPS) bloom boost limit means 4.5 ETH is sent to block proposer (50% of 9 ETH)

![bloom boost flow chart](../../img/bloom_boost_flow.png)

This gives you more granular control over your bloomboost configuration. For traps monitoring higher value/more critical contracts, you can boost the trap with more ETH and/or set a higher percentage here to further boost the traps priority, which is especially important during turbulent market conditions.

```bash
drosera set-bloomboost-limit --trap-address <address> --limit <limit>
```

Where `limit` is an integer between 0 and 10000 and it is a percentage expressed in basis points (BPS). To convert a percentage to BPS you can take your percentage (with up to two decimal places) and simply multiply it by 100 i.e. 51.02% \* 100 = 5102 BPS.
