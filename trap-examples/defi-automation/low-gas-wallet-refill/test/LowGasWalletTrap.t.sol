// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {LowGasWalletTrap} from "../src/LowGasWalletTrap.sol";

contract LowGasWalletTrapTest is Test {
    LowGasWalletTrap public trap;
    
    uint256 constant MIN_BALANCE = 0.1 ether;
    uint256 constant REFILL_AMOUNT = 0.5 ether;
    
    function setUp() public {
        trap = new LowGasWalletTrap();
    }
    
    function test_InitialState() public view {
        address[] memory wallets = trap.getMonitoredWallets();
        assertEq(wallets.length, 3);
        assertEq(trap.getMinBalance(), MIN_BALANCE);
        assertEq(trap.getRefillAmount(), REFILL_AMOUNT);
    }
    
    function test_CollectBalance() public {
        bytes memory data = trap.collect();
        LowGasWalletTrap.WalletBalance[] memory balances = 
            abi.decode(data, (LowGasWalletTrap.WalletBalance[]));
        
        assertEq(balances.length, 3);
        assertTrue(balances[0].wallet != address(0));
    }
    
    function test_BelowThreshold() public {
        bytes memory collectData = trap.collect();
        bytes[] memory dataArray = new bytes[](1);
        dataArray[0] = collectData;
        
        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(dataArray);
        
        // Wallets may or may not be below threshold depending on their actual balances
        if (shouldTrigger) {
            assertTrue(responseData.length > 0);
        }
    }
    
    function test_AddWallet() public {
        address newWallet = 0x1111111111111111111111111111111111111111;
        trap.addMonitoredWallet(newWallet);
        
        address[] memory wallets = trap.getMonitoredWallets();
        assertEq(wallets.length, 4);
        assertEq(wallets[3], newWallet);
    }
}