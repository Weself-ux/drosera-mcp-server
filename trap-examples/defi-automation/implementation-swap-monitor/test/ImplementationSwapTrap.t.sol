// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {ImplementationSwapTrap} from "../src/ImplementationSwapTrap.sol";

contract ImplementationSwapTrapTest is Test {
    ImplementationSwapTrap public trap;
    
    address constant UNISWAP_PROXY = 0xEe6A57eC80ea46401049E92587E52f5Ec1c24785;
    address constant COMPOUND_PROXY = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    address constant AAVE_PROXY = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    
    address constant TEST_PROXY = 0x1111111111111111111111111111111111111111;
    address constant OLD_OWNER = 0x2222222222222222222222222222222222222222;
    address constant NEW_OWNER = 0x3333333333333333333333333333333333333333;
    
    function setUp() public {
        trap = new ImplementationSwapTrap();
    }
    
    function test_InitialState() public view {
        ImplementationSwapTrap.ProxyInfo[] memory proxies = trap.getMonitoredProxies();
        assertEq(proxies.length, 3);
        assertEq(proxies[0].proxy, UNISWAP_PROXY);
        assertEq(proxies[1].proxy, COMPOUND_PROXY);
        assertEq(proxies[2].proxy, AAVE_PROXY);
    }
    
    function test_CollectData() public {
        // Mock owner/admin responses for all monitored proxies
        ImplementationSwapTrap.ProxyInfo[] memory proxies = trap.getMonitoredProxies();
        for (uint256 i = 0; i < proxies.length; i++) {
            if (proxies[i].hasOwner) {
                vm.mockCall(
                    proxies[i].proxy,
                    abi.encodeWithSignature("owner()"),
                    abi.encode(OLD_OWNER)
                );
            }
            if (proxies[i].hasAdmin) {
                vm.mockCall(
                    proxies[i].proxy,
                    abi.encodeWithSignature("admin()"),
                    abi.encode(OLD_OWNER)
                );
            }
        }
        
        bytes memory data = trap.collect();
        assertTrue(data.length > 0);
        
        ImplementationSwapTrap.ProxyState[] memory states = 
            abi.decode(data, (ImplementationSwapTrap.ProxyState[]));
        assertEq(states.length, 3);
    }
    
    function test_NoChanges() public {
        // Mock stable owner/admin for all proxies
        ImplementationSwapTrap.ProxyInfo[] memory proxies = trap.getMonitoredProxies();
        for (uint256 i = 0; i < proxies.length; i++) {
            if (proxies[i].hasOwner) {
                vm.mockCall(
                    proxies[i].proxy,
                    abi.encodeWithSignature("owner()"),
                    abi.encode(OLD_OWNER)
                );
            }
            if (proxies[i].hasAdmin) {
                vm.mockCall(
                    proxies[i].proxy,
                    abi.encodeWithSignature("admin()"),
                    abi.encode(OLD_OWNER)
                );
            }
        }
        
        bytes memory data1 = trap.collect();
        bytes memory data2 = trap.collect();
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = data2;
        dataArray[1] = data1;
        
        (bool shouldTrigger,) = trap.shouldRespond(dataArray);
        assertFalse(shouldTrigger);
    }
    
    function test_OwnerChange() public {
        // Mock existing proxies first
        ImplementationSwapTrap.ProxyInfo[] memory proxies = trap.getMonitoredProxies();
        for (uint256 i = 0; i < proxies.length; i++) {
            if (proxies[i].hasOwner) {
                vm.mockCall(
                    proxies[i].proxy,
                    abi.encodeWithSignature("owner()"),
                    abi.encode(OLD_OWNER)
                );
            }
            if (proxies[i].hasAdmin) {
                vm.mockCall(
                    proxies[i].proxy,
                    abi.encodeWithSignature("admin()"),
                    abi.encode(OLD_OWNER)
                );
            }
        }
        
        // Add test proxy and mock initial owner
        trap.addMonitoredProxy(TEST_PROXY, true, false);
        
        vm.mockCall(
            TEST_PROXY,
            abi.encodeWithSignature("owner()"),
            abi.encode(OLD_OWNER)
        );
        
        bytes memory data1 = trap.collect();
        
        // Mock owner change
        vm.mockCall(
            TEST_PROXY,
            abi.encodeWithSignature("owner()"),
            abi.encode(NEW_OWNER)
        );
        
        bytes memory data2 = trap.collect();
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = data2;
        dataArray[1] = data1;
        
        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(dataArray);
        
        assertTrue(shouldTrigger);
        assertTrue(responseData.length > 0);
        
        ImplementationSwapTrap.ProxyChange[] memory changes = 
            abi.decode(responseData, (ImplementationSwapTrap.ProxyChange[]));
        
        assertEq(changes.length, 1);
        assertEq(changes[0].proxy, TEST_PROXY);
        assertEq(changes[0].oldOwner, OLD_OWNER);
        assertEq(changes[0].newOwner, NEW_OWNER);
    }
    
    function test_AdminChange() public {
        // Mock existing proxies first
        ImplementationSwapTrap.ProxyInfo[] memory proxies = trap.getMonitoredProxies();
        for (uint256 i = 0; i < proxies.length; i++) {
            if (proxies[i].hasOwner) {
                vm.mockCall(
                    proxies[i].proxy,
                    abi.encodeWithSignature("owner()"),
                    abi.encode(OLD_OWNER)
                );
            }
            if (proxies[i].hasAdmin) {
                vm.mockCall(
                    proxies[i].proxy,
                    abi.encodeWithSignature("admin()"),
                    abi.encode(OLD_OWNER)
                );
            }
        }
        
        // Add test proxy with admin monitoring
        trap.addMonitoredProxy(TEST_PROXY, false, true);
        
        vm.mockCall(
            TEST_PROXY,
            abi.encodeWithSignature("admin()"),
            abi.encode(OLD_OWNER)
        );
        
        bytes memory data1 = trap.collect();
        
        // Mock admin change
        vm.mockCall(
            TEST_PROXY,
            abi.encodeWithSignature("admin()"),
            abi.encode(NEW_OWNER)
        );
        
        bytes memory data2 = trap.collect();
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = data2;
        dataArray[1] = data1;
        
        (bool shouldTrigger, bytes memory responseData) = trap.shouldRespond(dataArray);
        
        assertTrue(shouldTrigger);
        assertTrue(responseData.length > 0);
    }
    
    function test_AddProxy() public {
        trap.addMonitoredProxy(TEST_PROXY, true, false);
        
        ImplementationSwapTrap.ProxyInfo[] memory proxies = trap.getMonitoredProxies();
        assertEq(proxies.length, 4);
        assertEq(proxies[3].proxy, TEST_PROXY);
        assertTrue(proxies[3].hasOwner);
        assertFalse(proxies[3].hasAdmin);
    }
}