# Protobuf Conformance Test Runner for Dart

This directory contains the conformance test runner for the Dart protobuf implementation.

## Setup

1. Install dependencies:
   ```bash
   npm install    # Installs conformance test runner
   dart pub get   # Installs Dart dependencies
   ```

2. Generate the protobuf files:
   ```bash
   make generate
   ```

## Running Tests

To run the conformance tests:

```bash
./run_tests.sh
```

Or using npm:

```bash
npm test
```

## Files

- `bin/conformance_test_runner.dart` - The main conformance test runner executable
- `lib/src/generated/` - Generated protobuf files for conformance tests
- `proto/` - Proto files for conformance tests
- `failing_tests.txt` - List of currently failing tests
- `failing_tests_text_format.txt` - List of failing text format tests
- `Makefile` - Build configuration for generating protobuf files
- `run_tests.sh` - Script to run the conformance tests

## Supported Features

- Binary protobuf serialization/deserialization
- JSON serialization/deserialization  
- Proto2 and Proto3 message types

## Unsupported Features

- Text format (returns "skipped")
- JSPB format (returns "skipped")
- Editions (proto files not yet supported by protoc-gen-dart)