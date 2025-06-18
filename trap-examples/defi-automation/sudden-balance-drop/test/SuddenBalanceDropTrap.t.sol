// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {SuddenBalanceDropTrap} from "../src/SuddenBalanceDropTrap.sol";

contract SuddenBalanceDropTrapTest is Test {
    SuddenBalanceDropTrap public trap;
    
    address constant TEST_VAULT = 0x1111111111111111111111111111111111111111;
    address constant TEST_TOKEN = 0x2222222222222222222222222222222222222222;
    
    function setUp() public {
        trap = new SuddenBalanceDropTrap();
    }
    
    function test_InitialState() public view {
        SuddenBalanceDropTrap.VaultInfo[] memory vaults = trap.getMonitoredVaults();
        uint256 threshold = trap.getDropThreshold();
        
        assertEq(vaults.length, 3);
        assertEq(threshold, 1000); // 10% in BPS
    }
    
    function test_CollectData() public {
        // Mock balances for all monitored vaults
        SuddenBalanceDropTrap.VaultInfo[] memory vaults = trap.getMonitoredVaults();
        for (uint256 i = 0; i < vaults.length; i++) {
            vm.mockCall(
                vaults[i].token,
                abi.encodeWithSignature("balanceOf(address)", vaults[i].vault),
                abi.encode(100000e6) // 100k tokens
            );
        }
        
        bytes memory data = trap.collect();
        assertTrue(data.length > 0);
        
        SuddenBalanceDropTrap.VaultBalance[] memory balances = 
            abi.decode(data, (SuddenBalanceDropTrap.VaultBalance[]));
        assertEq(balances.length, 3);
    }
    
    function test_NoBalanceDrops() public {
        // Mock stable balances for all vaults
        SuddenBalanceDropTrap.VaultInfo[] memory vaults = trap.getMonitoredVaults();
        for (uint256 i = 0; i < vaults.length; i++) {
            vm.mockCall(
                vaults[i].token,
                abi.encodeWithSignature("balanceOf(address)", vaults[i].vault),
                abi.encode(100000e6) // 100k tokens (stable)
            );
        }
        
        bytes memory data1 = trap.collect();
        bytes memory data2 = trap.collect();
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = data2;
        dataArray[1] = data1;
        
        (bool shouldTrigger,) = trap.shouldRespond(dataArray);
        assertFalse(shouldTrigger);
    }
    
    function test_BalanceDrop() public {
        // Mock stable balances for original vaults first
        SuddenBalanceDropTrap.VaultInfo[] memory vaults = trap.getMonitoredVaults();
        for (uint256 i = 0; i < vaults.length; i++) {
            vm.mockCall(
                vaults[i].token,
                abi.encodeWithSignature("balanceOf(address)", vaults[i].vault),
                abi.encode(100000e6) // 100k tokens (stable)
            );
        }
        
        // Add test vault and mock initial high balance
        trap.addMonitoredVault(TEST_VAULT, TEST_TOKEN);
        
        vm.mockCall(
            TEST_TOKEN,
            abi.encodeWithSignature("balanceOf(address)", TEST_VAULT),
            abi.encode(100000e6) // 100k tokens initially
        );
        
        bytes memory data1 = trap.collect();
        
        // Mock balance drop to 80k (20% drop)
        vm.mockCall(
            TEST_TOKEN,
            abi.encodeWithSignature("balanceOf(address)", TEST_VAULT),
            abi.encode(80000e6) // 80k tokens (20% drop)
        );
        
        bytes memory data2 = trap.collect();
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = data2;
        dataArray[1] = data1;
        
        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(dataArray);
        
        assertTrue(shouldTrigger);
        assertTrue(responseData.length > 0);
    }
    
    function test_AddVault() public {
        trap.addMonitoredVault(TEST_VAULT, TEST_TOKEN);
        
        SuddenBalanceDropTrap.VaultInfo[] memory vaults = trap.getMonitoredVaults();
        assertEq(vaults.length, 4);
        assertEq(vaults[3].vault, TEST_VAULT);
        assertEq(vaults[3].token, TEST_TOKEN);
    }
}