// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

// Import test proto files to get different message types and extensions
import '../../protoc_plugin/test/gen/extend_unittest.pb.dart';
import '../../protoc_plugin/test/gen/google/protobuf/unittest.pb.dart';

void main() {
  group('Extension validation tests', () {
    test('hasExtension returns false for incompatible extensions', () {
      // Create different message types
      final testAllExtensions = TestAllExtensions();
      final testAllTypes = TestAllTypes(); // Does not support extensions
      final outer = Outer();

      // Test extensions that apply to TestAllExtensions
      final extensionForTestAllExtensions = Unittest.optionalInt32Extension;
      final anotherExtensionForTestAllExtensions =
          Unittest.optionalStringExtension;

      // Test extensions that apply to different message types
      final extensionForOuter = Extend_unittest.outer;

      // Valid cases - extension applies to message type but is not set
      expect(
        testAllExtensions.hasExtension(extensionForTestAllExtensions),
        isFalse,
        reason: 'Extension applies to message type but field is not set',
      );
      expect(
        testAllExtensions.hasExtension(anotherExtensionForTestAllExtensions),
        isFalse,
        reason: 'Another compatible extension that is not set',
      );

      // Invalid cases - extension does not apply to message type
      expect(
        testAllExtensions.hasExtension(extensionForOuter),
        isFalse,
        reason: 'Extension for different message type should return false',
      );
      expect(
        outer.hasExtension(extensionForTestAllExtensions),
        isFalse,
        reason: 'Extension for different message type should return false',
      );
      expect(
        outer.hasExtension(anotherExtensionForTestAllExtensions),
        isFalse,
        reason: 'Extension for different message type should return false',
      );

      // TestAllTypes doesn't support extensions at all
      expect(
        testAllTypes.hasExtension(extensionForTestAllExtensions),
        isFalse,
        reason: 'Message that does not support extensions should return false',
      );
    });

    test(
      'hasExtension returns true only when extension is set and compatible',
      () {
        final testAllExtensions = TestAllExtensions();
        final outer = Outer();

        // Extensions for different message types
        final extensionForTestAllExtensions = Unittest.optionalInt32Extension;
        final extensionForOuter =
            Extend_unittest.extensionInner; // This extends Outer

        // Set extensions on their compatible message types
        testAllExtensions.setExtension(extensionForTestAllExtensions, 42);
        outer.setExtension(extensionForOuter, Inner());

        // Valid cases - extension is set and compatible
        expect(
          testAllExtensions.hasExtension(extensionForTestAllExtensions),
          isTrue,
          reason: 'Extension is set and compatible',
        );
        expect(
          outer.hasExtension(extensionForOuter),
          isTrue,
          reason: 'Extension is set and compatible',
        );

        // Invalid cases - extension is set but on wrong message type
        expect(
          testAllExtensions.hasExtension(extensionForOuter),
          isFalse,
          reason: 'Extension is set on different message type',
        );
        expect(
          outer.hasExtension(extensionForTestAllExtensions),
          isFalse,
          reason: 'Extension is set on different message type',
        );
      },
    );

    test(
      'hasExtension validates extension applicability before checking field presence',
      () {
        final testAllExtensions = TestAllExtensions();

        // Set up extensions with different applicability
        final compatibleExtension = Unittest.optionalInt32Extension;
        final incompatibleExtension =
            Extend_unittest
                .extensionInner; // This extends Outer, not TestAllExtensions

        // Verify they have different extendee types
        expect(
          compatibleExtension.extendee,
          'protobuf_unittest.TestAllExtensions',
          reason: 'Compatible extension should extend TestAllExtensions',
        );
        expect(
          incompatibleExtension.extendee,
          'extend_unittest.Outer',
          reason: 'Incompatible extension should extend Outer',
        );

        // Set the compatible extension
        testAllExtensions.setExtension(compatibleExtension, 123);

        // The compatible extension should return true
        expect(
          testAllExtensions.hasExtension(compatibleExtension),
          isTrue,
          reason: 'Compatible extension that is set should return true',
        );

        // Even if there were a field number collision, incompatible extensions should return false
        // This tests the fix where hasExtension was incorrectly returning true for all extensions
        // with the same field number regardless of message type compatibility
        expect(
          testAllExtensions.hasExtension(incompatibleExtension),
          isFalse,
          reason:
              'Incompatible extension should return false even with potential field number collision',
        );
      },
    );

    test(
      'hasExtension works correctly with multiple extensions on same message',
      () {
        final testAllExtensions = TestAllExtensions();

        // Multiple extensions for the same message type
        final intExtension = Unittest.optionalInt32Extension;
        final stringExtension = Unittest.optionalStringExtension;
        final messageExtension = Unittest.optionalNestedMessageExtension;

        // Initially all should return false
        expect(testAllExtensions.hasExtension(intExtension), isFalse);
        expect(testAllExtensions.hasExtension(stringExtension), isFalse);
        expect(testAllExtensions.hasExtension(messageExtension), isFalse);

        // Set only the int extension
        testAllExtensions.setExtension(intExtension, 42);
        expect(testAllExtensions.hasExtension(intExtension), isTrue);
        expect(testAllExtensions.hasExtension(stringExtension), isFalse);
        expect(testAllExtensions.hasExtension(messageExtension), isFalse);

        // Set the string extension too
        testAllExtensions.setExtension(stringExtension, 'hello');
        expect(testAllExtensions.hasExtension(intExtension), isTrue);
        expect(testAllExtensions.hasExtension(stringExtension), isTrue);
        expect(testAllExtensions.hasExtension(messageExtension), isFalse);

        // Set the message extension
        testAllExtensions.setExtension(
          messageExtension,
          TestAllTypes_NestedMessage()..i = 99,
        );
        expect(testAllExtensions.hasExtension(intExtension), isTrue);
        expect(testAllExtensions.hasExtension(stringExtension), isTrue);
        expect(testAllExtensions.hasExtension(messageExtension), isTrue);

        // Clear one extension
        testAllExtensions.clearExtension(stringExtension);
        expect(testAllExtensions.hasExtension(intExtension), isTrue);
        expect(testAllExtensions.hasExtension(stringExtension), isFalse);
        expect(testAllExtensions.hasExtension(messageExtension), isTrue);
      },
    );

    test('hasExtension works with repeated extensions', () {
      final testAllExtensions = TestAllExtensions();
      final repeatedExtension = Unittest.repeatedInt32Extension;

      // Initially should return false
      expect(testAllExtensions.hasExtension(repeatedExtension), isFalse);

      // Add an element to the repeated extension
      testAllExtensions.addExtension(repeatedExtension, 1);
      expect(testAllExtensions.hasExtension(repeatedExtension), isTrue);

      // Add another element
      testAllExtensions.addExtension(repeatedExtension, 2);
      expect(testAllExtensions.hasExtension(repeatedExtension), isTrue);

      // Clear the repeated extension
      testAllExtensions.clearExtension(repeatedExtension);
      expect(testAllExtensions.hasExtension(repeatedExtension), isFalse);
    });

    test(
      'hasExtension consistency with getExtension and setExtension error behavior',
      () {
        final testAllTypes = TestAllTypes(); // Does not support extensions
        final incompatibleExtension = Unittest.optionalInt32Extension;

        // hasExtension should return false for incompatible extensions
        expect(testAllTypes.hasExtension(incompatibleExtension), isFalse);

        // getExtension should throw for incompatible extensions
        expect(
          () => testAllTypes.getExtension(incompatibleExtension),
          throwsArgumentError,
        );

        // setExtension should throw for incompatible extensions
        expect(
          () => testAllTypes.setExtension(incompatibleExtension, 42),
          throwsArgumentError,
        );
      },
    );
  });

  group('Extension field number collision regression tests', () {
    test(
      'extensions with same field number on different message types handled correctly',
      () {
        // This test specifically addresses the bug where hasExtension() returned true
        // for all extensions with the same field number, regardless of message type compatibility

        final testAllExtensions = TestAllExtensions();
        final outer = Outer();

        // Find extensions for different message types
        final extForTestAll = Unittest.optionalInt32Extension;
        final extForOuter =
            Extend_unittest.extensionInner; // This extends Outer

        // Set extension on TestAllExtensions
        testAllExtensions.setExtension(extForTestAll, 123);

        // TestAllExtensions should only report true for its own extension
        expect(
          testAllExtensions.hasExtension(extForTestAll),
          isTrue,
          reason: 'TestAllExtensions should have its own extension',
        );
        expect(
          testAllExtensions.hasExtension(extForOuter),
          isFalse,
          reason:
              'TestAllExtensions should not report extension for different message type',
        );

        // Set extension on Outer
        outer.setExtension(extForOuter, Inner());

        // Outer should only report true for its own extension
        expect(
          outer.hasExtension(extForOuter),
          isTrue,
          reason: 'Outer should have its own extension',
        );
        expect(
          outer.hasExtension(extForTestAll),
          isFalse,
          reason:
              'Outer should not report extension for different message type',
        );

        // Even after setting both, each message should only report its own extensions
        expect(testAllExtensions.hasExtension(extForTestAll), isTrue);
        expect(testAllExtensions.hasExtension(extForOuter), isFalse);
        expect(outer.hasExtension(extForOuter), isTrue);
        expect(outer.hasExtension(extForTestAll), isFalse);
      },
    );

    test('extension extendee validation prevents false positives', () {
      // Create messages of different types
      final testAllExtensions = TestAllExtensions();
      final outer = Outer();

      // Get extensions for each message type
      final testAllExt = Unittest.optionalInt32Extension;
      final outerExt = Extend_unittest.extensionInner; // This extends Outer

      // Verify extendee information
      expect(testAllExt.extendee, 'protobuf_unittest.TestAllExtensions');
      expect(outerExt.extendee, 'extend_unittest.Outer');

      // Test cross-type extension checks return false
      expect(
        testAllExtensions.hasExtension(outerExt),
        isFalse,
        reason: 'Should validate extendee compatibility',
      );
      expect(
        outer.hasExtension(testAllExt),
        isFalse,
        reason: 'Should validate extendee compatibility',
      );

      // Even when extensions are set on appropriate messages,
      // cross-checks should still return false
      testAllExtensions.setExtension(testAllExt, 42);
      outer.setExtension(outerExt, Inner());

      expect(testAllExtensions.hasExtension(outerExt), isFalse);
      expect(outer.hasExtension(testAllExt), isFalse);
    });
  });
}
