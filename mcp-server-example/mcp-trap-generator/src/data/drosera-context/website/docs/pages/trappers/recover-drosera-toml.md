---
sidebar_position: 12
title: Recover your drosera.toml File
---

# Recovering Your drosera.toml File 🤷‍♂️

The `drosera.toml` file is your local reference to all of your traps (typically under one keypair). It specifies how you want them configured, the paths to the compiled trap code on your local computer, the response functions and contracts, the Ethereum RPC you choose to use, etc. So this file is important, but life can happen and the file may be deleted, corrupted, etc by accident or no fault of your own. 

In this case, you can use the trapper CLI `recover` command. This will reconstruct the majority of a `drosera.toml` file, using on-chain state data, given a private key. It is a lossy reconstruction. It does not reconstruct the file 100% the way it was. After the file is recovered, you will need to identify each trap in the file and re-specify the `path` variable to where the compiled trap code is on your local computer, because that data is not stored on-chain.

This command pulls all of the trap data from on-chain that is owned by the specified `--private-key`. If you have separated multiple traps in multiple different `drosera.toml` files, all created using the same private key, this command will recover all of them into one file. Finally, any traps you deployed with a different private key will not be pulled down with this command. For traps created with a different private key you will need to run the command again for each sepearate private key.

## Recover

```bash
drosera recover --eth-rpc-url <rpc_url> --private-key 0x<your_private_key>
```

:::info
Optionally, you can include the `--write-path <write_path>` argument to write the recovered file to a directory and name of your choice. Ex: `--write-path ./recovered_trapasaurus_rex.toml`. If not provided, the CLI will write the file to the current working directory and call it `recovered_drosera.toml`.
:::

Once you have the file and have re-specified the `path` fields for each trap with the location of their compiled trap code, you can then rename the file to the name the CLI looks for automatically which is `drosera.toml`.



