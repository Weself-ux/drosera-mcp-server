# Drosera Trap Testing Guide

## Understanding Trap Testing

Testing Drosera Traps is unique because:

- Traps simulate what Drosera nodes do off-chain
- Tests verify both monitoring logic AND response data formatting
- You're testing stateless contracts that get redeployed each block in a shadow fork on the Drosera node

## Core Testing Principle

Your Solidity tests simulate the Drosera node's behavior:

TODO: The below should talk about block sample size most likely and how that is related

```solidity
// This is what happens in production:
// 1. Node deploys trap in its local shadow fork
// 2. Node calls collect()
// 3. Node stores data and calls shouldRespond()
// 4. If true, node triggers on-chain response

// Your test simulates this:
trap = new MyTrap();
bytes memory collected = trap.collect();
bytes[] memory dataArray = new bytes[](1);
dataArray[0] = collected;
(bool trigger, bytes memory response) = trap.shouldRespond(dataArray);
```

## Essential Test Categories

### 1. Constructor and Initialization Tests

```solidity
function testConstructorInitialization() public {
    MyTrap testTrap = new MyTrap();

    // Verify initial state
    assertEq(testTrap.getMonitoredAddresses().length, 2);
    assertEq(testTrap.THRESHOLD(), 1000);
    assertEq(testTrap.monitoredAddresses(0), EXPECTED_ADDRESS);
}
```

### 2. Data Collection Tests

Always mock external calls:

```solidity
function testCollectGathersDataCorrectly() public {
    // Mock successful call
    vm.mockCall(
        ORACLE_ADDRESS,
        abi.encodeWithSelector(IAggregator.latestRoundData.selector),
        abi.encode(
            uint80(1),          // roundId
            int256(2000e8),     // price
            uint256(100),       // startedAt
            uint256(200),       // updatedAt
            uint80(1)           // answeredInRound
        )
    );

    bytes memory data = trap.collect();

    // Decode and verify
    OracleData memory decoded = abi.decode(data, OracleData);
    assertEq(decoded.price, 2000e8);
    assertEq(decoded.updatedAt, 200);
}
```

### 3. Trigger Logic Tests

Test both positive and negative cases:

```solidity
function testShouldRespondTriggersWhenConditionMet() public {
    // Create test data that SHOULD trigger
    CollectedData[] memory data = new CollectedData[](1);
    data[0] = CollectedData({
        target: address(0x123),
        value: 2000,  // Above threshold
        timestamp: block.timestamp
    });

    bytes[] memory dataArray = new bytes[](1);
    dataArray[0] = abi.encode(data);

    (bool shouldTrigger, bytes memory response) = trap.shouldRespond(dataArray);

    assertTrue(shouldTrigger, "Should trigger when value exceeds threshold");

    // Verify response data
    Alert[] memory alerts = abi.decode(response, (Alert[]));
    assertEq(alerts.length, 1);
    assertEq(alerts[0].target, address(0x123));
}

function testShouldNotRespondWhenConditionNotMet() public {
    // Create test data that should NOT trigger
    CollectedData[] memory data = new CollectedData[](1);
    data[0] = CollectedData({
        target: address(0x123),
        value: 500,   // Below threshold
        timestamp: block.timestamp
    });

    bytes[] memory dataArray = new bytes[](1);
    dataArray[0] = abi.encode(data);

    (bool shouldTrigger, ) = trap.shouldRespond(dataArray);

    assertFalse(shouldTrigger, "Should not trigger when value below threshold");
}
```

### 4. Edge Case Tests

TODO: below is talking about multiple data points, this would be the case for block sample size being greater than 1. shouldRespond is only called by the operator when it has a full block sample size of data from previous collect() calls. Each collect() call is from a different sequential block, so the dataArray will always contain the most recent data point at index 0, second most recent at index 1 and so on.

```solidity
function testShouldRespondWithMultipleDataPoints() public {
    // Test with historical data (multiple collect() results)
    bytes[] memory dataArray = new bytes[](3);

    // Newest data first
    dataArray[0] = abi.encode(createTestData(1500));
    dataArray[1] = abi.encode(createTestData(1200));
    dataArray[2] = abi.encode(createTestData(900));

    (bool shouldTrigger, ) = trap.shouldRespond(dataArray);

    // Should only analyze newest data
    assertTrue(shouldTrigger);
}
```

