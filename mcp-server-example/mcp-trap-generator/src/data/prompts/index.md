# Drosera AI Trap Generation Prompts

This directory contains comprehensive prompts and guides for AI-assisted Drosera Trap generation. These prompts are designed to be used by the MCP server to help Claude understand and generate high-quality Drosera Traps.

## Available Prompts

### 1. [Main Trap Generation Prompt](./trap-generation-prompt.md)

The primary prompt that defines Claude's role as a Trap generation assistant. Includes:

- Core concepts and ITrap interface
- Execution flow and architecture
- Implementation rules and best practices
- Standard trap structure template
- Integration with response contracts

### 2. [Trap Testing Guide](./trap-testing-guide.md)

Comprehensive testing guidance for Drosera Traps. Covers:

- Testing philosophy and simulation approach
- Essential test categories with examples
- Testing patterns by trap type
- Fork testing strategies
- Common testing mistakes to avoid

### 3. [Quick Reference Guide](./quick-reference.md)

A concise reference for trap developers containing:

- Essential checklists
- Code templates
- Common pitfalls and solutions
- Gas optimization tips
- Testing commands
- Decision criteria for triggering

## How to Use These Prompts

### For MCP Server Integration

1. **Primary Context**: Load `trap-generation-prompt.md` as the main context when users request trap generation
2. **Testing Context**: Include `trap-testing-guide.md` when users ask about testing
3. **Quick Help**: Use `quick-reference.md` for quick answers and reminders

### Example Integration Flow

TODO: Why is this python

```python
# When user asks to create a trap
if "create trap" in user_query or "generate trap" in user_query:
    load_prompt("trap-generation-prompt.md")

    # If specific pattern mentioned
    # if any(pattern in user_query for pattern in ["oracle", "liquidity", "fee", "bridge"]):
    #    load_prompt("common-trap-patterns.md")

    # If testing mentioned
    if "test" in user_query:
        load_prompt("trap-testing-guide.md")
```

## Key Concepts to Emphasize

When using these prompts, ensure the AI understands:
TODO: is this stateless execution confusing? it is technically correct but maybe needs more explanation

1. **Stateless Execution**: Traps are redeployed each block
2. **No Constructor Args**: Configuration must be hardcoded or read from chain
3. **Response Integration**: shouldRespond data must match response_function signature
4. **Gas Efficiency**: Operators pay for execution
5. **Reliability First**: Avoid false positives

## Prompt Maintenance

These prompts should be updated when:

- New trap patterns emerge
- Drosera protocol updates change execution model
- Common user questions reveal gaps
- New testing tools or methods become available

## Additional Resources

Beyond these prompts, the MCP server should also reference:

- `/data/drosera-context/` - Official Drosera documentation
- `/data/trap-examples/` - Example trap implementations
- `/data/protocols/` - Protocol-specific ABIs and data

## Version History

- v1.0 (2025-01-29): Initial prompt set created
  - Main generation prompt
  - Testing guide
  - Common patterns
  - Quick reference

---

These prompts form the foundation for AI-assisted Drosera Trap generation. They should be continuously refined based on user feedback and real-world usage patterns.
