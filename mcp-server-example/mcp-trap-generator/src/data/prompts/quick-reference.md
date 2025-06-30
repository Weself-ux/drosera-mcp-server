# Drosera Trap Development Quick Reference

## Essential Checklist for Trap Development

### ✅ Before You Start

- [ ] Understand what condition should trigger the trap
- [ ] Identify which contracts/protocols to monitor
- [ ] Determine appropriate response action
- [ ] Choose monitoring pattern (threshold, time-based, state change, etc.)

### ✅ Implementation Checklist

- [ ] Implement ITrap interface (collect() and shouldRespond())
- [ ] No constructor parameters (use hardcoded values or read from contracts)
- [ ] Handle all external calls with try-catch
- [ ] Use structs for organized data
- [ ] Ensure collect() is view (no state changes)
- [ ] Ensure shouldRespond() is pure (no state access)
- [ ] Return proper response data format matching response_function

### ✅ Testing Checklist

- [ ] Test constructor initialization
- [ ] Test collect() with mocked external calls
- [ ] Test shouldRespond() positive cases (should trigger)
- [ ] Test shouldRespond() negative cases (should not trigger)
- [ ] Test response data encoding/format
- [ ] Fork test with real mainnet data (optional)

### ✅ Configuration Checklist

- [ ] Create drosera.toml with correct network and chain_id
- [ ] Set response_contract address
- [ ] Define response_function with correct signature
- [ ] Configure appropriate cooldown period

## Quick Code Templates

### Minimal Trap Structure

```solidity
contract MyTrap is ITrap {
    address[] public monitoredAddresses;

    constructor() {
        // TODO: not sure if this is how we should specify this
        monitoredAddresses.push(0x...);
    }

    function collect() external view override returns (bytes memory) {
        // Gather data from blockchain
        return abi.encode(data);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length == 0) return (false, "");
        // Analyze data and return (shouldTrigger, responseData)
        return (false, "");
    }
}
```

### Common Patterns

**Try-Catch for External Calls:**

```solidity
try IContract(addr).getValue() returns (uint256 value) {
    // Handle success
} catch {
    // Handle failure gracefully
}
```

**Response Data Encoding:**
TODO: does this seem fine to specify?

```solidity
// For response_function = "pauseAddresses(address[])"
return (true, abi.encode(addressesToPause));

// For response_function = "updateThreshold(uint256)"
return (true, abi.encode(newThreshold));
```

**Time-based Checks:**
TODO: not sure this is needeed to specify

```solidity
uint256 staleness = block.timestamp - lastUpdate;
if (staleness > MAX_STALENESS) {
    // Trigger response
}
```

## Common Pitfalls and Solutions

| Pitfall                      | Solution                                        |
| ---------------------------- | ----------------------------------------------- |
| Using constructor arguments  | Hardcode values or read from external contracts |
| Storing state between blocks | Design stateless - each block is independent    |
| Not handling call failures   | Always use try-catch for external calls         |
| Wrong response data format   | Match response_function signature exactly       |

TODO: this could be confusing, collect can be leveraged for whatever
| Complex collect() logic | Keep it simple - just gather data |
TODO: Not sure that this is needed to specify
| Assuming data array has items | Always check `if (data.length == 0)` |

## Gas Optimization Tips

1. **Pre-allocate arrays**: `new Type[](knownSize)`
2. **Minimize loops**: Batch operations where possible
3. **Avoid repeated external calls**: Cache results in memory
4. **Use efficient encoding**: Pack structs efficiently
5. **Early returns**: Exit early when trigger conditions met

## Response Function Examples

```toml
# Pause single address
response_function = "pause(address)"

# Pause multiple addresses
response_function = "pauseAddresses(address[])"

# Update parameter
response_function = "setThreshold(uint256)"

# Complex response
response_function = "handleIncident(address,uint256,bytes)"
```

## Testing Commands

```bash
# Run all tests
forge test

# Run specific test
forge test --match-test testShouldRespond

# Run with verbosity
forge test -vvv

# Fork test
forge test --fork-url $ETH_RPC_URL

# Gas report
forge test --gas-report
```

## Deployment Flow

1. **Develop**: Write trap contract implementing ITrap
2. **Test**: Comprehensive unit and integration tests
3. **Configure**: Create drosera.toml with response settings
4. **Deploy**: Use Drosera CLI to deploy trap
5. **Monitor**: Operators begin executing your trap
6. **Maintain**: Update trap logic as needed

## When to Trigger vs Not Trigger

TODO: Not sure that this is needed, seems like it could be confusing and optimize for something when it shouldnt

### ✅ Trigger When:

- Threshold clearly exceeded
- Time limit definitively passed
- Unauthorized state change detected
- Multiple correlated indicators align
- High confidence of actual incident

### ❌ Don't Trigger When:

- Data temporarily unavailable
- Minor fluctuations within normal range
- Single indicator without corroboration
- During known maintenance windows
- Low confidence or ambiguous signals

## Remember

- **Reliability > Complexity**: Simple, reliable traps are better than complex ones
- **False Positives = Bad**: Better to miss edge cases than trigger incorrectly
- **Test Thoroughly**: Your trap protects real money - test every scenario
- **Monitor Gas**: Operators pay gas costs - be efficient
- **Document Clearly**: Help others understand your trap's purpose and logic

## Need Help?

- Review example traps in `/trap-examples/`
- Check the comprehensive guides in `/data/prompts/`
- Test against mainnet forks for real-world validation
- Consider edge cases and failure modes carefully
