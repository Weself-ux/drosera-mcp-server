const TelegramBot = require('node-telegram-bot-api');
const { Web3 } = require('web3');

const config = {
    telegramToken: "TELEGRAM_BOT_TOKEN"
    contractAddress: "RESPONSE_CONTRACT_ADDRESS"
    rpcUrl: "RPC_URL"
    chatId: "TELEGRAM_CHAT_ID"
};

const bot = new TelegramBot(config.telegramToken, { polling: true });
const web3 = new Web3(new Web3.providers.WebsocketProvider(config.rpcUrl));

const contractABI = [
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
                "indexed": true,
                "internalType": "bytes32",
                "name": "alertType",
                "type": "bytes32"
            },
            {
                "internalType": "uint256",
                "name": "currentBalance",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "lastActiveBlock",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "dormantBlocks",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "blockNumber",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "timestamp",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "alertId",
                "type": "uint256"
            },
            {
                "internalType": "string",
                "name": "telegramMessage",
                "type": "string"
            }
        ],
        "name": "DormancyStatusChanged",
        "type": "event"
    }
];

const contract = new web3.eth.Contract(contractABI, config.contractAddress);

function formatTimestamp(timestamp) {
    return new Date(Number(timestamp) * 1000).toLocaleString();
}

function getAlertTypeFromHash(alertTypeHash) {
    const reactivatedHash = web3.utils.keccak256('REACTIVATED');
    const decodeFailedHash = web3.utils.keccak256('DECODE_FAILED');
    
    if (alertTypeHash === reactivatedHash) return 'REACTIVATED';
    if (alertTypeHash === decodeFailedHash) return 'DECODE_FAILED';
    return 'UNKNOWN';
}

function buildAlertMessage(data, transactionHash) {
    const {
        contractAddress,
        blockNumber,
        timestamp
    } = data;

    return `🚨 DROSERA ALERT 🚨
🔍 Dormant Contract Activated!
📧 Contract: ${contractAddress}
⏰ Activation Time: ${formatTimestamp(timestamp)}
🔗 Block: ${blockNumber}
📋 Transaction: ${transactionHash}
⚠️ This contract was previously dormant and has suddenly become active. This could indicate:
• Rug pull attempt
• Exploitation attempt  
• Legitimate reactivation
🔍 Investigate immediately!`;
}

async function sendAlert(message) {
    try {
        await bot.sendMessage(config.chatId, message);
        console.log('Alert sent');
    } catch (error) {
        console.error('Alert failed:', error.message);
    }
}

console.log('Starting Drosera Monitor...');
console.log(`Contract: ${config.contractAddress}`);

const dormancyEvents = contract.events.DormancyStatusChanged({
    fromBlock: 'latest'
});

dormancyEvents.on('data', async (event) => {
    const alertType = getAlertTypeFromHash(event.returnValues.alertType);
    console.log('Dormancy event:', alertType);
    
    const message = buildAlertMessage(event.returnValues, event.transactionHash);
    await sendAlert(message);
});

dormancyEvents.on('error', (error) => {
    console.error('Event error:', error.message);
});

process.on('SIGINT', () => {
    console.log('Shutting down...');
    process.exit(0);
});

console.log('Monitor active');
