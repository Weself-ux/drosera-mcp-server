// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {MultiTokenBalanceTrap} from "../src/MultiTokenBalanceTrap.sol";

contract MultiTokenBalanceTrapTest is Test {
    MultiTokenBalanceTrap public trap;
    
    address constant TREASURY = 0x742d35cC6634C0532925a3B8d80a6B24C5D06e41;
    address constant OPERATIONS = 0x8Ba1f109551Bd432803012645Aac136C40872A5F;
    
    address constant USDC_TOKEN = 0xa0B86a33e6441fD9Eec086d4E61ef0b5D31a5e7D;
    address constant USDT_TOKEN = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant DAI_TOKEN = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    
    uint256 constant USDC_MIN = 100000e6;
    uint256 constant USDT_MIN = 50000e6;
    uint256 constant DAI_MIN = 75000e18;
    
    function setUp() public {
        trap = new MultiTokenBalanceTrap();
    }
    
    function test_InitialState() public view {
        MultiTokenBalanceTrap.TokenConfig[] memory configs = trap.getMonitoredTokens();
        
        assertEq(configs.length, 3);
        assertEq(configs[0].token, USDC_TOKEN);
        assertEq(configs[0].minBalance, USDC_MIN);
    }
    
    function test_CollectData() public {
        // Mock balances for all monitored tokens
        MultiTokenBalanceTrap.TokenConfig[] memory configs = trap.getMonitoredTokens();
        for (uint256 i = 0; i < configs.length; i++) {
            vm.mockCall(
                configs[i].token,
                abi.encodeWithSignature("balanceOf(address)", configs[i].account),
                abi.encode(200000e6) // High balance
            );
        }
        
        bytes memory data = trap.collect();
        assertTrue(data.length > 0);
        
        MultiTokenBalanceTrap.TokenBalance[] memory balances = 
            abi.decode(data, (MultiTokenBalanceTrap.TokenBalance[]));
        assertEq(balances.length, 3);
    }
    
    function test_NoAlertsWithHighBalances() public {
        // Mock high balances for all tokens
        vm.mockCall(
            USDC_TOKEN,
            abi.encodeWithSignature("balanceOf(address)", TREASURY),
            abi.encode(200000e6) // 200k USDC
        );
        vm.mockCall(
            USDT_TOKEN,
            abi.encodeWithSignature("balanceOf(address)", OPERATIONS),
            abi.encode(100000e6) // 100k USDT
        );
        vm.mockCall(
            DAI_TOKEN,
            abi.encodeWithSignature("balanceOf(address)", TREASURY),
            abi.encode(150000e18) // 150k DAI
        );
        
        bytes memory data = trap.collect();
        bytes[] memory dataArray = new bytes[](1);
        dataArray[0] = data;
        
        (bool shouldTrigger,) = trap.shouldRespond(dataArray);
        assertFalse(shouldTrigger);
    }
    
    function test_AlertWithLowBalance() public {
        // Mock normal balances for other tokens
        MultiTokenBalanceTrap.TokenConfig[] memory configs = trap.getMonitoredTokens();
        for (uint256 i = 0; i < configs.length; i++) {
            if (configs[i].token == USDC_TOKEN) {
                // Mock low balance for USDC
                vm.mockCall(
                    configs[i].token,
                    abi.encodeWithSignature("balanceOf(address)", configs[i].account),
                    abi.encode(50000e6) // 50k USDC (below 100k threshold)
                );
            } else {
                // Mock high balances for others
                vm.mockCall(
                    configs[i].token,
                    abi.encodeWithSignature("balanceOf(address)", configs[i].account),
                    abi.encode(200000e6) // High balance
                );
            }
        }
        
        bytes memory data = trap.collect();
        bytes[] memory dataArray = new bytes[](1);
        dataArray[0] = data;
        
        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(dataArray);
        assertTrue(shouldTrigger);
        assertTrue(responseData.length > 0);
    }
    
    function test_AddToken() public {
        address newToken = 0x1111111111111111111111111111111111111111;
        address newAccount = 0x2222222222222222222222222222222222222222;
        
        trap.addMonitoredToken(newToken, newAccount, 1000e18);
        
        MultiTokenBalanceTrap.TokenConfig[] memory configs = trap.getMonitoredTokens();
        assertEq(configs.length, 4);
        assertEq(configs[3].token, newToken);
        assertEq(configs[3].account, newAccount);
        assertEq(configs[3].minBalance, 1000e18);
    }
}