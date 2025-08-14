@README.md

# Protobuf Conformance Test Fixing Guide

This guide provides instructions for systematically fixing protobuf conformance test failures.

## Systematic Fix Process

**IMPORTANT**: Always follow this exact process for each fix:

1. **One Issue at a Time**: Fix only one category of failures at a time
2. **Test After Each Fix**: Run conformance tests after implementing each fix
3. **Update Failing Tests**: Remove fixed tests from `failing_tests.txt`
4. **Clean Up**: Format code and run lints before committing
5. **Commit Each Fix**: Make a separate commit for each completed fix

## How to Approach Fixes

Use the checklist in `conformance_test_failures_checklist.md` to pick the next category to work on. Refer to `failing_tests.txt` for the current list of failing tests.

### General Fix Process Example

**Steps**:

1. Analyze the failing tests and understand the expected behavior
2. Implement the fix in the relevant source files
3. Run `make generate` to rebuild protoc_plugin and generate dart protobuf code.
4. Run tests: `./run_tests.sh`
5. Remove fixed tests from `failing_tests.txt`
6. Clean up and commit:
   ```bash
   dart format .
   dart analyze
   git add .
   git commit -m "[type]: [concise description of fix]"
   ```

### Debugging Tips

- Compare implementation with `../protobuf-es` reference implementation
- Use test names to understand what functionality is being tested
- Check error messages in conformance test output for clues
- Focus on one test pattern at a time (e.g., all JSON input tests, all binary tests)
- Look for patterns in failing test names to group related issues
- Do not overfit to the test, create a generic solution that solves the general problem
- Never hard-code or use test names or values in fix code

## Testing Commands

```bash
# Rebuild protoc_plugin and dart protobuf code
make generate

# Run conformance tests
./run_tests.sh

# Format code
dart format .

# Run static analysis
dart analyze
```

## Progress Tracking

- Always check `failing_tests.txt` before and after each fix to track progress
- Use `conformance_test_failures_checklist.md` to mark completed categories
- Reference implementation: `../protobuf-es/packages/protobuf/src/`
- Keep commits focused and descriptive
- Test thoroughly before moving to the next fix

## Common File Locations

- Main protobuf library: `../protobuf/lib/src/protobuf/`
- JSON handling: `../protobuf/lib/src/protobuf/proto3_json.dart`
- Well-known types: `../protobuf/lib/src/protobuf/mixins/well_known.dart`
- Wire format: `../protobuf/lib/src/protobuf/coded_buffer_*.dart`
- Conformance runner: `bin/conformance_test_runner.dart`
