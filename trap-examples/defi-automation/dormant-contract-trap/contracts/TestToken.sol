// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TestTarget
 * @notice A simple contract that can receive ETH and has functions to simulate activity
 * @dev Used to test the DormantContractTrap
 */
contract TestTarget {
    uint256 public counter;
    uint256 public lastActivity;
    address public owner;
    
    event ActivityDetected(address indexed caller, uint256 timestamp, uint256 value);
    event CounterIncreased(uint256 newValue);
    
    constructor() {
        owner = msg.sender;
        lastActivity = block.timestamp;
    }
    
    // Allows contract to receive ETH
    receive() external payable {
        lastActivity = block.timestamp;
        emit ActivityDetected(msg.sender, block.timestamp, msg.value);
    }
    
    // Function to simulate activity
    function doSomething() external {
        counter++;
        lastActivity = block.timestamp;
        emit CounterIncreased(counter);
        emit ActivityDetected(msg.sender, block.timestamp, 0);
    }
    
    // Function to simulate activity with value
    function doSomethingWithValue() external payable {
        counter++;
        lastActivity = block.timestamp;
        emit CounterIncreased(counter);
        emit ActivityDetected(msg.sender, block.timestamp, msg.value);
    }
    
    // Owner can withdraw
    function withdraw() external {
        require(msg.sender == owner, "Only owner");
        lastActivity = block.timestamp;
        payable(owner).transfer(address(this).balance);
        emit ActivityDetected(msg.sender, block.timestamp, 0);
    }
    
    // View functions
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    function getTimeSinceLastActivity() external view returns (uint256) {
        return block.timestamp - lastActivity;
    }
}
