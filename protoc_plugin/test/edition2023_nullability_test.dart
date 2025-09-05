// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'gen_nullable/edition2023_nullability.pb.dart' as nullable;

void main() {
  group('Edition 2023 Nullability', () {
    test('Edition 2023 explicit fields should be nullable with API_LEVEL_NULLABLE', () {
      // This test demonstrates the expected behavior
      // Currently FAILING because edition 2023 is not generating nullable types

      final msg = nullable.TestMessage();

      // Explicit presence fields should be nullable in API_LEVEL_NULLABLE
      // These assertions show what SHOULD be generated but currently isn't

      // String field with explicit presence should return String?
      expect(
        () {
          String? value = msg.explicitString; // Should compile with String?
          expect(value, isNull); // Should be null when not set
        },
        returnsNormally,
        reason:
            'Explicit string field should be nullable (String?) but is currently String',
      );

      // Message field with explicit presence should return TestMessage?
      expect(
        () {
          nullable.TestMessage? value =
              msg.explicitMessage; // Should compile with TestMessage?
          expect(value, isNull); // Should be null when not set
        },
        returnsNormally,
        reason:
            'Explicit message field should be nullable (TestMessage?) but is currently TestMessage',
      );

      // Enum field with explicit presence should return TestEnum?
      expect(
        () {
          nullable.TestEnum? value =
              msg.explicitEnum; // Should compile with TestEnum?
          expect(value, isNull); // Should be null when not set
        },
        returnsNormally,
        reason:
            'Explicit enum field should be nullable (TestEnum?) but is currently TestEnum',
      );
    });

    test('Edition 2023 implicit fields should be non-nullable', () {
      final msg = nullable.TestMessage();

      // Implicit presence fields should be non-nullable (like proto3)

      // String field with implicit presence should return String (not String?)
      String value1 =
          msg.implicitString; // Should compile with non-nullable String
      expect(value1, equals('')); // Default empty string

      // Int field with implicit presence should return int (not int?)
      int value2 = msg.implicitInt32; // Should compile with non-nullable int
      expect(value2, equals(0)); // Default 0

      // Bool field with implicit presence should return bool (not bool?)
      bool value3 = msg.implicitBool; // Should compile with non-nullable bool
      expect(value3, equals(false)); // Default false

      // Enum field with implicit presence should return TestEnum (not TestEnum?)
      nullable.TestEnum value4 =
          msg.implicitEnum; // Should compile with non-nullable enum
      expect(
        value4,
        equals(nullable.TestEnum.TEST_ENUM_UNSPECIFIED),
      ); // Default unspecified
    });

    test('Edition 2023 collections are never nullable', () {
      final msg = nullable.TestMessage();

      // Repeated fields should always be non-nullable List<T>
      List<String> repeatedStrings = msg.repeatedStrings;
      expect(repeatedStrings, isEmpty);
      expect(repeatedStrings, isNotNull);

      List<int> repeatedInts = msg.repeatedInts;
      expect(repeatedInts, isEmpty);
      expect(repeatedInts, isNotNull);

      List<nullable.TestMessage> repeatedMessages = msg.repeatedMessages;
      expect(repeatedMessages, isEmpty);
      expect(repeatedMessages, isNotNull);

      // Maps should always be non-nullable Map<K,V>
      Map<String, String> stringMap = msg.stringMap;
      expect(stringMap, isEmpty);
      expect(stringMap, isNotNull);

      Map<int, int> intMap = msg.intMap;
      expect(intMap, isEmpty);
      expect(intMap, isNotNull);

      Map<String, nullable.TestMessage> messageMap = msg.messageMap;
      expect(messageMap, isEmpty);
      expect(messageMap, isNotNull);
    });
  });
}
