---
sidebar_position: 2
title: Registration
---

# Register as an Operator 🗳️

To run the Drosera Operator Node, you must first register as an Operator. This process involves registering a public BLS public key with the Drosera contracts. This can be achieved by running the following command:

```bash
drosera-operator register --eth-rpc-url <rpc-url> --eth-private-key <private-key>
```

The BLS public key is derived using the operator's private key. The public key is used to sign attestations and then aggregated to reach consensus on the state of the network.

:::note
If you use an EOA private key for restaking, do not use that key for registration or drosera operations. Instead, use a separate EOA private key for registration and operator operations. When Drosera integrates restaking, we will update the protocol and instructions accordingly.
:::

:::note
Access to an EOA private key is required as of now. Remoting signing via AWS KMS and GCP will be supported in the future.
:::

:::note
The same configuration format used for the Operator node can be used for any of the operator commands. i.e. the cli args, config file, or env vars used to run the Operator node can be used for the `register` command
:::
