// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {TokenSupplyWatchTrap} from "../src/TokenSupplyWatchTrap.sol";

contract TokenSupplyWatchTrapTest is Test {
    TokenSupplyWatchTrap public trap;
    
    address constant USDC_TOKEN = 0xa0B86a33e6441fD9Eec086d4E61ef0b5D31a5e7D;
    address constant USDT_TOKEN = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant DAI_TOKEN = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant TEST_TOKEN = 0x1111111111111111111111111111111111111111;
    
    function setUp() public {
        trap = new TokenSupplyWatchTrap();
    }
    
    function test_InitialState() public view {
        address[] memory tokens = trap.getMonitoredTokens();
        uint256 threshold = trap.getChangeThreshold();
        
        assertEq(tokens.length, 3);
        assertEq(tokens[0], USDC_TOKEN);
        assertEq(tokens[1], USDT_TOKEN);
        assertEq(tokens[2], DAI_TOKEN);
        assertEq(threshold, 500); // 5% in BPS
    }
    
    function test_CollectData() public {
        // Mock token supplies for all monitored tokens
        address[] memory tokens = trap.getMonitoredTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            vm.mockCall(
                tokens[i],
                abi.encodeWithSignature("totalSupply()"),
                abi.encode(1000000000e6) // 1B tokens
            );
        }
        
        bytes memory data = trap.collect();
        assertTrue(data.length > 0);
        
        TokenSupplyWatchTrap.SupplyData[] memory supplies = 
            abi.decode(data, (TokenSupplyWatchTrap.SupplyData[]));
        assertEq(supplies.length, 3);
    }
    
    function test_NoSupplyChanges() public {
        // Mock stable supplies for all tokens
        address[] memory tokens = trap.getMonitoredTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            vm.mockCall(
                tokens[i],
                abi.encodeWithSignature("totalSupply()"),
                abi.encode(1000000000e6) // 1B tokens (stable)
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
    
    function test_SupplyIncrease() public {
        // Mock existing tokens first
        address[] memory tokens = trap.getMonitoredTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            vm.mockCall(
                tokens[i],
                abi.encodeWithSignature("totalSupply()"),
                abi.encode(1000000000e6) // 1B tokens (stable)
            );
        }
        
        // Add test token
        trap.addMonitoredToken(TEST_TOKEN);
        
        // Mock initial supply for test token
        vm.mockCall(
            TEST_TOKEN,
            abi.encodeWithSignature("totalSupply()"),
            abi.encode(100000000e6) // 100M tokens
        );
        
        bytes memory data1 = trap.collect();
        
        // Mock supply increase (10% increase)
        vm.mockCall(
            TEST_TOKEN,
            abi.encodeWithSignature("totalSupply()"),
            abi.encode(110000000e6) // 110M tokens
        );
        
        bytes memory data2 = trap.collect();
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = data2;
        dataArray[1] = data1;
        
        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(dataArray);
        
        assertTrue(shouldTrigger);
        
        TokenSupplyWatchTrap.SupplyChange[] memory changes = 
            abi.decode(responseData, (TokenSupplyWatchTrap.SupplyChange[]));
        
        assertEq(changes.length, 1);
        assertEq(changes[0].token, TEST_TOKEN);
        assertEq(changes[0].oldSupply, 100000000e6);
        assertEq(changes[0].newSupply, 110000000e6);
        assertEq(changes[0].changeBps, 1000); // 10%
        assertTrue(changes[0].isIncrease);
    }
    
    function test_SupplyDecrease() public {
        // Mock existing tokens first
        address[] memory tokens = trap.getMonitoredTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            vm.mockCall(
                tokens[i],
                abi.encodeWithSignature("totalSupply()"),
                abi.encode(1000000000e6) // 1B tokens (stable)
            );
        }
        
        // Add test token
        trap.addMonitoredToken(TEST_TOKEN);
        
        // Mock initial supply
        vm.mockCall(
            TEST_TOKEN,
            abi.encodeWithSignature("totalSupply()"),
            abi.encode(100000000e6)
        );
        
        bytes memory data1 = trap.collect();
        
        // Mock supply decrease (8% decrease)
        vm.mockCall(
            TEST_TOKEN,
            abi.encodeWithSignature("totalSupply()"),
            abi.encode(92000000e6)
        );
        
        bytes memory data2 = trap.collect();
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = data2;
        dataArray[1] = data1;
        
        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(dataArray);
        
        assertTrue(shouldTrigger);
        
        TokenSupplyWatchTrap.SupplyChange[] memory changes = 
            abi.decode(responseData, (TokenSupplyWatchTrap.SupplyChange[]));
        
        assertEq(changes.length, 1);
        assertEq(changes[0].changeBps, 800); // 8%
        assertFalse(changes[0].isIncrease);
    }
    
    function test_SmallChangeIgnored() public {
        // Mock existing tokens first
        address[] memory tokens = trap.getMonitoredTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            vm.mockCall(
                tokens[i],
                abi.encodeWithSignature("totalSupply()"),
                abi.encode(1000000000e6) // 1B tokens (stable)
            );
        }
        
        // Add test token
        trap.addMonitoredToken(TEST_TOKEN);
        
        // Mock initial supply
        vm.mockCall(
            TEST_TOKEN,
            abi.encodeWithSignature("totalSupply()"),
            abi.encode(100000000e6)
        );
        
        bytes memory data1 = trap.collect();
        
        // Mock small supply change (2% increase - below 5% threshold)
        vm.mockCall(
            TEST_TOKEN,
            abi.encodeWithSignature("totalSupply()"),
            abi.encode(102000000e6)
        );
        
        bytes memory data2 = trap.collect();
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = data2;
        dataArray[1] = data1;
        
        (bool shouldTrigger,) = trap.shouldRespond(dataArray);
        assertFalse(shouldTrigger);
    }
    
    function test_SmallAbsoluteChangeIgnored() public {
        // Mock existing tokens first  
        address[] memory tokens = trap.getMonitoredTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            vm.mockCall(
                tokens[i],
                abi.encodeWithSignature("totalSupply()"),
                abi.encode(1000000000e6) // 1B tokens (stable)
            );
        }
        
        // Add test token
        trap.addMonitoredToken(TEST_TOKEN);
        
        // Mock initial supply (small supply)
        vm.mockCall(
            TEST_TOKEN,
            abi.encodeWithSignature("totalSupply()"),
            abi.encode(1000000e6) // 1M tokens
        );
        
        bytes memory data1 = trap.collect();
        
        // Mock large percentage but small absolute change
        vm.mockCall(
            TEST_TOKEN,
            abi.encodeWithSignature("totalSupply()"),
            abi.encode(1100000e6) // 1.1M tokens (10% but only 100k change)
        );
        
        bytes memory data2 = trap.collect();
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = data2;
        dataArray[1] = data1;
        
        (bool shouldTrigger,) = trap.shouldRespond(dataArray);
        assertFalse(shouldTrigger); // Should not trigger due to small absolute change
    }
    
    function test_AddToken() public {
        trap.addMonitoredToken(TEST_TOKEN);
        
        address[] memory tokens = trap.getMonitoredTokens();
        assertEq(tokens.length, 4);
        assertEq(tokens[3], TEST_TOKEN);
    }
}