#!/bin/bash

# Run the conformance tests
# Requires conformance_test_runner binary from the protobuf project
# 
# To install conformance_test_runner:
# 1. Download from https://github.com/bufbuild/protobuf-conformance/releases
# 2. Or build from source: https://github.com/protocolbuffers/protobuf
# 3. Or install via npm: npm install -g @bufbuild/protobuf-conformance

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RUNNER="$SCRIPT_DIR/bin/conformance_test_runner.dart"
FAILING_TESTS="$SCRIPT_DIR/failing_tests.txt"
TEXT_FORMAT_FAILING_TESTS="$SCRIPT_DIR/failing_tests_text_format.txt"

# Create empty failure lists if they don't exist
touch "$FAILING_TESTS"
touch "$TEXT_FORMAT_FAILING_TESTS"

# Try to find conformance_test_runner
CONFORMANCE_RUNNER=""
if [ -f "$SCRIPT_DIR/node_modules/.bin/conformance_test_runner" ]; then
    CONFORMANCE_RUNNER="$SCRIPT_DIR/node_modules/.bin/conformance_test_runner"
elif command -v conformance_test_runner &> /dev/null; then
    CONFORMANCE_RUNNER="conformance_test_runner"
else
    echo "Error: conformance_test_runner not found"
    echo ""
    echo "To install conformance_test_runner locally:"
    echo "  npm install"
    echo ""
    echo "Or install globally:"
    echo "  npm install -g @bufbuild/protobuf-conformance"
    echo ""
    echo "Or download from:"
    echo "  https://github.com/bufbuild/protobuf-conformance/releases"
    exit 1
fi

echo "Running conformance tests with $CONFORMANCE_RUNNER"
echo "Test runner: $RUNNER"

# Run the tests
$CONFORMANCE_RUNNER \
    --enforce_recommended \
    --failure_list "$FAILING_TESTS" \
    --text_format_failure_list "$TEXT_FORMAT_FAILING_TESTS" \
    --output_dir "$SCRIPT_DIR" \
    "$RUNNER"