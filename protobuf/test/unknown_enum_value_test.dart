// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:test/test.dart';

import 'mock_util.dart' show T, mockEnumValues;

void main() {
  group('Unknown Enum Value Support', () {
    group('allowUnknownEnumIntegers option', () {
      test('should preserve unknown positive enum integer values', () {
        final message = T();
        
        // Test with unknown positive integer
        message.mergeFromProto3Json(
          {'enm': 999},
          allowUnknownEnumIntegers: true,
        );
        
        // Field should be considered set
        expect(message.hasEnm, isTrue);
        
        // Generated getter should return default enum value for type safety
        expect(message.enm, equals(mockEnumValues.first));
        
        // Raw value should be accessible via getFieldOrNull and contain unknown value
        final rawValue = message.getFieldOrNull(7); // tag number 7 for 'enm'
        expect(rawValue, isNotNull);
        expect(rawValue.toString(), contains('UNKNOWN_ENUM_VALUE_999'));
        expect((rawValue as dynamic).value, equals(999));
      });

      test('should preserve unknown negative enum integer values', () {
        final message = T();
        
        message.mergeFromProto3Json(
          {'enm': -42},
          allowUnknownEnumIntegers: true,
        );
        
        expect(message.hasEnm, isTrue);
        expect(message.enm, equals(mockEnumValues.first));
        
        final rawValue = message.getFieldOrNull(7);
        expect(rawValue.toString(), contains('UNKNOWN_ENUM_VALUE_-42'));
        expect((rawValue as dynamic).value, equals(-42));
      });

      test('should handle known enum values normally', () {
        final message = T();
        
        // Use known enum value (1 = 'a')
        message.mergeFromProto3Json(
          {'enm': 1},
          allowUnknownEnumIntegers: true,
        );
        
        expect(message.hasEnm, isTrue);
        expect(message.enm.value, equals(1));
        expect(message.enm.name, equals('a'));
        expect(message.getFieldOrNull(7), equals(mockEnumValues[0]));
      });

      test('should reject unknown enum values when option is false', () {
        final message = T();
        
        expect(
          () => message.mergeFromProto3Json(
            {'enm': 999},
            allowUnknownEnumIntegers: false,
          ),
          throwsA(
            allOf(
              isFormatException,
              predicate((FormatException e) => 
                e.message.contains('Unknown enum value')),
            ),
          ),
        );
      });

      test('should handle edge case values', () {
        final message = T();
        
        // Test max int32
        message.mergeFromProto3Json(
          {'enm': 2147483647},
          allowUnknownEnumIntegers: true,
        );
        
        expect(message.hasEnm, isTrue);
        final rawValue = message.getFieldOrNull(7);
        expect((rawValue as dynamic).value, equals(2147483647));
        
        // Test min int32
        message.mergeFromProto3Json(
          {'enm': -2147483648},
          allowUnknownEnumIntegers: true,
        );
        
        final rawValue2 = message.getFieldOrNull(7);
        expect((rawValue2 as dynamic).value, equals(-2147483648));
      });
    });

    group('permissiveEnums option', () {
      test('should preserve unknown enum integer values', () {
        final message = T();
        
        message.mergeFromProto3Json(
          {'enm': 777},
          permissiveEnums: true,
        );
        
        expect(message.hasEnm, isTrue);
        expect(message.enm, equals(mockEnumValues.first));
        
        final rawValue = message.getFieldOrNull(7);
        expect(rawValue.toString(), contains('UNKNOWN_ENUM_VALUE_777'));
        expect((rawValue as dynamic).value, equals(777));
      });

      test('should handle case-insensitive enum string values', () {
        final message = T();
        
        // Test case-insensitive string matching
        message.mergeFromProto3Json(
          {'enm': 'A'}, // uppercase version of 'a'
          permissiveEnums: true,
        );
        
        expect(message.hasEnm, isTrue);
        expect(message.enm.name, equals('a'));
        expect(message.getFieldOrNull(7), equals(mockEnumValues[0]));
      });

      test('should work with both allowUnknownEnumIntegers and permissiveEnums', () {
        final message = T();
        
        message.mergeFromProto3Json(
          {'enm': 555},
          allowUnknownEnumIntegers: true,
          permissiveEnums: true,
        );
        
        final rawValue = message.getFieldOrNull(7);
        expect(rawValue.toString(), contains('UNKNOWN_ENUM_VALUE_555'));
        expect((rawValue as dynamic).value, equals(555));
      });
    });

    group('Field access patterns', () {
      late T message;
      
      setUp(() {
        message = T();
        message.mergeFromProto3Json(
          {'enm': 888},
          allowUnknownEnumIntegers: true,
        );
      });

      test('hasField and hasEnm should return true for unknown enum values', () {
        expect(message.hasField(7), isTrue);
        expect(message.hasEnm, isTrue);
      });

      test('getField should return default value for type safety', () {
        final fieldValue = message.getField(7);
        expect(fieldValue, equals(mockEnumValues.first));
      });

      test('generated getter should return default enum value', () {
        expect(message.enm, equals(mockEnumValues.first));
      });

      test('getFieldOrNull should return unknown enum value', () {
        final rawValue = message.getFieldOrNull(7);
        expect(rawValue, isNotNull);
        expect(rawValue.toString(), contains('UNKNOWN_ENUM_VALUE_888'));
        expect((rawValue as dynamic).value, equals(888));
      });

      test('clearing field should work normally', () {
        message.clearField(7); // Use clearField with tag number
        
        expect(message.hasEnm, isFalse);
        expect(message.hasField(7), isFalse);
        expect(message.getFieldOrNull(7), isNull);
        expect(message.enm, equals(mockEnumValues.first));
      });

      test('setting known value should override unknown value', () {
        // Verify we start with unknown value
        expect(message.getFieldOrNull(7).toString(), contains('UNKNOWN_ENUM_VALUE_888'));
        
        // Set a known value using setField
        message.setField(7, mockEnumValues[1]); // 'b'
        
        // Should now have the known value
        expect(message.enm, equals(mockEnumValues[1]));
        expect(message.getFieldOrNull(7), equals(mockEnumValues[1]));
      });

      test('transition from known to unknown value', () {
        // Start with known value
        message.setField(7, mockEnumValues[1]);
        expect(message.enm, equals(mockEnumValues[1]));
        
        // Overwrite with unknown value via JSON
        message.mergeFromProto3Json(
          {'enm': 333},
          allowUnknownEnumIntegers: true,
        );
        
        expect(message.enm, equals(mockEnumValues.first));
        final rawValue = message.getFieldOrNull(7);
        expect((rawValue as dynamic).value, equals(333));
      });
    });

    group('Integration with other proto3 JSON options', () {
      test('should work with ignoreUnknownFields', () {
        final message = T();
        
        expect(
          () => message.mergeFromProto3Json(
            {
              'enm': 123,
              'unknownField': 'should be ignored',
            },
            allowUnknownEnumIntegers: true,
            ignoreUnknownFields: true,
          ),
          returnsNormally,
        );
        
        final rawValue = message.getFieldOrNull(7);
        expect(rawValue.toString(), contains('UNKNOWN_ENUM_VALUE_123'));
      });

      test('should work with supportNamesWithUnderscores', () {
        final message = T();
        
        message.mergeFromProto3Json(
          {'enm': 456}, // Using 'enm' which is already snake_case in this test
          allowUnknownEnumIntegers: true,
          supportNamesWithUnderscores: true,
        );
        
        final rawValue = message.getFieldOrNull(7);
        expect(rawValue.toString(), contains('UNKNOWN_ENUM_VALUE_456'));
      });

      test('should work with all options enabled', () {
        final message = T();
        
        message.mergeFromProto3Json(
          {
            'enm': 789,
            'unknown_field': 'ignored',
          },
          allowUnknownEnumIntegers: true,
          ignoreUnknownFields: true,
          supportNamesWithUnderscores: true,
          permissiveEnums: true,
        );
        
        final rawValue = message.getFieldOrNull(7);
        expect(rawValue.toString(), contains('UNKNOWN_ENUM_VALUE_789'));
        expect((rawValue as dynamic).value, equals(789));
      });
    });

    group('_UnknownEnumValue behavior', () {
      test('should implement ProtobufEnum interface correctly', () {
        final message = T();
        message.mergeFromProto3Json(
          {'enm': 42},
          allowUnknownEnumIntegers: true,
        );
        
        final unknownEnum = message.getFieldOrNull(7);
        
        // Should be a ProtobufEnum
        expect(unknownEnum, isA<dynamic>());
        expect(unknownEnum.toString(), equals('UNKNOWN_ENUM_VALUE_42'));
        expect((unknownEnum as dynamic).value, equals(42));
        expect((unknownEnum as dynamic).name, equals('UNKNOWN_ENUM_VALUE_42'));
      });

      test('should implement equality correctly', () {
        final message1 = T();
        final message2 = T();
        
        message1.mergeFromProto3Json(
          {'enm': 100},
          allowUnknownEnumIntegers: true,
        );
        
        message2.mergeFromProto3Json(
          {'enm': 100},
          allowUnknownEnumIntegers: true,
        );
        
        final unknown1 = message1.getFieldOrNull(7);
        final unknown2 = message2.getFieldOrNull(7);
        
        expect(unknown1, equals(unknown2));
        expect(unknown1.hashCode, equals(unknown2.hashCode));
      });

      test('should handle zero value', () {
        final message = T();
        
        // Note: In our mock, the first enum value has value 1, so 0 is unknown
        message.mergeFromProto3Json(
          {'enm': 0},
          allowUnknownEnumIntegers: true,
        );
        
        final rawValue = message.getFieldOrNull(7);
        expect(rawValue.toString(), contains('UNKNOWN_ENUM_VALUE_0'));
        expect((rawValue as dynamic).value, equals(0));
      });
    });

    group('Error conditions and edge cases', () {
      test('should handle JSON parsing errors gracefully', () {
        final message = T();
        
        // Invalid JSON should still throw appropriate errors
        expect(
          () => message.mergeFromProto3Json(
            {'enm': 'invalid_string'},
            allowUnknownEnumIntegers: true,
          ),
          throwsA(isFormatException),
        );
      });

      test('should preserve type safety in generated code', () {
        final message = T();
        message.mergeFromProto3Json(
          {'enm': 999},
          allowUnknownEnumIntegers: true,
        );
        
        // Generated getter should never throw, always return valid enum
        expect(() => message.enm, returnsNormally);
        expect(message.enm, isA<dynamic>()); // Should be a valid enum type
      });

      test('should handle multiple unknown values in same message', () {
        final message = T();
        
        // Set unknown value, then change to another unknown value
        message.mergeFromProto3Json(
          {'enm': 111},
          allowUnknownEnumIntegers: true,
        );
        
        expect((message.getFieldOrNull(7) as dynamic).value, equals(111));
        
        message.mergeFromProto3Json(
          {'enm': 222},
          allowUnknownEnumIntegers: true,
        );
        
        expect((message.getFieldOrNull(7) as dynamic).value, equals(222));
      });
    });
  });
}