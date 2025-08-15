#!/bin/bash

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[ℹ]${NC} $1"
}

# Track overall success
OVERALL_SUCCESS=true

# Change to project root
cd "$PROJECT_ROOT"

# 1. Run dart analyze on protobuf with all messages fatal
print_info "Running dart analyze on protobuf..."
cd protobuf
if dart analyze --fatal-infos --fatal-warnings; then
    print_status "protobuf analysis passed"
else
    print_error "protobuf analysis failed"
    OVERALL_SUCCESS=false
fi
cd "$PROJECT_ROOT"

# 2. Run dart analyze on protoc_plugin with all messages fatal
print_info "Running dart analyze on protoc_plugin..."
cd protoc_plugin
if dart analyze --fatal-infos --fatal-warnings; then
    print_status "protoc_plugin analysis passed"
else
    print_error "protoc_plugin analysis failed"
    OVERALL_SUCCESS=false
fi
cd "$PROJECT_ROOT"

# 3. Check formatting of all modified files
print_info "Checking formatting of modified files..."

# Get list of modified Dart files (staged and unstaged)
MODIFIED_FILES=$(git diff --name-only --diff-filter=ACMR HEAD -- '*.dart' && git diff --cached --name-only --diff-filter=ACMR HEAD -- '*.dart' | sort -u)

if [ -z "$MODIFIED_FILES" ]; then
    print_status "No modified Dart files to check"
else
    FORMAT_ISSUES=""
    for file in $MODIFIED_FILES; do
        if [ -f "$file" ]; then
            if ! dart format --set-exit-if-changed --output=none "$file" 2>/dev/null; then
                FORMAT_ISSUES="$FORMAT_ISSUES$file\n"
            fi
        fi
    done
    
    if [ -z "$FORMAT_ISSUES" ]; then
        print_status "All modified files are properly formatted"
    else
        print_error "The following files need formatting:"
        echo -e "$FORMAT_ISSUES"
        print_info "Run 'dart format .' to fix formatting issues"
        OVERALL_SUCCESS=false
    fi
fi

# 4. Run dart test on protobuf
print_info "Running tests for protobuf..."
cd protobuf
if dart test --reporter=expanded 2>&1 | tail -1 | grep -q "All tests passed"; then
    print_status "protobuf tests passed"
else
    print_error "protobuf tests failed"
    OVERALL_SUCCESS=false
fi
cd "$PROJECT_ROOT"

# 5. Run dart test on protoc_plugin
print_info "Running tests for protoc_plugin..."
cd protoc_plugin
if dart test --reporter=expanded 2>&1 | tail -1 | grep -q "All tests passed"; then
    print_status "protoc_plugin tests passed"
else
    print_error "protoc_plugin tests failed"
    OVERALL_SUCCESS=false
fi
cd "$PROJECT_ROOT"

# 6. Run make generate in conformance_runner
print_info "Running make generate in conformance_runner..."
cd conformance_runner
if make generate > /dev/null 2>&1; then
    print_status "make generate completed successfully"
else
    print_error "make generate failed"
    OVERALL_SUCCESS=false
fi

# 7. Run ./run_tests.sh in conformance_runner
print_info "Running conformance tests..."
if [ -f "./run_tests.sh" ]; then
    # Capture the output and only show the summary
    CONFORMANCE_OUTPUT=$(./run_tests.sh 2>&1)
    CONFORMANCE_EXIT_CODE=$?
    
    # Extract just the conformance suite summary line
    SUMMARY=$(echo "$CONFORMANCE_OUTPUT" | grep "CONFORMANCE SUITE")
    
    if [ $CONFORMANCE_EXIT_CODE -eq 0 ]; then
        print_status "Conformance tests passed"
        if [ -n "$SUMMARY" ]; then
            echo "  $SUMMARY"
        fi
    else
        print_error "Conformance tests failed"
        if [ -n "$SUMMARY" ]; then
            echo "  $SUMMARY"
        fi
        OVERALL_SUCCESS=false
    fi
else
    print_error "run_tests.sh not found in conformance_runner"
    OVERALL_SUCCESS=false
fi
cd "$PROJECT_ROOT"

# Final summary
echo ""
if [ "$OVERALL_SUCCESS" = true ]; then
    print_status "All checks passed successfully!"
    exit 0
else
    print_error "Some checks failed. Please review the output above."
    exit 1
fi