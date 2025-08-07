/ SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DormantContractMonitor
 * @dev Monitors dormant contracts and alerts when they become active
 * @dev Compatible with Drosera network trap system
 */
contract DormantContractMonitor {
    struct ContractInfo {
        address contractAddress;
        bool isActive;
        uint256 lastActivityTime;
        uint256 addedTime;
    }
    
    ContractInfo[] public monitoredContracts;
    mapping(address => uint256) public contractToIndex;
    mapping(address => bool) public isMonitored;
    
    address public owner;
    uint256 public inactivityPeriod;
    
    // Events
    event ContractActivated(address indexed contractAddress, uint256 timestamp);
    event ContractAdded(address indexed contractAddress);
    event ContractStatusUpdated(address indexed contractAddress, bool isActive);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event InactivityPeriodUpdated(uint256 oldPeriod, uint256 newPeriod);
    
    // Errors
    error NotOwner();
    error InvalidAddress();
    error ContractAlreadyMonitored();
    error ContractNotMonitored();
    error InvalidInactivityPeriod();
    error UnauthorizedAccess();
    
    constructor(uint256 _inactivityPeriod) {
        if (_inactivityPeriod == 0) revert InvalidInactivityPeriod();
        owner = msg.sender;
        inactivityPeriod = _inactivityPeriod;
    }
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    
    modifier validAddress(address _address) {
        if (_address == address(0)) revert InvalidAddress();
        _;
    }
    
    /**
     * @dev Adds a contract to monitoring list
     * @param _contractAddress Address of contract to monitor
     */
    function addContractToMonitor(address _contractAddress) 
        external 
        onlyOwner 
        validAddress(_contractAddress) 
    {
        if (isMonitored[_contractAddress]) revert ContractAlreadyMonitored();
        
        contractToIndex[_contractAddress] = monitoredContracts.length;
        isMonitored[_contractAddress] = true;
        
        monitoredContracts.push(ContractInfo({
            contractAddress: _contractAddress,
            isActive: false,
            lastActivityTime: block.timestamp,
            addedTime: block.timestamp
        }));
        
        emit ContractAdded(_contractAddress);
    }
    
    /**
     * @dev Updates last activity time for a contract
     * @param _contractAddress Contract to update
     */
    function updateLastActivityTime(address _contractAddress) external {
        if (!isMonitored[_contractAddress]) revert ContractNotMonitored();
        
        uint256 index = contractToIndex[_contractAddress];
        monitoredContracts[index].lastActivityTime = block.timestamp;
    }
    
    /**
     * @dev Checks and updates contract activity status
     * @param _contractAddress Contract to check
     * @param _isActive Current activity status
     */
    function checkContractActivity(address _contractAddress, bool _isActive) external {
        if (!isMonitored[_contractAddress]) revert ContractNotMonitored();
        
        uint256 index = contractToIndex[_contractAddress];
        ContractInfo storage contractInfo = monitoredContracts[index];
        
        // If contract was active and now inactive
        if (!_isActive && contractInfo.isActive) {
            contractInfo.isActive = false;
            contractInfo.lastActivityTime = block.timestamp;
            emit ContractStatusUpdated(_contractAddress, false);
        }
        // If contract was inactive and now active
        else if (_isActive && !contractInfo.isActive) {
            // Check if it's been inactive long enough to be considered "dormant"
            if (block.timestamp - contractInfo.lastActivityTime >= inactivityPeriod) {
                contractInfo.isActive = true;
                contractInfo.lastActivityTime = block.timestamp;
                emit ContractActivated(_contractAddress, block.timestamp);
            }
        }
        
        emit ContractStatusUpdated(_contractAddress, _isActive);
    }
    
    /**
     * @dev Checks if a contract is dormant
     * @param _contractAddress Contract to check
     * @return bool True if contract is dormant
     */
    function isDormant(address _contractAddress) public view returns (bool) {
        if (!isMonitored[_contractAddress]) return false;
        
        uint256 index = contractToIndex[_contractAddress];
        ContractInfo memory contractInfo = monitoredContracts[index];
        
        return (block.timestamp - contractInfo.lastActivityTime >= inactivityPeriod) && !contractInfo.isActive;
    }
    
    /**
     * @dev Manually triggers activation check (for testing)
     * @param _contractAddress Contract to check
     */
    function manualActivationCheck(address _contractAddress) external onlyOwner {
        if (!isMonitored[_contractAddress]) revert ContractNotMonitored();
        
        uint256 index = contractToIndex[_contractAddress];
        ContractInfo storage contractInfo = monitoredContracts[index];
        
        if (isDormant(_contractAddress)) {
            contractInfo.isActive = true;
            contractInfo.lastActivityTime = block.timestamp;
            emit ContractActivated(_contractAddress, block.timestamp);
        }
    }
    
    /**
     * @dev Gets contract monitoring information
     * @param _contractAddress Contract to query
     * @return contractAddress The contract address
     * @return isActive Current activity status
     * @return lastActivityTime Last recorded activity timestamp
     * @return addedTime When contract was added to monitoring
     * @return dormant Current dormancy status
     */
    function getContractInfo(address _contractAddress) external view returns (
        address contractAddress,
        bool isActive,
        uint256 lastActivityTime,
        uint256 addedTime,
        bool dormant
    ) {
        if (!isMonitored[_contractAddress]) revert ContractNotMonitored();
        
        uint256 index = contractToIndex[_contractAddress];
        ContractInfo memory info = monitoredContracts[index];
        
        return (
            info.contractAddress,
            info.isActive,
            info.lastActivityTime,
            info.addedTime,
            isDormant(_contractAddress)
        );
    }
    
    /**
     * @dev Gets total number of monitored contracts
     * @return uint256 Count of monitored contracts
     */
    function getMonitoredContractsCount() external view returns (uint256) {
        return monitoredContracts.length;
    }
    
    /**
     * @dev Updates the inactivity period
     * @param _newPeriod New inactivity period in seconds
     */
    function updateInactivityPeriod(uint256 _newPeriod) external onlyOwner {
        if (_newPeriod == 0) revert InvalidInactivityPeriod();
        
        uint256 oldPeriod = inactivityPeriod;
        inactivityPeriod = _newPeriod;
        
        emit InactivityPeriodUpdated(oldPeriod, _newPeriod);
    }
    
    /**
     * @dev Transfers ownership to a new address
     * @param _newOwner Address of the new owner
     */
    function transferOwnership(address _newOwner) external onlyOwner validAddress(_newOwner) {
        address oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
    }
    
    /**
     * @dev DROSERA REQUIRED: Response function called when trap is triggered
     * @param _contractAddress Contract that triggered the trap
     */
    function response(address _contractAddress) external {
        if (!isMonitored[_contractAddress]) revert ContractNotMonitored();
        
        uint256 index = contractToIndex[_contractAddress];
        ContractInfo storage contractInfo = monitoredContracts[index];
        
        // Mark as active and update timestamp
        contractInfo.isActive = true;
        contractInfo.lastActivityTime = block.timestamp;
        
        // Emit the activation event for monitoring systems
        emit ContractActivated(_contractAddress, block.timestamp);
        
        // Additional response logic can be added here:
        // - Pause related contracts
        // - Trigger emergency procedures
        // - Alert other systems
        // - etc.
    }
    
    /**
     * @dev DROSERA REQUIRED: Check if trap should be triggered
     * @param _contractAddress Contract to check
     * @return bool True if trap should trigger
     */
    function shouldTrigger(address _contractAddress) external view returns (bool) {
        if (!isMonitored[_contractAddress]) return false;
        
        uint256 index = contractToIndex[_contractAddress];
        ContractInfo memory contractInfo = monitoredContracts[index];
        
        // Trigger if contract has been dormant and is now showing activity
        return isDormant(_contractAddress) && contractInfo.isActive;
    }
    
    /**
     * @dev Removes a contract from monitoring (emergency function)
     * @param _contractAddress Contract to remove
     */
    function removeContractFromMonitoring(address _contractAddress) external onlyOwner {
        if (!isMonitored[_contractAddress]) revert ContractNotMonitored();
        
        uint256 index = contractToIndex[_contractAddress];
        uint256 lastIndex = monitoredContracts.length - 1;
        
        // Move the last element to the deleted spot
        if (index != lastIndex) {
            ContractInfo storage lastContract = monitoredContracts[lastIndex];
            monitoredContracts[index] = lastContract;
            contractToIndex[lastContract.contractAddress] = index;
        }
        
        // Remove the last element
        monitoredContracts.pop();
        delete contractToIndex[_contractAddress];
        delete isMonitored[_contractAddress];
    }
}

