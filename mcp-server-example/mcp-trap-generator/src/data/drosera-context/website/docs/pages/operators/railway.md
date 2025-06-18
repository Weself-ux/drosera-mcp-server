---
sidebar_position: 11
title: Run on Railway
---

# 🚀 How to Launch Our Template on Railway

Follow these simple steps to deploy the Drosera Operator template on **railway.app**:

## Prerequisites

1. **Railway Account**: Sign up or log in to [railway.app](https://railway.app).
2. **GitHub Account**(optional): Ensure you have a GitHub account. This allows you to use the full version of the free trial (without a github account, you will have to pay for a non-free tier in order to deploy the templates).
3. **Ethereum Private Key**: Your operator will be launched with an Ethereum account so you will need the account private key and the account will need some $ETH on the account. Currently we are only supporting Holesky testnet. You can get Holesky $ETH from a faucet of your choosing. You can get a Holesky account private key through online wallets, execution client commands, etc. Please always keep security in mind when obtaining and using private keys for any crypto application.
4. **Ethereum RPC URL**: Currently we only support Holesky RPC endpoints. Public Holesky RPC endpoints are available but the free offerings typically have strong rate limiting in place and won't function properly with the operator node. You can purchase an API key from node providers like Alchemy to get better response times and rate freedom. You can also choose to run your own Holesky RPC node and expose it to your operator.

## Instructions

There are two very similar railway templates for running an operator

### Deploy only the Drosera Operator

This option allows you to run a stand-alone drosera operator. See [Run the Node](/operators/run-operator) for more information regarding the operator software.

#### Deploy the template

1. View the template:  
   [![Deploy on Railway](https://railway.com/button.svg)](https://railway.app/template/Ndyq3N?referralCode=tVlTpv)
2. Launch the project by clicking `Deploy drosera-operator` button.
3. Configure Environment Variables
   - Example:
     ```
     DRO-ETH-RPC_URL="https://ethereum-holesky-rpc.publicnode.com" # Change this to your Holesky RPC Node URL
     DRO-ETH-PRIVATE_KEY="0x8406...3cdb9" # Changes this to your Holesky Ethereum Private Key
     ```
4. Deploy the service by pressing the `Deploy` button.

#### Enable Networking

In order for liveness data for this operator to be seen on the frontend, we need to add an http proxy.

1. Open the `Settings` tab of your service.
2. Navigate to the `Networking` section of the settings tab.
3. Click the `Generate Domain` button.
4. Select port `31314` port from the dropdown list (if you changed the DRO__SERVER__PORT variable, choose the value you set).
5. Click the `Generate Domain` button again.

#### Redeploy the Operator

Now we need to redeploy the service to pick up the networking changes

1. Select the `Deployments` tab of your service.
2. In the green active deployment box, click the vertical 3 dot menu.
3. Click `Redeploy`

### Deploy a protocol-level Drosera Operator on the Drosera Testnet

This option allows you to run an operator and delegation client for simple opt in logic. See the [Testnet Guide](/operators/testnet-guide) for more information about how this works. This option is for protocol-level Operators hand-selected by the Drosera Team for running public traps in our testnet.

1. View the template:  
   [![Deploy on Railway](https://railway.com/button.svg)](https://railway.app/template/0OtXZl?referralCode=tVlTpv)
2. Launch the project by clicking `Deploy drosera-operator (testnet)` button.

3. Configure Environment Variables for both services. The environment variables with the same name should have the same values for each service.

   - Example:
     ```
     DRO-ETH-RPC_URL="https://ethereum-holesky-rpc.publicnode.com" # Change this to your Holesky RPC Node URL
     DRO-ETH-PRIVATE_KEY="0x8406...3cdb9" # Changes this to your Holesky Ethereum Private Key
     ```

4. Deploy the service by pressing the `Deploy` button.

#### Enable Networking

In order for liveness data for this operator to be seen on the frontend, we need to add an http proxy.

1. Open the `Settings` tab of your service.
2. Navigate to the `Networking` section of the settings tab.
3. Click the `Generate Domain` button.
4. Select port `31314` port from the dropdown list (if you changed the DRO__SERVER__PORT variable, choose the value you set).
5. Click the `Generate Domain` button again.

#### Redeploy the Operator

Now we need to redeploy the service to pick up the networking changes

1. Select the `Deployments` tab of your service.
2. In the green active deployment box, click the vertical 3 dot menu.
3. Click `Redeploy`

### Build or Deploy Errors ??

1. Check the **Deployment Logs** tab on your railway service for more details.
2. Verify that all required environment variables are configured correctly.

## Upgrading your Operator in Railway

1. Under the `Settings` section of each service, change the `Source Image` tag to the most recent version to guarantee that the new version tag is applied.
2. Adjust the environment variable names to match any new changes to the drosera-operator and drosera-delegation-client
3. Deploy the changes.

Enjoy using our template on **Railway.app**! 🚀
