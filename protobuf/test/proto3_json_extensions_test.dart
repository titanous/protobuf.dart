// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:test/test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';

// Test extensions for proto3 JSON extension handling
// These mirror the tests from protobuf-es to ensure compatibility

/// Test extension for int32 values
final testInt32Extension = Extension<int>(
  'protobuf_test_messages.proto2.TestAllTypesProto2',
  'testInt32Extension', 
  1001,
  PbFieldType.O3,
);

/// Test extension for string values  
final testStringExtension = Extension<String>(
  'protobuf_test_messages.proto2.TestAllTypesProto2',
  'testStringExtension',
  1002, 
  PbFieldType.OS,
);

/// Test extension for uint64 values
final testUint64Extension = Extension<Int64>(
  'protobuf_test_messages.proto2.TestAllTypesProto2', 
  'testUint64Extension',
  1003,
  PbFieldType.OU6,
);

/// Test extension for bool values
final testBoolExtension = Extension<bool>(
  'protobuf_test_messages.proto2.TestAllTypesProto2',
  'testBoolExtension', 
  1004,
  PbFieldType.OB,
);

void main() {
  group('Proto3 JSON Extensions', () {
    late GeneratedMessage message;
    late ExtensionRegistry registry;
    late TypeRegistry typeRegistry;

    setUp(() {
      // Create a simple test message class for extensions
      message = TestMessage();
      
      // Create extension registry with test extensions
      registry = ExtensionRegistry()
        ..add(testInt32Extension)
        ..add(testStringExtension) 
        ..add(testUint64Extension)
        ..add(testBoolExtension);
        
      typeRegistry = const TypeRegistry.empty();
    });

    group('Extension parsing from JSON', () {
      test('parses int32 extension', () {
        const jsonStr = '{"[protobuf_test_messages.proto2.test_int32_extension]": 42}';
        final decoded = jsonDecode(jsonStr);
        
        message.mergeFromProto3Json(
          decoded,
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(message.getExtension(testInt32Extension), equals(42));
      });

      test('parses string extension', () {
        const jsonStr = '{"[protobuf_test_messages.proto2.test_string_extension]": "hello"}';
        final decoded = jsonDecode(jsonStr);
        
        message.mergeFromProto3Json(
          decoded,
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(message.getExtension(testStringExtension), equals('hello'));
      });

      test('parses uint64 extension', () {
        const jsonStr = '{"[protobuf_test_messages.proto2.test_uint64_extension]": "123456789"}';
        final decoded = jsonDecode(jsonStr);
        
        message.mergeFromProto3Json(
          decoded,
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(message.getExtension(testUint64Extension), equals(Int64(123456789)));
      });

      test('parses bool extension', () {
        const jsonStr = '{"[protobuf_test_messages.proto2.test_bool_extension]": true}';
        final decoded = jsonDecode(jsonStr);
        
        message.mergeFromProto3Json(
          decoded,
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(message.getExtension(testBoolExtension), equals(true));
      });

      test('parses multiple extensions', () {
        const jsonStr = '''
        {
          "[protobuf_test_messages.proto2.test_int32_extension]": 42,
          "[protobuf_test_messages.proto2.test_string_extension]": "world"
        }''';
        final decoded = jsonDecode(jsonStr);
        
        message.mergeFromProto3Json(
          decoded,
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(message.getExtension(testInt32Extension), equals(42));
        expect(message.getExtension(testStringExtension), equals('world'));
      });

      test('handles camelCase to snake_case conversion', () {
        const jsonStr = '{"[protobuf_test_messages.proto2.test_int32_extension]": 123}';
        final decoded = jsonDecode(jsonStr);
        
        message.mergeFromProto3Json(
          decoded,
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(message.getExtension(testInt32Extension), equals(123));
      });

      test('ignores unknown extensions when ignoreUnknownFields is true', () {
        const jsonStr = '{"[unknown.extension]": 42}';
        final decoded = jsonDecode(jsonStr);
        
        expect(() {
          message.mergeFromProto3Json(
            decoded,
            extensionRegistry: registry,
            typeRegistry: typeRegistry,
            ignoreUnknownFields: true,
          );
        }, returnsNormally);
      });

      test('throws on unknown extensions when ignoreUnknownFields is false', () {
        const jsonStr = '{"[unknown.extension]": 42}';
        final decoded = jsonDecode(jsonStr);
        
        expect(() {
          message.mergeFromProto3Json(
            decoded,
            extensionRegistry: registry,
            typeRegistry: typeRegistry,
            ignoreUnknownFields: false,
          );
        }, throwsA(isA<FormatException>()));
      });
    });

    group('Extension serialization to JSON', () {
      test('serializes int32 extension', () {
        message.setExtension(testInt32Extension, 42);
        
        final json = message.toProto3Json(
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(json, containsPair('[protobuf_test_messages.proto2.test_int32_extension]', 42));
      });

      test('serializes string extension', () {
        message.setExtension(testStringExtension, 'hello');
        
        final json = message.toProto3Json(
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(json, containsPair('[protobuf_test_messages.proto2.test_string_extension]', 'hello'));
      });

      test('serializes uint64 extension', () {
        message.setExtension(testUint64Extension, Int64(123456789));
        
        final json = message.toProto3Json(
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(json, containsPair('[protobuf_test_messages.proto2.test_uint64_extension]', '123456789'));
      });

      test('serializes bool extension', () {
        message.setExtension(testBoolExtension, true);
        
        final json = message.toProto3Json(
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(json, containsPair('[protobuf_test_messages.proto2.test_bool_extension]', true));
      });

      test('serializes multiple extensions', () {
        message.setExtension(testInt32Extension, 42);
        message.setExtension(testStringExtension, 'world');
        
        final json = message.toProto3Json(
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(json, containsPair('[protobuf_test_messages.proto2.test_int32_extension]', 42));
        expect(json, containsPair('[protobuf_test_messages.proto2.test_string_extension]', 'world'));
      });

      test('handles snake_case extension names correctly', () {
        message.setExtension(testInt32Extension, 123);
        
        final json = message.toProto3Json(
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        // Should use snake_case in JSON
        expect(json, containsPair('[protobuf_test_messages.proto2.test_int32_extension]', 123));
      });
    });

    group('Round-trip JSON serialization', () {
      test('int32 extension round-trip', () {
        message.setExtension(testInt32Extension, 42);
        
        // Serialize to JSON
        final json = message.toProto3Json(
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        // Create new message and deserialize
        final newMessage = TestMessage();
        newMessage.mergeFromProto3Json(
          json,
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(newMessage.getExtension(testInt32Extension), equals(42));
      });

      test('string extension round-trip', () {
        message.setExtension(testStringExtension, 'test value');
        
        final json = message.toProto3Json(
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        final newMessage = TestMessage();
        newMessage.mergeFromProto3Json(
          json,
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(newMessage.getExtension(testStringExtension), equals('test value'));
      });

      test('multiple extensions round-trip', () {
        message.setExtension(testInt32Extension, 123);
        message.setExtension(testStringExtension, 'hello');
        message.setExtension(testBoolExtension, false);
        
        final json = message.toProto3Json(
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        final newMessage = TestMessage();
        newMessage.mergeFromProto3Json(
          json,
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        expect(newMessage.getExtension(testInt32Extension), equals(123));
        expect(newMessage.getExtension(testStringExtension), equals('hello'));
        expect(newMessage.getExtension(testBoolExtension), equals(false));
      });
    });

    group('Edge cases', () {
      test('handles null extension values', () {
        const jsonStr = '{"[protobuf_test_messages.proto2.test_string_extension]": null}';
        final decoded = jsonDecode(jsonStr);
        
        message.mergeFromProto3Json(
          decoded,
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        // Extension should not be set for null values
        expect(message.hasExtension(testStringExtension), isFalse);
      });

      test('handles empty extension registry', () {
        const jsonStr = '{"[protobuf_test_messages.proto2.test_int32_extension]": 42}';
        final decoded = jsonDecode(jsonStr);
        
        expect(() {
          message.mergeFromProto3Json(
            decoded,
            extensionRegistry: ExtensionRegistry.EMPTY,
            typeRegistry: typeRegistry,
            ignoreUnknownFields: false,
          );
        }, throwsA(isA<FormatException>()));
      });

      test('serializes only set extensions', () {
        // Don't set any extensions
        final json = message.toProto3Json(
          extensionRegistry: registry,
          typeRegistry: typeRegistry,
        );
        
        // Should not contain any extension fields
        final jsonMap = json as Map<String, dynamic>;
        expect(jsonMap.keys.where((key) => key.startsWith('[')), isEmpty);
      });
    });
  });
}

/// Simple test message class for extension testing
class TestMessage extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'TestAllTypesProto2',
    package: const PackageName('protobuf_test_messages.proto2'),
    createEmptyInstance: create,
  );

  TestMessage._();
  
  factory TestMessage() => create();
  
  static TestMessage create() => TestMessage._();
  
  @override
  BuilderInfo get info_ => _i;
  
  @override
  TestMessage createEmptyInstance() => create();
  
  @override
  TestMessage clone() => create()..mergeFromMessage(this);
}