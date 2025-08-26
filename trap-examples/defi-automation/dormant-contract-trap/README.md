# Dormant Contract Reactivation Trap

A Drosera trap that monitors dormant or abandoned smart contracts (especially from rug-pulled or failed projects) and detects when they suddenly become active again, sending real-time alerts via Telegram.

## Overview

This trap monitors specified contracts for periods of inactivity (dormancy) and triggers alerts when the contracts become dormant or reactivate after a period of inactivity. Useful for detecting potential exploitation attempts where bad actors reactivate previously dormant contracts, often seen in:

- Rug pull attempts using old contract infrastructure
- Exploitation of abandoned DeFi protocols
- Reactivation of failed project contracts for malicious purposes
-  legitimate contract reactivations

## How It Works

The trap continuously monitors the contract state including:

Balance changes
Transaction nonce updates
Code hash modifications

When the contract shows no activity for 25+ blocks (~5 minutes), it triggers a dormancy alert. If activity resumes, it sends a reactivation alert.

## Component

## DormantContractTrap.sol
The main trap contract that implements the dormancy detection logic..

## DormantResponseContract.sol
Receives alerts from Drosera and emits events for external monitoring.

## monitor.js
Node.js script that listens for dormancy events and sends Telegram notifications.

## Setup Instructions

1. Deploy the Contracts

2. Create trap configuration file:

bash 
nano drosera.toml

Add your trap configuration:

nano drosera.toml
[trap.dormant_trap]

file = "nano src/DormantContractTrap.sol"
contract = "DormantContractTrap"

file = "nano src/DormantResponseContract.sol"
contract = "DormantResponseContract"
function = "notifyDormancyChange"

Deploy with Drosera CLI:

bash
DROSERA_PRIVATE_KEY=your_private_key drosera apply

### 2. Configure Telegram Bot

1. Create a Telegram bot via [@BotFather](https://t.me/botfather)
2. Get your bot token
3. Get your chat ID by messaging [@userinfobot](https://t.me/userinfobot)

### 3. Setup Node.js Monitor

1. Install dependencies:
   bash
   npm install node-telegram-bot-api web3
 

2. Update configuration in monitor.js:
   ```javascript
   const config = {
       telegramToken: 'YOUR_BOT_TOKEN',
       contractAddress: 'YOUR_DEPLOYED_CONTRACT_ADDRESS',
       rpcUrl: 'wss://your-rpc-endpoint',
       chatId: 'YOUR_CHAT_ID'
   };
   ```

3. Run the monitor:
   bash
   node monitor.js
   

## Testing the Trap

Once deployed, test your dormant contract monitor:

Check Drosera Dashboard: Verify your trap is active and collecting data (Green Blocks)
Monitor Logs: Watch the monitor.js console output for activity detection using command prompt
Wait for Natural Dormancy: The trap will trigger when the monitored contract has no activity for 25+ blocks
Verify Alerts: Check your Telegram for dormancy notifications when the trap triggers
Test Response Contract: Ensure the response contract receives and processes alerts correctly

The trap automatically monitors the specified contract and will alert when dormancy conditions are met.

## Key Features

- **Real-time monitoring** of contract activity changes
- **Configurable dormancy periods** for different use cases  
- **Telegram integration** for instant notifications
- **Transaction tracking** with block and hash details
- **Health monitoring** with periodic status updates

## Alert Example

When a dormant contract reactivates, you'll receive:

```
🚨 DROSERA ALERT 🚨

🔍 Dormant Contract Activated!
📧 Contract: 0x1234...abcd
⏰ Activation Time: 1/15/2025, 3:45:22 PM
🔗 Block: 942828
📋 Transaction: 0x5678...efgh

⚠️ This contract was previously dormant and has suddenly become active.

🔍 Investigate immediately!
```

## Use Cases

- **Security Monitoring**: Watch abandoned DeFi protocols for unexpected reactivation
- **Rug Pull Detection**: Monitor failed projects that might attempt to reactivate for malicious purposes
- **Research**: Track contract lifecycle patterns and reactivation behaviors
- **Portfolio Protection**: Monitor investments in projects that have gone dormant

## Network Compatibility

- Ethereum Mainnet
- Holesky Testnet  
- Hoodi Chain
- Any EVM-compatible network

## Future Enhancements

- Automatic contract discovery based on activity patterns
- Integration with multiple notification channels eg. (Discord)
- Advanced pattern recognition for suspicious reactivation behaviors
- Multi-chain monitoring support
- Integration with other Drosera traps for comprehensive security coverage

## Contributing

This is a proof-of-concept trap for the Drosera network. Contributions and improvements are welcome!
