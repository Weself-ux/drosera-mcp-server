# Dormant Contract Reactivation Trap

A Drosera trap that monitors dormant or abandoned smart contracts (especially from rug-pulled or failed projects) and detects when they suddenly become active again, sending real-time alerts via Telegram.

## Overview

This trap is designed to catch potential exploitation attempts where bad actors reactivate previously dormant contracts, often seen in:
- Rug pull attempts using old contract infrastructure
- Exploitation of abandoned DeFi protocols
- Reactivation of failed project contracts for malicious purposes

## How It Works

1. **Contract Monitoring**: Manually add suspicious or abandoned contracts to the monitoring list
2. **Dormancy Detection**: Tracks contract inactivity periods (configurable threshold)
3. **Reactivation Alerts**: Detects when dormant contracts suddenly become active
4. **Telegram Notifications**: Sends instant alerts with transaction details for immediate investigation

## Setup Instructions

### 1. Deploy the Monitor Contract

1. Open [Remix IDE](https://remix.ethereum.org)
2. Create and compile `DormantContractMonitor.sol`
3. Deploy with constructor parameter:
   - `_inactivityPeriod`: Time in seconds to consider a contract dormant (e.g., 300 for 5 minutes testing)

### 2. Configure Telegram Bot

1. Create a Telegram bot via [@BotFather](https://t.me/botfather)
2. Get your bot token
3. Get your chat ID by messaging [@userinfobot](https://t.me/userinfobot)

### 3. Setup Node.js Monitor

1. Install dependencies:
   ```bash
   npm install node-telegram-bot-api web3
   ```

2. Update configuration in `monitor.js`:
   ```javascript
   const config = {
       telegramToken: 'YOUR_BOT_TOKEN',
       contractAddress: 'YOUR_DEPLOYED_CONTRACT_ADDRESS',
       rpcUrl: 'wss://your-rpc-endpoint',
       chatId: 'YOUR_CHAT_ID'
   };
   ```

3. Run the monitor:
   ```bash
   node monitor.js
   ```

### 4. call Contracts to Monitor

Use Remix to call `addContractToMonitor()` on your deployed contract:
```solidity
addContractToMonitor(0x_SUSPICIOUS_CONTRACT_ADDRESS_)
```

## Testing

1. Deploy the `TestToken.sol` contract
2. Add it to monitoring using `addContractToMonitor()`
3. Wait for the inactivity period to pass
4. Call `reactivate()` on the test token
5. Call `checkContractActivity()` with the test token address and `isActive: true`
6. Verify Telegram alert is received

## Key Features

- **Real-time monitoring** of contract activity changes
- **Configurable dormancy periods** for different use cases  
- **Telegram integration** for instant notifications
- **Transaction tracking** with block and hash details
- **Manual activation checks** for testing purposes
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
