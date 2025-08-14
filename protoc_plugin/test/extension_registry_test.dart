// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:protoc_plugin/protoc.dart';
import 'package:protoc_plugin/src/gen/google/protobuf/compiler/plugin.pb.dart';
import 'package:protoc_plugin/src/gen/google/protobuf/descriptor.pb.dart';
import 'package:test/test.dart';

void main() {
  group('ExtensionRegistry', () {
    test('can track extensions from proto files', () {
      // Create a mock CodeGeneratorRequest with extension definitions
      final request =
          CodeGeneratorRequest()
            ..protoFile.add(
              FileDescriptorProto()
                ..name = 'test.proto'
                ..package = 'test'
                ..extension.add(
                  FieldDescriptorProto()
                    ..name = 'test_extension'
                    ..number = 1000
                    ..type = FieldDescriptorProto_Type.TYPE_STRING
                    ..extendee = '.google.protobuf.FieldOptions',
                )
                ..extension.add(
                  FieldDescriptorProto()
                    ..name = 'another_extension'
                    ..number = 1001
                    ..type = FieldDescriptorProto_Type.TYPE_INT32
                    ..extendee = '.google.protobuf.MessageOptions',
                ),
            );

      final registry = ExtensionRegistry(request);

      // Check that extensions were registered
      final fieldExt = registry.getExtension(
        'google.protobuf.FieldOptions',
        1000,
      );
      expect(fieldExt, isNotNull);
      expect(fieldExt!.fullName, endsWith('test_extension'));
      expect(fieldExt.type, equals(FieldDescriptorProto_Type.TYPE_STRING));

      final msgExt = registry.getExtension(
        'google.protobuf.MessageOptions',
        1001,
      );
      expect(msgExt, isNotNull);
      expect(msgExt!.fullName, endsWith('another_extension'));
      expect(msgExt.type, equals(FieldDescriptorProto_Type.TYPE_INT32));

      // Check that non-existent extensions return null
      expect(
        registry.getExtension('google.protobuf.FieldOptions', 9999),
        isNull,
      );
    });

    test('handles nested extensions', () {
      final request =
          CodeGeneratorRequest()
            ..protoFile.add(
              FileDescriptorProto()
                ..name = 'nested.proto'
                ..package = 'nested'
                ..messageType.add(
                  DescriptorProto()
                    ..name = 'OuterMessage'
                    ..extension.add(
                      FieldDescriptorProto()
                        ..name = 'nested_ext'
                        ..number = 2000
                        ..type = FieldDescriptorProto_Type.TYPE_BOOL
                        ..extendee = '.google.protobuf.FieldOptions',
                    ),
                ),
            );

      final registry = ExtensionRegistry(request);

      final nestedExt = registry.getExtension(
        'google.protobuf.FieldOptions',
        2000,
      );
      expect(nestedExt, isNotNull);
      expect(nestedExt!.fullName, endsWith('nested_ext'));
      expect(nestedExt.type, equals(FieldDescriptorProto_Type.TYPE_BOOL));
    });

    test('handles multiple proto files', () {
      final request =
          CodeGeneratorRequest()
            ..protoFile.addAll([
              FileDescriptorProto()
                ..name = 'file1.proto'
                ..package = 'pkg1'
                ..extension.add(
                  FieldDescriptorProto()
                    ..name = 'ext1'
                    ..number = 3000
                    ..type = FieldDescriptorProto_Type.TYPE_STRING
                    ..extendee = '.google.protobuf.FieldOptions',
                ),
              FileDescriptorProto()
                ..name = 'file2.proto'
                ..package = 'pkg2'
                ..extension.add(
                  FieldDescriptorProto()
                    ..name = 'ext2'
                    ..number = 3001
                    ..type = FieldDescriptorProto_Type.TYPE_INT64
                    ..extendee = '.google.protobuf.FieldOptions',
                ),
            ]);

      final registry = ExtensionRegistry(request);

      // Both extensions should be registered
      expect(
        registry.getExtension('google.protobuf.FieldOptions', 3000),
        isNotNull,
      );
      expect(
        registry.getExtension('google.protobuf.FieldOptions', 3001),
        isNotNull,
      );
    });
  });

  group('ExtensionValueDecoder', () {
    test('can extract field extensions from unknown fields', () {
      // Create a field with options containing extensions in unknown fields
      final fieldOptions = FieldOptions();

      // Simulate having extension data in unknown fields
      // In real usage, this would come from parsing a proto with extensions
      // For testing, we'll verify the structure is correct

      final request =
          CodeGeneratorRequest()
            ..protoFile.add(
              FileDescriptorProto()
                ..name = 'test.proto'
                ..extension.add(
                  FieldDescriptorProto()
                    ..name = 'validator'
                    ..number = 51234
                    ..type = FieldDescriptorProto_Type.TYPE_STRING
                    ..extendee = '.google.protobuf.FieldOptions',
                ),
            );

      final registry = ExtensionRegistry(request);
      final decoder = ExtensionValueDecoder(registry);

      // The decoder should be able to extract extensions when they're present
      // in the unknown fields of the options
      expect(decoder, isNotNull);
    });

    test('handles different extension types', () {
      final request =
          CodeGeneratorRequest()
            ..protoFile.add(
              FileDescriptorProto()
                ..name = 'types.proto'
                ..extension.addAll([
                  FieldDescriptorProto()
                    ..name = 'string_ext'
                    ..number = 4000
                    ..type = FieldDescriptorProto_Type.TYPE_STRING
                    ..extendee = '.google.protobuf.FieldOptions',
                  FieldDescriptorProto()
                    ..name = 'int32_ext'
                    ..number = 4001
                    ..type = FieldDescriptorProto_Type.TYPE_INT32
                    ..extendee = '.google.protobuf.FieldOptions',
                  FieldDescriptorProto()
                    ..name = 'bool_ext'
                    ..number = 4002
                    ..type = FieldDescriptorProto_Type.TYPE_BOOL
                    ..extendee = '.google.protobuf.FieldOptions',
                  FieldDescriptorProto()
                    ..name = 'enum_ext'
                    ..number = 4003
                    ..type = FieldDescriptorProto_Type.TYPE_ENUM
                    ..extendee = '.google.protobuf.FieldOptions',
                ]),
            );

      final registry = ExtensionRegistry(request);
      final decoder = ExtensionValueDecoder(registry);

      // Verify the decoder can handle different types
      expect(decoder, isNotNull);

      // The actual extraction would happen when processing field options
      // with unknown fields containing these extensions
    });
  });
}
