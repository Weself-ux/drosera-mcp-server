// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DormantResponseContract
 * @notice Handles responses when dormant contracts are reactivated
 * @dev This contract is called by Drosera when the DormantContractTrap triggers
 */
contract DormantResponseContract {
    
    struct ReactivationRecord {
        address contractAddress;
        uint256 timestamp;
        uint256 blockNumber;
        bool handled;
    }
    
    address public owner;
    mapping(address => ReactivationRecord) public reactivations;
    address[] public reactivatedContracts;
    
    // Events
    event DormantContractReactivated(
        address indexed contractAddress, 
        uint256 timestamp, 
        uint256 blockNumber
    );
    event ContractBlacklisted(address indexed contractAddress);
    event EmergencyAlert(address indexed contractAddress, string message);
    
    // Errors
    error NotOwner();
    error InvalidAddress();
    error AlreadyHandled();
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Main response function called by Drosera
     * @param reactivatedContract Address of the contract that became active
     */
    function handleDormantReactivation(address reactivatedContract) external {
        if (reactivatedContract == address(0)) revert InvalidAddress();
        
        // Check if already handled to prevent spam
        if (reactivations[reactivatedContract].handled) revert AlreadyHandled();
        
        // Record the reactivation
        reactivations[reactivatedContract] = ReactivationRecord({
            contractAddress: reactivatedContract,
            timestamp: block.timestamp,
            blockNumber: block.number,
            handled: true
        });
        
        // Add to list if not already there
        bool exists = false;
        for (uint256 i = 0; i < reactivatedContracts.length; i++) {
            if (reactivatedContracts[i] == reactivatedContract) {
                exists = true;
                break;
            }
        }
        
        if (!exists) {
            reactivatedContracts.push(reactivatedContract);
        }
        
        // Emit alert event
        emit DormantContractReactivated(
            reactivatedContract,
            block.timestamp,
            block.number
        );
        
        // Emit emergency alert for immediate attention
        emit EmergencyAlert(
            reactivatedContract,
            "ALERT: Dormant contract has been reactivated - possible rug pull recovery"
        );
    }
    
    /**
     * @dev Alternative response function with more details
     * @param reactivatedContract Address of the reactivated contract
     * @param alertMessage Custom alert message
     */
    function handleDormantReactivationWithMessage(
        address reactivatedContract, 
        string calldata alertMessage
    ) external {
        if (reactivatedContract == address(0)) revert InvalidAddress();
        
        // Record the reactivation (duplicate logic to avoid recursion)
        if (reactivations[reactivatedContract].handled) revert AlreadyHandled();
        
        reactivations[reactivatedContract] = ReactivationRecord({
            contractAddress: reactivatedContract,
            timestamp: block.timestamp,
            blockNumber: block.number,
            handled: true
        });
        
        // Add to list if not already there
        bool exists = false;
        for (uint256 i = 0; i < reactivatedContracts.length; i++) {
            if (reactivatedContracts[i] == reactivatedContract) {
                exists = true;
                break;
            }
        }
        
        if (!exists) {
            reactivatedContracts.push(reactivatedContract);
        }
        
        // Emit events
        emit DormantContractReactivated(reactivatedContract, block.timestamp, block.number);
        emit EmergencyAlert(reactivatedContract, alertMessage);
    }
    
    /**
     * @dev Get reactivation details
     */
    function getReactivationDetails(address contractAddress) 
        external 
        view 
        returns (ReactivationRecord memory) 
    {
        return reactivations[contractAddress];
    }
    
    /**
     * @dev Get all reactivated contracts
     */
    function getAllReactivatedContracts() external view returns (address[] memory) {
        return reactivatedContracts;
    }
    
    /**
     * @dev Get count of reactivated contracts
     */
    function getReactivatedContractsCount() external view returns (uint256) {
        return reactivatedContracts.length;
    }
    
    /**
     * @dev Check if contract has been reactivated
     */
    function isReactivated(address contractAddress) external view returns (bool) {
        return reactivations[contractAddress].handled;
    }
    
    /**
     * @dev Owner function to manually blacklist a contract
     */
    function blacklistContract(address contractAddress) external onlyOwner {
        if (contractAddress == address(0)) revert InvalidAddress();
        
        emit ContractBlacklisted(contractAddress);
        emit EmergencyAlert(contractAddress, "Contract manually blacklisted by admin");
    }
    
    /**
     * @dev Reset handling status (for testing)
     */
    function resetHandlingStatus(address contractAddress) external onlyOwner {
        reactivations[contractAddress].handled = false;
    }
    
    /**
     * @dev Transfer ownership
     */
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert InvalidAddress();
        owner = newOwner;
    }
}
