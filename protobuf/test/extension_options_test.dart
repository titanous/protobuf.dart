// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:protobuf/protobuf.dart';
import 'package:protobuf/src/protobuf/extension_options.dart';
import 'package:test/test.dart';

// Mock FieldOptions for testing
class MockFieldOptions extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'MockFieldOptions',
    package: const PackageName('test'),
    createEmptyInstance: () => MockFieldOptions._(),
  );
  
  @override
  BuilderInfo get info_ => _i;
  
  MockFieldOptions._();
  
  factory MockFieldOptions() => create();
  
  static MockFieldOptions create() => MockFieldOptions._();
  
  @override
  MockFieldOptions createEmptyInstance() => create();
  
  @override
  MockFieldOptions clone() => MockFieldOptions._()..mergeFromMessage(this);
  
  factory MockFieldOptions.fromBuffer(List<int> bytes, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) {
    final result = create();
    result.mergeFromBuffer(bytes, r);
    return result;
  }
}

// Mock extension with options
class MockExtension {
  static final testExtension = Extension<String>(
    'TestMessage',
    'testField',
    1000,
    PbFieldType.OS,
    defaultOrMaker: '',
    optionsBytes: [1, 2, 3, 4, 5], // Sample bytes
  );
  
  static final extensionWithoutOptions = Extension<int>(
    'TestMessage',
    'noOptionsField',
    1001,
    PbFieldType.O3,
    defaultOrMaker: 0,
  );
}

void main() {
  group('Extension Options', () {
    test('Extension with optionsBytes stores bytes correctly', () {
      final ext = MockExtension.testExtension;
      expect(ext.optionsBytes, isNotNull);
      expect(ext.optionsBytes, equals([1, 2, 3, 4, 5]));
    });
    
    test('Extension without optionsBytes has null options', () {
      final ext = MockExtension.extensionWithoutOptions;
      expect(ext.optionsBytes, isNull);
    });
    
    test('getExtensionOptions returns null for extension without options', () {
      final ext = MockExtension.extensionWithoutOptions;
      final options = getExtensionOptions(
        ext,
        (bytes, registry) => MockFieldOptions.fromBuffer(bytes, registry),
        ExtensionRegistry(),
      );
      expect(options, isNull);
    });
    
    test('getExtensionOptions returns null for empty optionsBytes', () {
      // Empty bytes are treated as no options
      final ext = Extension<String>(
        'TestMessage',
        'testField',
        1000,
        PbFieldType.OS,
        defaultOrMaker: '',
        optionsBytes: [], // Empty bytes
      );
      final options = getExtensionOptions(
        ext,
        (bytes, registry) => MockFieldOptions.fromBuffer(bytes, registry),
        ExtensionRegistry(),
      );
      // Empty bytes are treated as no options
      expect(options, isNull);
    });
    
    test('getExtensionOptions deserializes non-empty valid protobuf bytes', () {
      // Use minimal valid protobuf bytes (field 1, varint 0)
      final ext = Extension<String>(
        'TestMessage',
        'testField',
        1000,
        PbFieldType.OS,
        defaultOrMaker: '',
        optionsBytes: [8, 0], // Field 1 = 0 (valid protobuf)
      );
      final options = getExtensionOptions(
        ext,
        (bytes, registry) => MockFieldOptions.fromBuffer(bytes, registry),
        ExtensionRegistry(),
      );
      expect(options, isNotNull);
      expect(options, isA<MockFieldOptions>());
    });
    
    test('hasOption returns false for extension without options', () {
      final ext = MockExtension.extensionWithoutOptions;
      final testOption = Extension<bool>('FieldOptions', 'test', 2000, PbFieldType.OB);
      final result = hasOption(
        ext,
        testOption,
        (bytes, registry) => MockFieldOptions.fromBuffer(bytes, registry),
        ExtensionRegistry(),
      );
      expect(result, isFalse);
    });
    
    test('getOption returns null for extension without options', () {
      final ext = MockExtension.extensionWithoutOptions;
      final testOption = Extension<String>('FieldOptions', 'test', 2000, PbFieldType.OS);
      final result = getOption(
        ext,
        testOption,
        (bytes, registry) => MockFieldOptions.fromBuffer(bytes, registry),
        ExtensionRegistry(),
      );
      expect(result, isNull);
    });
    
    test('getOptionWithDefault returns default for extension without options', () {
      final ext = MockExtension.extensionWithoutOptions;
      final testOption = Extension<String>('FieldOptions', 'test', 2000, PbFieldType.OS);
      final result = getOptionWithDefault(
        ext,
        testOption,
        'default_value',
        (bytes, registry) => MockFieldOptions.fromBuffer(bytes, registry),
        ExtensionRegistry(),
      );
      expect(result, equals('default_value'));
    });
  });
  
  group('Extension Constructors', () {
    test('Extension constructor accepts optionsBytes', () {
      final ext = Extension<String>(
        'TestMessage',
        'testField',
        1000,
        PbFieldType.OS,
        defaultOrMaker: '',
        optionsBytes: [10, 20, 30],
      );
      expect(ext.optionsBytes, equals([10, 20, 30]));
    });
    
    test('Extension.repeated constructor accepts optionsBytes', () {
      final ext = Extension<String>.repeated(
        'TestMessage',
        'repeatedField',
        1001,
        PbFieldType.PS,
        check: getCheckFunction(PbFieldType.PS),
        optionsBytes: [40, 50, 60],
      );
      expect(ext.optionsBytes, equals([40, 50, 60]));
    });
    
    test('Extension constructor without optionsBytes has null options', () {
      final ext = Extension<String>(
        'TestMessage',
        'testField',
        1000,
        PbFieldType.OS,
        defaultOrMaker: '',
      );
      expect(ext.optionsBytes, isNull);
    });
  });
}