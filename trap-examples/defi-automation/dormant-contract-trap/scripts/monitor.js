const TelegramBot = require('node-telegram-bot-api');
const { Web3 } = require('web3');

// Configuration
const config = {
    telegramToken: 'Telegram bot api',
    contractAddress: '0xMonitoring contract address',
    rpcUrl: 'wss://eth-hoodi.************',
    chatId: '*********'
};

// Initialize Telegram bot
const bot = new TelegramBot(config.telegramToken, { polling: true });

// Initialize Web3
const web3 = new Web3(new Web3.providers.WebsocketProvider(config.rpcUrl));

// Contract ABI (updated with response functions)
const contractABI = [
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_inactivityPeriod",
                "type": "uint256"
            }
        ],
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
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "timestamp",
                "type": "uint256"
            }
        ],
        "name": "ContractActivated",
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
            },
            {
                "indexed": false,
                "internalType": "bool",
                "name": "isActive",
                "type": "bool"
            }
        ],
        "name": "ContractStatusUpdated",
        "type": "event"
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
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_contractAddress",
                "type": "address"
            },
            {
                "internalType": "bool",
                "name": "_isActive",
                "type": "bool"
            }
        ],
        "name": "checkContractActivity",
        "outputs": [],
        "stateMutability": "nonpayable",
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
                "internalType": "address",
                "name": "contractAddress",
                "type": "address"
            },
            {
                "internalType": "bool",
                "name": "isActive",
                "type": "bool"
            },
            {
                "internalType": "uint256",
                "name": "lastActivityTime",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "addedTime",
                "type": "uint256"
            },
            {
                "internalType": "bool",
                "name": "dormant",
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
        "inputs": [
            {
                "internalType": "address",
                "name": "_contractAddress",
                "type": "address"
            }
        ],
        "name": "isDormant",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
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
        "name": "manualActivationCheck",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "monitoredContracts",
        "outputs": [
            {
                "internalType": "address",
                "name": "contractAddress",
                "type": "address"
            },
            {
                "internalType": "bool",
                "name": "isActive",
                "type": "bool"
            },
            {
                "internalType": "uint256",
                "name": "lastActivityTime",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "addedTime",
                "type": "uint256"
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
        "name": "response",
        "outputs": [],
        "stateMutability": "nonpayable",
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
        "name": "shouldTrigger",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_newPeriod",
                "type": "uint256"
            }
        ],
        "name": "updateInactivityPeriod",
        "outputs": [],
        "stateMutability": "nonpayable",
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
        "name": "updateLastActivityTime",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

// Initialize contract
const contract = new web3.eth.Contract(contractABI, config.contractAddress);

// Utility function to format timestamp
function formatTimestamp(timestamp) {
    // Convert BigInt to Number for Date calculation
    const timestampNumber = typeof timestamp === 'bigint' ? Number(timestamp) : timestamp;
    return new Date(timestampNumber * 1000).toLocaleString();
}

console.log('🚀 Starting Drosera Contract Monitor on Hoodi Chain...');
console.log(`📡 Monitoring contract: ${config.contractAddress}`);
console.log(`📱 Telegram alerts will be sent to chat: ${config.chatId}`);
console.log('🔄 Testing contract connection...');

// Test contract connection first
contract.methods.getMonitoredContractsCount().call()
.then(count => {
    console.log(`✅ Contract connected successfully!`);
    console.log(`📊 Currently monitoring ${count} contracts`);
    
    // Only start event listeners after successful connection
    startEventListeners();
})
.catch(error => {
    console.error('❌ Failed to connect to contract:', error.message);
    console.log('\n🔍 Troubleshooting steps:');
    console.log('1. ✓ Contract address: ' + config.contractAddress);
    console.log('2. ✓ RPC URL: ' + config.rpcUrl);
    console.log('3. ❓ Check if contract is deployed on Hoodi chain');
    console.log('4. ❓ Check if WebSocket connection is working');
    console.log('5. ❓ Try redeploying the contract');
    process.exit(1);
});

function startEventListeners() {
    console.log('🎧 Starting event listeners...');
    
    // Listen for ContractActivated events
    try {
        const activatedEvents = contract.events.ContractActivated({
            fromBlock: 'latest'
        });
        
        activatedEvents.on('data', async (event) => {
            console.log('🚨 ACTIVATION DETECTED!', event);
            
            const contractAddress = event.returnValues.contractAddress;
            const timestamp = event.returnValues.timestamp;
            
            // Convert BigInt to string for display
            const timestampStr = typeof timestamp === 'bigint' ? timestamp.toString() : timestamp;
            
            const alertMessage = `
🚨 **DROSERA ALERT** 🚨

🔍 **Dormant Contract Activated!**
📧 Contract: \`${contractAddress}\`
⏰ Activation Time: ${formatTimestamp(timestamp)}
🔗 Block: ${event.blockNumber}
📋 Transaction: \`${event.transactionHash}\`

⚠️ This contract was previously dormant and has suddenly become active. This could indicate:
• Rug pull attempt
• Exploitation attempt  
• Legitimate reactivation

🔍 **Investigate immediately!**
            `;
            
            try {
                console.log('📤 Sending Telegram alert...');
                const result = await bot.sendMessage(config.chatId, alertMessage, { parse_mode: 'Markdown' });
                console.log('✅ Alert sent successfully to Telegram:', result.message_id);
            } catch (error) {
                console.error('❌ Error sending Telegram alert:', error.message);
                
                // Try sending without markdown if it fails
                try {
                    const simpleMessage = `🚨 DROSERA ALERT: Contract ${contractAddress} activated at block ${event.blockNumber}! Check transaction: ${event.transactionHash}`;
                    await bot.sendMessage(config.chatId, simpleMessage);
                    console.log('✅ Simple alert sent successfully');
                } catch (simpleError) {
                    console.error('❌ Failed to send simple alert too:', simpleError.message);
                }
            }
        });

        activatedEvents.on('error', (error) => {
            console.error('❌ ContractActivated event error:', error.message);
        });

        // Listen for ContractAdded events
        const addedEvents = contract.events.ContractAdded({
            fromBlock: 'latest'
        });
        
        addedEvents.on('data', (event) => {
            console.log('📝 Contract added to monitoring:', event.returnValues.contractAddress);
        });

        addedEvents.on('error', (error) => {
            console.error('❌ ContractAdded event error:', error.message);
        });

        // Listen for ContractStatusUpdated events  
        const statusEvents = contract.events.ContractStatusUpdated({
            fromBlock: 'latest'
        });
        
        statusEvents.on('data', (event) => {
            console.log('📊 Contract status updated:', {
                address: event.returnValues.contractAddress,
                isActive: event.returnValues.isActive
            });
        });

        statusEvents.on('error', (error) => {
            console.error('❌ ContractStatusUpdated event error:', error.message);
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
        
    } catch (error) {
        console.error('❌ Health check failed:', error.message);
    }
}

// Run health check every 5 minutes
setInterval(healthCheck, 5 * 60 * 1000);

// Handle process termination
process.on('SIGINT', () => {
    console.log('🛑 Shutting down Drosera monitor...');
    process.exit(0);
});

// Handle WebSocket connection errors
web3.currentProvider.on('error', (error) => {
    console.error('❌ WebSocket connection error:', error.message);
    console.log('🔄 Attempting to reconnect...');
});

web3.currentProvider.on('connect', () => {
    console.log('✅ WebSocket connected to Hoodi chain');
});

web3.currentProvider.on('disconnect', () => {
    console.log('🔌 WebSocket disconnected from Hoodi chain');
});
