const TelegramBot = require('node-telegram-bot-api');
const { Web3 } = require('web3');

// Configuration
const config = {
    telegramToken: 'YOUR_TELEGRAM_BOT_TOKEN', // Replace with your bot token
    contractAddress: '0xYOUR_DEPLOYED_DORMANT_TRAP_ADDRESS', // Replace with your deployed DormantContractTrap address
    rpcUrl: 'wss://eth-hoodi.************', // Your Hoodi chain WebSocket RPC
    chatId: 'YOUR_CHAT_ID', // Replace with your Telegram chat ID
    operatorAddress: '0xYOUR_OPERATOR_ADDRESS' // Your operator address
};

// Initialize Telegram bot
const bot = new TelegramBot(config.telegramToken, { polling: true });

// Initialize Web3
const web3 = new Web3(new Web3.providers.WebsocketProvider(config.rpcUrl));

// Contract ABI for DormantContractTrap
const contractABI = [
    {
        "inputs": [],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "contractAddress",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "previousBalance",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "currentBalance",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "dormantSince",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "timestamp",
                "type": "uint256"
            }
        ],
        "name": "DormantContractReactivated",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "contractAddress",
                "type": "address"
            }
        ],
        "name": "ContractAdded",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "contractAddress",
                "type": "address"
            }
        ],
        "name": "ContractRemoved",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "operatorAddress",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "string",
                "name": "chatId",
                "type": "string"
            }
        ],
        "name": "TelegramConfigured",
        "type": "event"
    },
    {
        "inputs": [],
        "name": "collect",
        "outputs": [
            {
                "internalType": "bytes",
                "name": "",
                "type": "bytes"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes[]",
                "name": "data",
                "type": "bytes[]"
            }
        ],
        "name": "shouldRespond",
        "outputs": [
            {
                "internalType": "bool",
                "name": "shouldTrigger",
                "type": "bool"
            },
            {
                "internalType": "bytes",
                "name": "responseData",
                "type": "bytes"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getMonitoredContracts",
        "outputs": [
            {
                "internalType": "address[]",
                "name": "",
                "type": "address[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_contractAddress",
                "type": "address"
            }
        ],
        "name": "getContractInfo",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "lastBalance",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "lastActivity",
                "type": "uint256"
            },
            {
                "internalType": "bool",
                "name": "dormant",
                "type": "bool"
            },
            {
                "internalType": "bool",
                "name": "monitored",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getMonitoredContractsCount",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getDormancyPeriod",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "pure",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getActivityThreshold",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "pure",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_contractAddress",
                "type": "address"
            }
        ],
        "name": "addContractToMonitor",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

// Initialize contract
const contract = new web3.eth.Contract(contractABI, config.contractAddress);

// Utility functions
function formatTimestamp(timestamp) {
    const timestampNumber = typeof timestamp === 'bigint' ? Number(timestamp) : timestamp;
    return new Date(timestampNumber * 1000).toLocaleString();
}

function formatEther(wei) {
    const weiNumber = typeof wei === 'bigint' ? Number(wei) : wei;
    return (weiNumber / 1e18).toFixed(6);
}

function formatDormancyPeriod(dormantSince) {
    const now = Math.floor(Date.now() / 1000);
    const dormantFor = now - Number(dormantSince);
    const days = Math.floor(dormantFor / (24 * 60 * 60));
    const hours = Math.floor((dormantFor % (24 * 60 * 60)) / 3600);
    return `${days} days, ${hours} hours`;
}

function getExplorerLink(address, type = 'address') {
    // Replace with actual Hoodi chain explorer URL
    const baseUrl = 'https://hoodi-explorer.com';
    return `${baseUrl}/${type}/${address}`;
}

console.log('🚀 Starting Drosera Dormant Contract Monitor on Hoodi Chain...');
console.log(`📡 Monitoring contract: ${config.contractAddress}`);
console.log(`📱 Telegram alerts will be sent to chat: ${config.chatId}`);
console.log(`👤 Operator address: ${config.operatorAddress}`);
console.log('🔄 Testing contract connection...');

// Test contract connection first
contract.methods.getMonitoredContractsCount().call()
.then(async count => {
    console.log(`✅ Contract connected successfully!`);
    console.log(`📊 Currently monitoring ${count} contracts`);
    
    // Get monitored contracts
    try {
        const contracts = await contract.methods.getMonitoredContracts().call();
        console.log('📋 Monitored contracts:', contracts);
        
        // Get dormancy settings
        const dormancyPeriod = await contract.methods.getDormancyPeriod().call();
        const activityThreshold = await contract.methods.getActivityThreshold().call();
        
        console.log(`⏰ Dormancy period: ${Number(dormancyPeriod) / (24 * 60 * 60)} days`);
        console.log(`💰 Activity threshold: ${formatEther(activityThreshold)} ETH`);
        
    } catch (error) {
        console.log('⚠️ Could not fetch contract details:', error.message);
    }
    
    // Only start event listeners after successful connection
    startEventListeners();
})
.catch(error => {
    console.error('❌ Failed to connect to contract:', error.message);
    console.log('\n🔍 Troubleshooting steps:');
    console.log('1. ✓ Contract address: ' + config.contractAddress);
    console.log('2. ✓ RPC URL: ' + config.rpcUrl);
    console.log('3. ❓ Check if DormantContractTrap is deployed on Hoodi chain');
    console.log('4. ❓ Check if WebSocket connection is working');
    console.log('5. ❓ Verify contract ABI matches deployed contract');
    process.exit(1);
});

function startEventListeners() {
    console.log('🎧 Starting event listeners...');
    
    try {
        // Listen for DormantContractReactivated events (main alert)
        const reactivatedEvents = contract.events.DormantContractReactivated({
            fromBlock: 'latest'
        });
        
        reactivatedEvents.on('data', async (event) => {
            console.log('🚨 DORMANT CONTRACT REACTIVATED!', event);
            
            const contractAddress = event.returnValues.contractAddress;
            const previousBalance = event.returnValues.previousBalance;
            const currentBalance = event.returnValues.currentBalance;
            const dormantSince = event.returnValues.dormantSince;
            const timestamp = event.returnValues.timestamp;
            const blockNumber = event.blockNumber;
            const txHash = event.transactionHash;
            
            const balanceChange = Number(currentBalance) - Number(previousBalance);
            const balanceChangeEth = formatEther(Math.abs(balanceChange));
            const balanceDirection = balanceChange > 0 ? '📈 Increased' : '📉 Decreased';
            
            const alertMessage = `
🚨 **DROSERA TRAP TRIGGERED** 🚨

🧟 **DORMANT CONTRACT REACTIVATED!**

📧 **Contract:** \`${contractAddress}\`
😴 **Was Dormant Since:** ${formatTimestamp(dormantSince)}
⏰ **Reactivated At:** ${formatTimestamp(timestamp)}
📊 **Dormant For:** ${formatDormancyPeriod(dormantSince)}

💰 **Balance Activity:**
• Previous: ${formatEther(previousBalance)} ETH
• Current: ${formatEther(currentBalance)} ETH  
• Change: ${balanceDirection} by ${balanceChangeEth} ETH

🔗 **Transaction Details:**
• Block: ${blockNumber}
• TX Hash: \`${txHash}\`

🌐 **Explorer Links:**
• [Contract](${getExplorerLink(contractAddress)})
• [Transaction](${getExplorerLink(txHash, 'tx')})

⚠️ **SECURITY ALERT**
This contract was dormant for 90+ days and suddenly became active!

🚩 **POTENTIAL THREATS:**
• Rug pull execution
• Token dump preparation
• Exploit contract reactivation
• Abandoned protocol misuse
• MEV bot targeting

💡 **IMMEDIATE ACTIONS REQUIRED:**
• 🔍 Investigate transaction details
• 📊 Monitor for additional transactions
• 🚨 Check for large token movements
• 👥 Alert your security team
• 📱 Monitor social media for announcements

🤖 **Powered by Drosera Network**
🪤 **Trap:** DormantContractMonitor
👤 **Operator:** \`${config.operatorAddress}\`
            `;
            
            try {
                console.log('📤 Sending Telegram alert...');
                const result = await bot.sendMessage(config.chatId, alertMessage, { 
                    parse_mode: 'Markdown',
                    disable_web_page_preview: false 
                });
                console.log('✅ Alert sent successfully to Telegram:', result.message_id);
                
            } catch (error) {
                console.error('❌ Error sending Telegram alert:', error.message);
                
                // Fallback to simple message
                try {
                    const simpleMessage = `🚨 DROSERA ALERT: Dormant contract ${contractAddress} reactivated! Balance changed by ${balanceChangeEth} ETH. TX: ${txHash}`;
                    await bot.sendMessage(config.chatId, simpleMessage);
                    console.log('✅ Simple alert sent successfully');
                } catch (simpleError) {
                    console.error('❌ Failed to send simple alert too:', simpleError.message);
                }
            }
        });

        reactivatedEvents.on('error', (error) => {
            console.error('❌ DormantContractReactivated event error:', error.message);
        });

        // Listen for ContractAdded events
        const addedEvents = contract.events.ContractAdded({
            fromBlock: 'latest'
        });
        
        addedEvents.on('data', async (event) => {
            const contractAddress = event.returnValues.contractAddress;
            console.log('📝 Contract added to monitoring:', contractAddress);
            
            const message = `📝 **Contract Added to Monitoring**\n\n\`${contractAddress}\`\n\n🔍 Now monitoring for dormancy reactivation.`;
            try {
                await bot.sendMessage(config.chatId, message, { parse_mode: 'Markdown' });
            } catch (error) {
                console.error('Error sending contract added notification:', error.message);
            }
        });

        addedEvents.on('error', (error) => {
            console.error('❌ ContractAdded event error:', error.message);
        });

        // Listen for ContractRemoved events
        const removedEvents = contract.events.ContractRemoved({
            fromBlock: 'latest'
        });
        
        removedEvents.on('data', async (event) => {
            const contractAddress = event.returnValues.contractAddress;
            console.log('🗑️ Contract removed from monitoring:', contractAddress);
            
            const message = `🗑️ **Contract Removed from Monitoring**\n\n\`${contractAddress}\`\n\n✅ No longer monitoring this contract.`;
            try {
                await bot.sendMessage(config.chatId, message, { parse_mode: 'Markdown' });
            } catch (error) {
                console.error('Error sending contract removed notification:', error.message);
            }
        });

        removedEvents.on('error', (error) => {
            console.error('❌ ContractRemoved event error:', error.message);
        });

        // Listen for TelegramConfigured events
        const telegramEvents = contract.events.TelegramConfigured({
            fromBlock: 'latest'
        });
        
        telegramEvents.on('data', (event) => {
            console.log('📱 Telegram configuration updated. Operator:', event.returnValues.operatorAddress);
            console.log('📱 Chat ID:', event.returnValues.chatId);
        });

        telegramEvents.on('error', (error) => {
            console.error('❌ TelegramConfigured event error:', error.message);
        });

        console.log('✅ All event listeners started successfully!');
        
    } catch (error) {
        console.error('❌ Failed to start event listeners:', error.message);
        process.exit(1);
    }
}

// Health check function
async function healthCheck() {
    try {
        const blockNumber = await web3.eth.getBlockNumber();
        console.log(`💓 Health check - Hoodi Chain block: ${blockNumber}`);
        
        // Test contract connection
        const contractCount = await contract.methods.getMonitoredContractsCount().call();
        console.log(`📊 Currently monitoring ${contractCount} contracts`);
        
        // Test Telegram connection
        try {
            const me = await bot.getMe();
            console.log(`📱 Telegram bot connected: @${me.username}`);
        } catch (error) {
            console.error('❌ Telegram connection issue:', error.message);
        }
        
    } catch (error) {
        console.error('❌ Health check failed:', error.message);
    }
}

// Telegram bot commands
bot.onText(/\/start/, async (msg) => {
    const chatId = msg.chat.id;
    const welcomeMessage = `
🤖 **Drosera Dormant Contract Monitor**

This bot monitors dormant smart contracts and alerts when they become active again.

**Commands:**
/status - Check monitoring status
/contracts - List monitored contracts
/info <address> - Get contract info
/dormancy - Show dormancy settings
/help - Show this help message

🔒 **Security Focus:**
Detecting reactivated contracts from rug pulls, failed projects, and abandoned protocols.

⚡ **Powered by Drosera Network**
    `;
    
    await bot.sendMessage(chatId, welcomeMessage, { parse_mode: 'Markdown' });
});

bot.onText(/\/status/, async (msg) => {
    const chatId = msg.chat.id;
    
    try {
        const count = await contract.methods.getMonitoredContractsCount().call();
        const dormancyPeriod = await contract.methods.getDormancyPeriod().call();
        const activityThreshold = await contract.methods.getActivityThreshold().call();
        const blockNumber = await web3.eth.getBlockNumber();
        
        const statusMessage = `
📊 **Monitor Status**

🔗 **Chain:** Hoodi Network
📦 **Current Block:** ${blockNumber}
📋 **Monitored Contracts:** ${count}
⏰ **Dormancy Period:** ${Number(dormancyPeriod) / (24 * 60 * 60)} days
💰 **Activity Threshold:** ${formatEther(activityThreshold)} ETH
📡 **Contract:** \`${config.contractAddress}\`
✅ **Status:** Active & Monitoring

🎧 **Listening for:**
• DormantContractReactivated events
• ContractAdded/Removed events
• Balance changes and suspicious activity
        `;
        
        await bot.sendMessage(chatId, statusMessage, { parse_mode: 'Markdown' });
        
    } catch (error) {
        await bot.sendMessage(chatId, '❌ Error getting status: ' + error.message);
    }
});

bot.onText(/\/contracts/, async (msg) => {
    const chatId = msg.chat.id;
    
    try {
        const contracts = await contract.methods.getMonitoredContracts().call();
        
        if (contracts.length === 0) {
            await bot.sendMessage(chatId, '📭 No contracts are currently being monitored.');
            return;
        }
        
        let message = '📋 **Monitored Contracts:**\n\n';
        
        for (let i = 0; i < Math.min(contracts.length, 10); i++) { // Limit to 10 for readability
            const addr = contracts[i];
            try {
                const info = await contract.methods.getContractInfo(addr).call();
                const dormantStatus = info.dormant ? '😴 Dormant' : '⚡ Active';
                const lastActivity = formatTimestamp(info.lastActivity);
                
                message += `${i + 1}. \`${addr}\`\n`;
                message += `   Status: ${dormantStatus}\n`;
                message += `   Last Activity: ${lastActivity}\n`;
                message += `   Balance: ${formatEther(info.lastBalance)} ETH\n\n`;
                
            } catch (error) {
                message += `${i + 1}. \`${addr}\` (Error getting info)\n\n`;
            }
        }
        
        if (contracts.length > 10) {
            message += `... and ${contracts.length - 10} more contracts`;
        }
        
        await bot.sendMessage(chatId, message, { parse_mode: 'Markdown' });
        
    } catch (error) {
        await bot.sendMessage(chatId, '❌ Error getting contracts: ' + error.message);
    }
});

bot.onText(/\/info (.+)/, async (msg, match) => {
    const chatId = msg.chat.id;
    const address = match[1].trim();
    
    // Basic address validation
    if (!web3.utils.isAddress(address)) {
        await bot.sendMessage(chatId, '❌ Invalid contract address format');
        return;
    }
    
    try {
        const info = await contract.methods.getContractInfo(address).call();
        
        if (!info.monitored) {
            await bot.sendMessage(chatId, '⚠️ This contract is not being monitored');
            return;
        }
        
        const dormantStatus = info.dormant ? '😴 Dormant' : '⚡ Active';
        const lastActivity = formatTimestamp(info.lastActivity);
        const dormantFor = info.dormant ? formatDormancyPeriod(info.lastActivity) : 'N/A';
        
        const infoMessage = `
📊 **Contract Information**

📧 **Address:** \`${address}\`
📊 **Status:** ${dormantStatus}
⏰ **Last Activity:** ${lastActivity}
💰 **Last Balance:** ${formatEther(info.lastBalance)} ETH
📈 **Dormant For:** ${dormantFor}
🔍 **Monitored:** ${info.monitored ? '✅ Yes' : '❌ No'}

🌐 **[View on Explorer](${getExplorerLink(address)})**
        `;
        
        await bot.sendMessage(chatId, infoMessage, { 
            parse_mode: 'Markdown',
            disable_web_page_preview: true 
        });
        
    } catch (error) {
        await bot.sendMessage(chatId, '❌ Error getting contract info: ' + error.message);
    }
});

bot.onText(/\/dormancy/, async (msg) => {
    const chatId = msg.chat.id;
    
    try {
        const dormancyPeriod = await contract.methods.getDormancyPeriod().call();
        const activityThreshold = await contract.methods.getActivityThreshold().call();
        
        const dormancyMessage = `
⏰ **Dormancy Settings**

📅 **Dormancy Period:** ${Number(dormancyPeriod) / (24 * 60 * 60)} days
💰 **Activity Threshold:** ${formatEther(activityThreshold)} ETH

📋 **Detection Logic:**
• Contracts are considered dormant after ${Number(dormancyPeriod) / (24 * 60 * 60)} days of inactivity
• Activity is detected by balance changes ≥ ${formatEther(activityThreshold)} ETH
• Alerts trigger when dormant contracts show activity

🎯 **Use Case:**
Detecting when abandoned, rug-pulled, or failed project contracts suddenly become active again.
        `;
        
        await bot.sendMessage(chatId, dormancyMessage, { parse_mode: 'Markdown' });
        
    } catch (error) {
        await bot.sendMessage(chatId, '❌ Error getting dormancy settings: ' + error.message);
    }
});

bot.onText(/\/help/, async (msg) => {
    const chatId = msg.chat.id;
    const helpMessage = `
🤖 **Drosera Dormant Contract Monitor Help**

**Commands:**
/start - Welcome message
/status - Check monitoring status and statistics
/contracts - List all monitored contracts with their status
/info <address> - Get detailed info about a specific contract
/dormancy - Show dormancy detection settings
/help - Show this help message

**What this bot does:**
🔍 Monitors smart contracts from rug pulls and failed projects
⚠️ Detects when dormant contracts (inactive for 90+ days) suddenly become active
📱 Sends immediate Telegram alerts with detailed analysis
🛡️ Helps identify potential security threats and suspicious activity

**Alert Types:**
🚨 Dormant contract reactivation
📝 Contract added/removed from monitoring
📱 Configuration updates

**Technical Details:**
• Built on Drosera Network trap system
• Monitors Hoodi Chain
• Uses balance changes as activity indicators
• Provides explorer links for investigation

⚡ **Powered by Drosera Network**
    `;
    
    await bot.sendMessage(chatId, helpMessage, { parse_mode: 'Markdown' });
});

// Run health check every 5 minutes
setInterval(healthCheck, 5 * 60 * 1000);

// Send startup notification
bot.sendMessage(config.chatId, `
🚀 **Drosera Monitor Started**

🪤 **Trap:** DormantContractMonitor
🔗 **Network:** Hoodi Chain
📡 **Contract:** \`${config.contractAddress}\`
👤 **Operator:** \`${config.operatorAddress}\`

✅ **Status:** Ready to detect dormant contract reactivations!
`, { parse_mode: 'Markdown' }).catch(console.error);

// Handle process termination
process.on('SIGINT', () => {
    console.log('🛑 Shutting down Drosera monitor...');
    bot.sendMessage(config.chatId, '🛑 **Drosera monitor shutting down...**', { parse_mode: 'Markdown' })
        .finally(() => {
            process.exit(0);
        });
});

// Handle WebSocket connection events
web3.currentProvider.on('error', (error) => {
    console.error('❌ WebSocket connection error:', error.message);
    console.log('🔄 Attempting to reconnect...');
});

web3.currentProvider.on('connect', () => {
    console.log('✅ WebSocket connected to Hoodi chain');
});

web3.currentProvider.on('disconnect', () => {
    console.log('🔌 WebSocket disconnected from Hoodi chain');
    console.log('🔄 Waiting for reconnection...');
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
    console.error('❌ Uncaught Exception:', error);
    bot.sendMessage(config.chatId, `❌ **Monitor Error:** ${error.message}`, { parse_mode: 'Markdown' })
        .finally(() => {
            process.exit(1);
        });
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
});
