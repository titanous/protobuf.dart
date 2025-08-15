#!/usr/bin/env dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:protobuf/protobuf.dart';
import 'package:conformance_runner/src/generated/conformance/conformance.pb.dart';
import 'package:conformance_runner/src/generated/google/protobuf/test_messages_proto2.pb.dart';
import 'package:conformance_runner/src/generated/google/protobuf/test_messages_proto3.pb.dart';
import 'package:conformance_runner/src/generated/google/protobuf/test_messages_edition2023.pb.dart';
import 'package:conformance_runner/src/generated/google/protobuf/test_messages_proto2_editions.pb.dart'
    as proto2_editions;
import 'package:conformance_runner/src/generated/google/protobuf/test_messages_proto3_editions.pb.dart'
    as proto3_editions;
import 'package:conformance_runner/src/generated/google/protobuf/any.pb.dart';
import 'package:conformance_runner/src/generated/google/protobuf/duration.pb.dart';
import 'package:conformance_runner/src/generated/google/protobuf/timestamp.pb.dart';
import 'package:conformance_runner/src/generated/google/protobuf/field_mask.pb.dart';
import 'package:conformance_runner/src/generated/google/protobuf/struct.pb.dart';
import 'package:conformance_runner/src/generated/google/protobuf/wrappers.pb.dart';

// TypeRegistry containing all message types that might be wrapped in Any
final _typeRegistry = TypeRegistry([
  // Test message types
  TestAllTypesProto2(),
  TestAllTypesProto3(),
  TestAllTypesEdition2023(),
  proto2_editions.TestAllTypesProto2(),
  proto3_editions.TestAllTypesProto3(),

  // Well-known types
  Any(),
  Duration(),
  Timestamp(),
  FieldMask(),
  Struct(),
  Value(),
  ListValue(),

  // Wrapper types
  BoolValue(),
  BytesValue(),
  DoubleValue(),
  FloatValue(),
  Int32Value(),
  Int64Value(),
  StringValue(),
  UInt32Value(),
  UInt64Value(),
]);

void main() {
  // Process conformance test requests until EOF
  while (true) {
    if (!testIo(test)) {
      break;
    }
  }
}

/// Process a single conformance test request
ConformanceResponse test(ConformanceRequest request) {
  final response = ConformanceResponse();

  // Handle FailureSet request (first request from test runner)
  if (request.messageType == 'conformance.FailureSet') {
    final failureSet = FailureSet();
    response.protobufPayload = failureSet.writeToBuffer();
    return response;
  }

  // Get the message type to parse
  GeneratedMessage? message;
  switch (request.messageType) {
    case 'protobuf_test_messages.proto2.TestAllTypesProto2':
      message = TestAllTypesProto2();
      break;
    case 'protobuf_test_messages.proto3.TestAllTypesProto3':
      message = TestAllTypesProto3();
      break;
    case 'protobuf_test_messages.editions.TestAllTypesEdition2023':
      message = TestAllTypesEdition2023();
      break;
    case 'protobuf_test_messages.editions.proto2.TestAllTypesProto2':
      message = proto2_editions.TestAllTypesProto2();
      break;
    case 'protobuf_test_messages.editions.proto3.TestAllTypesProto3':
      message = proto3_editions.TestAllTypesProto3();
      break;
    default:
      response.runtimeError = 'Unknown message type: ${request.messageType}';
      return response;
  }

  // Parse the input payload
  try {
    switch (request.whichPayload()) {
      case ConformanceRequest_Payload.protobufPayload:
        message.mergeFromBuffer(request.protobufPayload);
        break;
      case ConformanceRequest_Payload.jsonPayload:
        // Parse using proto3 JSON format
        try {
          final decoded = jsonDecode(request.jsonPayload);
          message.mergeFromProto3Json(
            decoded,
            typeRegistry: _typeRegistry,
            ignoreUnknownFields: request.testCategory ==
                TestCategory.JSON_IGNORE_UNKNOWN_PARSING_TEST,
            supportNamesWithUnderscores: true,
            allowUnknownEnumIntegers: true,
          );
        } catch (e) {
          response.parseError = e.toString();
          return response;
        }
        break;
      case ConformanceRequest_Payload.jspbPayload:
        response.skipped = 'JSPB not supported';
        return response;
      case ConformanceRequest_Payload.textPayload:
        response.skipped = 'Text format not supported';
        return response;
      case ConformanceRequest_Payload.notSet:
        response.runtimeError = 'No payload provided';
        return response;
    }
  } catch (e) {
    response.parseError = e.toString();
    return response;
  }

  // Serialize to the requested output format
  try {
    switch (request.requestedOutputFormat) {
      case WireFormat.PROTOBUF:
        response.protobufPayload = message.writeToBuffer();
        return response;
      case WireFormat.JSON:
        final proto3Json = message.toProto3Json(typeRegistry: _typeRegistry);
        response.jsonPayload = jsonEncode(proto3Json);
        return response;
      case WireFormat.JSPB:
        response.skipped = 'JSPB not supported';
        return response;
      case WireFormat.TEXT_FORMAT:
        response.skipped = 'Text format not supported';
        return response;
      case WireFormat.UNSPECIFIED:
        response.runtimeError = 'Unspecified output format';
        return response;
    }
  } catch (e) {
    response.serializeError = e.toString();
    return response;
  }

  // Should never reach here, but Dart requires a return
  response.runtimeError = 'Unexpected error';
  return response;
}

/// Read and write conformance test messages using the binary protocol
/// Returns true if test ran successfully, false on legitimate EOF
bool testIo(ConformanceResponse Function(ConformanceRequest) testFunc) {
  // Read the 4-byte length prefix
  final lengthBytes = readBytes(4);
  if (lengthBytes == null) {
    return false; // EOF
  }

  final requestLength =
      ByteData.view(lengthBytes.buffer).getUint32(0, Endian.little);

  // Read the request
  final requestBytes = readBytes(requestLength);
  if (requestBytes == null) {
    throw Exception('Failed to read request');
  }

  // Parse the request
  final request = ConformanceRequest.fromBuffer(requestBytes);

  // Process the test
  final response = testFunc(request);

  // Write the response
  final responseBytes = response.writeToBuffer();
  final responseLengthBytes = Uint8List(4);
  ByteData.view(responseLengthBytes.buffer)
      .setUint32(0, responseBytes.length, Endian.little);

  stdout.add(responseLengthBytes);
  stdout.add(responseBytes);

  return true;
}

/// Read exactly n bytes from stdin, or null on EOF
Uint8List? readBytes(int n) {
  final buffer = Uint8List(n);
  int offset = 0;

  while (offset < n) {
    final byte = stdin.readByteSync();
    if (byte == -1) {
      if (offset == 0) {
        return null; // EOF
      }
      throw Exception('Premature EOF on stdin');
    }
    buffer[offset++] = byte;
  }

  return buffer;
}
