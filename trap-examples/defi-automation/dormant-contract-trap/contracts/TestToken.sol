// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
* @title TestToken
 * @dev Simple token contract for testing the monitor
 */
contract TestToken {
    string public constant name = "Test Token";
    string public constant symbol = "TEST";
    uint8 public constant decimals = 18;
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    
    bool public isActive = false;
    address public owner;
    uint256 public totalSupply;
    
    // Events
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Activated();
    event Deactivated();
    
    // Errors
    error InsufficientBalance();
    error InsufficientAllowance();
    error InvalidAddress();
    error NotOwner();
    
    constructor() {
        owner = msg.sender;
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
     * @dev Mints tokens to an address
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner validAddress(to) {
        balances[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }
    
    /**
     * @dev Simulates reactivation of a dormant contract
     */
    function reactivate() external onlyOwner {
        isActive = true;
        emit Activated();
    }
    
    /**
     * @dev Deactivates the contract
     */
    function deactivate() external onlyOwner {
        isActive = false;
        emit Deactivated();
    }
    
    /**
     * @dev Transfers tokens
     * @param to Address to transfer to
     * @param amount Amount to transfer
     */
    function transfer(address to, uint256 amount) external validAddress(to) returns (bool) {
        if (balances[msg.sender] < amount) revert InsufficientBalance();
        
        balances[msg.sender] -= amount;
        balances[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    /**
     * @dev Approves spending allowance
     * @param spender Address to approve
     * @param amount Amount to approve
     */
    function approve(address spender, uint256 amount) external validAddress(spender) returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    /**
     * @dev Transfers from approved allowance
     * @param from Address to transfer from
     * @param to Address to transfer to
     * @param amount Amount to transfer
     */
    function transferFrom(address from, address to, uint256 amount) 
        external 
        validAddress(from) 
        validAddress(to) 
        returns (bool) 
    {
        if (balances[from] < amount) revert InsufficientBalance();
        if (allowances[from][msg.sender] < amount) revert InsufficientAllowance();
        
        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
    
    /**
     * @dev Gets balance of an address
     * @param account Address to check
     * @return uint256 Balance
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
    
    /**
     * @dev Gets allowance between addresses
     * @param _owner Owner address
     * @param spender Spender address
     * @return uint256 Allowance amount
     */
    function allowance(address _owner, address spender) external view returns (uint256) {
        return allowances[_owner][spender];
    }
}
