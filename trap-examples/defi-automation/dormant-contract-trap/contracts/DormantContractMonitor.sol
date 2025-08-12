// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ITrap} from "contracts/interfaces/ITrap.sol";

/**
 * @title DormantContractTrap
 * @notice Monitor dormant/abandoned smart contracts and detect when they become active
 * @dev Drosera trap that monitors contracts from rug pulls or failed projects
 */
contract DormantContractTrap is ITrap {
    
    uint256 constant DORMANCY_PERIOD = 90 days; // Consider dormant after 90 days
    uint256 constant ACTIVITY_THRESHOLD = 0.001 ether; // Minimum balance change to consider active
    
    struct ContractActivity {
        address contractAddress;
        uint256 lastBalance;
        uint256 lastActivityTime;
        uint256 blockNumber;
        bool wasActive;
    }
    
    struct ActivationAlert {
        address contractAddress;
        uint256 previousBalance;
        uint256 currentBalance;
        uint256 dormantSince;
        uint256 reactivatedAt;
    }
    
    struct TelegramConfig {
        string botToken;
        string chatId;
        address operatorAddress;
        bool enabled;
    }
    
    address[] public monitoredContracts;
    mapping(address => uint256) public lastKnownBalance;
    mapping(address => uint256) public lastActivityTimestamp;
    mapping(address => bool) public isMonitored;
    
    TelegramConfig public telegramConfig;
    address public owner;
    
    // Events
    event DormantContractReactivated(
        address indexed contractAddress, 
        uint256 previousBalance,
        uint256 currentBalance,
        uint256 dormantSince,
        uint256 timestamp
    );
    event ContractAdded(address indexed contractAddress);
    event ContractRemoved(address indexed contractAddress);
    event TelegramConfigured(address indexed operatorAddress, string chatId);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    
    // Errors
    error NotOwner();
    error InvalidAddress();
    error ContractAlreadyMonitored();
    error ContractNotMonitored();
    error InvalidTelegramConfig();
    error UnauthorizedOperator();
    
    constructor() {
        owner = msg.sender;
        
        // Add some example contracts to monitor (replace with actual addresses)
        _addContractToMonitor(0x0000000000000000000000000000000000000000);
        _addContractToMonitor(0x0000000000000000000000000000000000000000);
        _addContractToMonitor(0x0000000000000000000000000000000000000000);
    }
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    
    modifier onlyAuthorizedOperator() {
        if (telegramConfig.enabled && msg.sender != telegramConfig.operatorAddress) {
            revert UnauthorizedOperator();
        }
        _;
    }
    
    /**
     * @dev ITrap implementation - collect data about monitored contracts
     */
    function collect() external view override returns (bytes memory) {
        ContractActivity[] memory activities = new ContractActivity[](monitoredContracts.length);
        
        for (uint256 i = 0; i < monitoredContracts.length; i++) {
            address contractAddr = monitoredContracts[i];
            uint256 currentBalance = contractAddr.balance;
            
            activities[i] = ContractActivity({
                contractAddress: contractAddr,
                lastBalance: lastKnownBalance[contractAddr],
                lastActivityTime: lastActivityTimestamp[contractAddr],
                blockNumber: block.number,
                wasActive: currentBalance != lastKnownBalance[contractAddr]
            });
        }
        
        return abi.encode(activities);
    }
    
    /**
     * @dev ITrap implementation - determine if trap should respond
     */
    function shouldRespond(bytes[] calldata data) 
        external 
        override 
        returns (bool shouldTrigger, bytes memory responseData) 
    {
        if (data.length == 0) {
            return (false, "");
        }
        
        ContractActivity[] memory activities = abi.decode(data[0], (ContractActivity[]));
        
        ActivationAlert[] memory alerts = new ActivationAlert[](activities.length);
        uint256 alertCount = 0;
        
        for (uint256 i = 0; i < activities.length; i++) {
            ContractActivity memory activity = activities[i];
            
            // Check if contract was dormant and is now showing activity
            bool isDormant = _isDormant(activity.contractAddress);
            bool hasActivity = _hasSignificantActivity(activity);
            
            if (isDormant && hasActivity) {
                alerts[alertCount++] = ActivationAlert({
                    contractAddress: activity.contractAddress,
                    previousBalance: activity.lastBalance,
                    currentBalance: activity.contractAddress.balance,
                    dormantSince: lastActivityTimestamp[activity.contractAddress],
                    reactivatedAt: block.timestamp
                });
                
                // Update internal state
                lastKnownBalance[activity.contractAddress] = activity.contractAddress.balance;
                lastActivityTimestamp[activity.contractAddress] = block.timestamp;
                
                // Emit event for monitor.js to pick up
                emit DormantContractReactivated(
                    activity.contractAddress,
                    activity.lastBalance,
                    activity.contractAddress.balance,
                    lastActivityTimestamp[activity.contractAddress],
                    block.timestamp
                );
            }
        }
        
        if (alertCount > 0) {
            ActivationAlert[] memory result = new ActivationAlert[](alertCount);
            for (uint256 i = 0; i < alertCount; i++) {
                result[i] = alerts[i];
            }
            return (true, abi.encode(result));
        }
        
        return (false, "");
    }
    
    /**
     * @dev Configure Telegram bot integration
     */
    function configureTelegram(
        string calldata _botToken,
        string calldata _chatId,
        address _operatorAddress
    ) external onlyOwner {
        if (_operatorAddress == address(0)) revert InvalidAddress();
        if (bytes(_botToken).length == 0 || bytes(_chatId).length == 0) {
            revert InvalidTelegramConfig();
        }
        
        telegramConfig = TelegramConfig({
            botToken: _botToken,
            chatId: _chatId,
            operatorAddress: _operatorAddress,
            enabled: true
        });
        
        emit TelegramConfigured(_operatorAddress, _chatId);
    }
    
    /**
     * @dev Add contract to monitoring list
     */
    function addContractToMonitor(address _contractAddress) external onlyOwner {
        _addContractToMonitor(_contractAddress);
    }
    
    /**
     * @dev Internal function to add contract
     */
    function _addContractToMonitor(address _contractAddress) internal {
        if (_contractAddress == address(0)) revert InvalidAddress();
        if (isMonitored[_contractAddress]) revert ContractAlreadyMonitored();
        
        isMonitored[_contractAddress] = true;
        monitoredContracts.push(_contractAddress);
        lastKnownBalance[_contractAddress] = _contractAddress.balance;
        lastActivityTimestamp[_contractAddress] = block.timestamp;
        
        emit ContractAdded(_contractAddress);
    }
    
    /**
     * @dev Remove contract from monitoring
     */
    function removeContractFromMonitoring(address _contractAddress) external onlyOwner {
        if (!isMonitored[_contractAddress]) revert ContractNotMonitored();
        
        // Find and remove from array
        for (uint256 i = 0; i < monitoredContracts.length; i++) {
            if (monitoredContracts[i] == _contractAddress) {
                monitoredContracts[i] = monitoredContracts[monitoredContracts.length - 1];
                monitoredContracts.pop();
                break;
            }
        }
        
        delete isMonitored[_contractAddress];
        delete lastKnownBalance[_contractAddress];
        delete lastActivityTimestamp[_contractAddress];
        
        emit ContractRemoved(_contractAddress);
    }
    
    /**
     * @dev Check if contract is dormant
     */
    function _isDormant(address _contractAddress) internal view returns (bool) {
        if (!isMonitored[_contractAddress]) return false;
        return (block.timestamp - lastActivityTimestamp[_contractAddress]) >= DORMANCY_PERIOD;
    }
    
    /**
     * @dev Check if there's significant activity
     */
    function _hasSignificantActivity(ContractActivity memory _activity) internal pure returns (bool) {
        uint256 currentBalance = _activity.contractAddress.balance;
        uint256 balanceDiff = currentBalance > _activity.lastBalance 
            ? currentBalance - _activity.lastBalance 
            : _activity.lastBalance - currentBalance;
            
        return balanceDiff >= ACTIVITY_THRESHOLD || _activity.wasActive;
    }
    
    /**
     * @dev Get list of monitored contracts
     */
    function getMonitoredContracts() external view returns (address[] memory) {
        return monitoredContracts;
    }
    
    /**
     * @dev Get contract info
     */
    function getContractInfo(address _contractAddress) external view returns (
        uint256 lastBalance,
        uint256 lastActivity,
        bool dormant,
        bool monitored
    ) {
        return (
            lastKnownBalance[_contractAddress],
            lastActivityTimestamp[_contractAddress],
            _isDormant(_contractAddress),
            isMonitored[_contractAddress]
        );
    }
    
    /**
     * @dev Get Telegram config
     */
    function getTelegramConfig() external view returns (TelegramConfig memory) {
        return telegramConfig;
    }
    
    /**
     * @dev Get dormancy period
     */
    function getDormancyPeriod() external pure returns (uint256) {
        return DORMANCY_PERIOD;
    }
    
    /**
     * @dev Get activity threshold
     */
    function getActivityThreshold() external pure returns (uint256) {
        return ACTIVITY_THRESHOLD;
    }
    
    /**
     * @dev Get monitored contracts count
     */
    function getMonitoredContractsCount() external view returns (uint256) {
        return monitoredContracts.length;
    }
    
    /**
     * @dev Transfer ownership
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        if (_newOwner == address(0)) revert InvalidAddress();
        
        address oldOwner = owner;
        owner = _newOwner;
        
        emit OwnershipTransferred(oldOwner, _newOwner);
    }
    
    /**
     * @dev Enable/disable Telegram
     */
    function setTelegramEnabled(bool _enabled) external onlyOwner {
        telegramConfig.enabled = _enabled;
    }
}