### 5. Time-Based Tests

TODO: this example really only works for things related to block.timestamp and block number. Its fine here, but for fork testing you need to actually select the next fork and perform the collects as shown in the aave liqudation trap example fork test.
For traps that monitor time conditions:

```solidity
function testStaleDataDetection() public {
    uint256 currentTime = block.timestamp;

    // Create stale data
    vm.warp(currentTime + 2 hours);

    OracleData[] memory data = new OracleData[](1);
    data[0] = OracleData({
        oracle: ORACLE_ADDRESS,
        price: 2000e8,
        updatedAt: currentTime  // 2 hours old
    });

    bytes[] memory dataArray = new bytes[](1);
    dataArray[0] = abi.encode(data);

    (bool shouldTrigger, ) = trap.shouldRespond(dataArray);

    assertTrue(shouldTrigger, "Should detect stale data");
}
```

### 6. Response Data Validation

Ensure response data matches expected format:

```solidity
function testResponseDataFormat() public {
    // Setup trigger condition
    bytes[] memory dataArray = setupTriggerCondition();

    (bool shouldTrigger, bytes memory response) = trap.shouldRespond(dataArray);

    assertTrue(shouldTrigger);

    // Decode response - must match response_function signature
    address[] memory pauseTargets = abi.decode(response, (address[]));

    // If drosera.toml has: response_function = "pauseAddresses(address[])"
    // Then response must decode to address[]
    assertEq(pauseTargets.length, 1);
    assertEq(pauseTargets[0], EXPECTED_ADDRESS);
}
```

## Testing Patterns for Fork Testing

## Fork Testing

TODO: The aave liquidation trap example shows how to do fork testing properly. This should probably help to understand how to do fork testing in general.
For integration tests on mainnet state:

```solidity
contract MyTrapForkTest is Test {
    MyTrap public trap;
    uint256 mainnetFork;

    function setUp() public {
        mainnetFork = vm.createFork(vm.envString("ETH_RPC_URL"));
        vm.selectFork(mainnetFork);

        trap = new MyTrap();
    }

    function testRealProtocolInteraction() public {
        // Test against actual mainnet contracts
        bytes memory data = trap.collect();

        // Verify real data was collected
        ProtocolData[] memory decoded = abi.decode(data, (ProtocolData[]));
        assertTrue(decoded[0].value > 0, "Should collect real data");
    }
}
```

## Common Testing Mistakes

1. **Forgetting Mock Cleanup**: Use `vm.clearMockedCalls()` between tests
2. **Wrong Response Format**: Response must match `response_function` signature
3. **Not Testing Constructor**: Constructor runs every block - test it thoroughly

## Test Checklist

- [ ] Constructor initializes all required state
- [ ] collect() handles successful external calls
- [ ] shouldRespond() triggers correctly on threshold breach
- [ ] shouldRespond() doesn't trigger below threshold
- [ ] shouldRespond() returns properly formatted response data
- [ ] All getter functions return expected values
- [ ] Time-based logic tested with vm.warp() (if applicable)
- [ ] Fork tests verify real protocol interaction (optional)

## Example: Complete Test Suite Structure

```solidity
contract CompleteTrapTest is Test {
    MyTrap public trap;

    // Test fixtures
    address constant MONITORED_PROTOCOL = address(0x123);
    uint256 constant THRESHOLD = 1000;

    function setUp() public {
        trap = new MyTrap();
    }

    // Initialization tests
    function testConstructor() public { }
    function testGetters() public { }

    // Collection tests
    function testCollectSuccess() public { }
    function testCollectMultipleTargets() public { }

    // Trigger tests
    function testShouldRespondPositive() public { }
    function testShouldRespondNegative() public { }

    // Response format tests
    function testResponseDataEncoding() public { }

    // Integration tests
    function testFullFlow() public { }

    // Helper functions
    function createTestData(uint256 value) internal view returns (CollectedData[] memory) { }
    function setupTriggerCondition() internal returns (bytes[] memory) { }
}
```

Remember: Your tests prove the trap will work correctly when deployed by Drosera nodes. Comprehensive testing prevents false positives and ensures reliable incident response.
