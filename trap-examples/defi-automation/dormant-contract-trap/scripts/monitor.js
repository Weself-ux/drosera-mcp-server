const TelegramBot = require('node-telegram-bot-api');
const { Web3 } = require('web3');

const config = {
    telegramToken: '8279269014:AAEGX1zjqLSkGpd2a6abqk8vc1mUaDAhubA',
    contractAddress: '0xf6B0B7A6ec7E406d8EB30c4DfAD13C55e971cE7e',
    rpcUrl: 'wss://eth-hoodi.g.alchemy.com/v2/6sgd1Sp3usg4zOi5y90j1',
    chatId: '7087390212'
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
                "internalType": "string",
                "name": "alertType",
                "type": "string"
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

function formatBalance(balance) {
    return (Number(balance) / 1e18).toFixed(6);
}

function buildAlertMessage(data, transactionHash) {
    const {
        alertType,
        blockNumber,
        timestamp
    } = data;

    return `🚨 DROSERA ALERT 🚨
🔍 Dormant Contract Activated!
📧 Contract: 0x1e39Bf6C913e9dE1a303a26fdf8557923aA8D1bd
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
    console.log('Dormancy event:', event.returnValues.alertType);
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
