// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

/**
 * @title DormantContractTrap
 * @notice Monitor dormant/abandoned smart contracts and detect when they become active
 * @dev Drosera trap that monitors contracts from rug pulls or failed projects
 */
contract DormantContractTrap is ITrap {
    
    uint256 constant DORMANCY_PERIOD = 5 minutes; // Consider dormant after 5 minutes (for testing)
    uint256 constant ACTIVITY_THRESHOLD = 0.0001 ether; // Minimum balance change to consider active
    
    // Contracts to monitor (replace with actual rug pull contract addresses)
    address[] public monitoredContracts;
    mapping(address => uint256) public lastKnownBalance;
    mapping(address => uint256) public lastActivityTimestamp;
    
    constructor() {
        // Add example contracts to monitor (replace with actual rug pull addresses)
        monitoredContracts.push(0x9F22B165DC6282ea434CC67619Ea6999ff3af2cf);
        
        // Initialize last known balances and timestamps
        for (uint256 i = 0; i < monitoredContracts.length; i++) {
            address contractAddr = monitoredContracts[i];
            lastKnownBalance[contractAddr] = contractAddr.balance;
            lastActivityTimestamp[contractAddr] = block.timestamp;
        }
    }
    
    /**
     * @dev ITrap implementation - collect data about monitored contracts
     */
    function collect() external view returns (bytes memory) {
        bool hasReactivation = false;
        address reactivatedContract = address(0);
        
        for (uint256 i = 0; i < monitoredContracts.length; i++) {
            address contractAddr = monitoredContracts[i];
            uint256 currentBalance = contractAddr.balance;
            uint256 lastBalance = lastKnownBalance[contractAddr];
            uint256 lastActivity = lastActivityTimestamp[contractAddr];
            
            // Check if contract is dormant (inactive for 5+ minutes)
            bool isDormant = (block.timestamp - lastActivity) >= DORMANCY_PERIOD;
            
            // Check if there's significant balance change (0.0001+ ETH)
            uint256 balanceChange = currentBalance > lastBalance 
                ? currentBalance - lastBalance 
                : lastBalance - currentBalance;
            bool hasActivity = balanceChange >= ACTIVITY_THRESHOLD;
            
            // If dormant contract shows activity, flag for alert
            if (isDormant && hasActivity) {
                hasReactivation = true;
                reactivatedContract = contractAddr;
                break;
            }
        }
        
        return abi.encode(hasReactivation, reactivatedContract);
    }
    
    /**
     * @dev ITrap implementation - determine if trap should respond
     * NOTE: Must be pure to match ITrap interface
     */
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        (bool hasReactivation, address contractAddr) = abi.decode(data[0], (bool, address));
        
        if (!hasReactivation || contractAddr == address(0)) {
            return (false, bytes(""));
        }
        
        return (true, abi.encode(contractAddr));
    }
    
    /**
     * @dev Manual function to update state after detection (called by owner)
     */
    function updateContractState(address contractAddr) external {
        lastKnownBalance[contractAddr] = contractAddr.balance;
        lastActivityTimestamp[contractAddr] = block.timestamp;
    }
    
    /**
     * @dev Get list of monitored contracts
     */
    function getMonitoredContracts() external view returns (address[] memory) {
        return monitoredContracts;
    }
}
