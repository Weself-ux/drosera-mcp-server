// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {SchedulerTrap} from "../src/SchedulerTrap.sol";

contract SchedulerTrapTest is Test {
    SchedulerTrap public trap;
    
    function setUp() public {
        trap = new SchedulerTrap();
    }
    
    function test_InitialState() public view {
        assertEq(trap.getInterval(), 86400); // 24 hours in seconds
        assertTrue(trap.getNextTriggerTime() > 0);
    }
    
    function test_CollectData() public {
        bytes memory data = trap.collect();
        SchedulerTrap.ScheduleData memory schedule = 
            abi.decode(data, (SchedulerTrap.ScheduleData));
        
        assertEq(schedule.blockNumber, block.number);
        assertEq(schedule.timestamp, block.timestamp);
        assertTrue(schedule.lastTrigger > 0);
    }
    
    function test_TimeUntilNext() public view {
        uint256 timeLeft = trap.timeUntilNext();
        assertTrue(timeLeft <= 86400); // Should be within 24 hours
    }
    
    function test_UpdateTrigger() public {
        uint256 oldTime = trap.getNextTriggerTime();
        
        // Skip forward in time to simulate trigger
        vm.warp(block.timestamp + 86401); // Move forward 24 hours + 1 second
        
        trap.updateLastTrigger();
        uint256 newTime = trap.getNextTriggerTime();
        
        assertTrue(newTime > oldTime);
    }
}