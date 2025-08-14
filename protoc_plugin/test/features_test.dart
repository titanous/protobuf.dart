// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:protoc_plugin/protoc.dart';
import 'package:protoc_plugin/src/gen/google/protobuf/descriptor.pb.dart';
import 'package:test/test.dart';

void main() {
  group('Feature Resolution', () {
    group('Field Presence', () {
      test('proto2 fields use explicit presence by default', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto2';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL;

        final presence = resolveFieldPresence(field, file);
        expect(presence, equals(FIELD_PRESENCE_EXPLICIT));
      });

      test('proto3 fields use implicit presence by default', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL;

        final presence = resolveFieldPresence(field, file);
        expect(presence, equals(FIELD_PRESENCE_IMPLICIT));
      });

      test('proto3 optional fields use explicit presence', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
              ..proto3Optional = true;

        final presence = resolveFieldPresence(field, file);
        expect(presence, equals(FIELD_PRESENCE_EXPLICIT));
      });

      test('oneof fields always use explicit presence', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
              ..oneofIndex = 0;

        final presence = resolveFieldPresence(field, file);
        expect(presence, equals(FIELD_PRESENCE_EXPLICIT));
      });

      test('required fields use legacy required presence', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto2';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_REQUIRED;

        final presence = resolveFieldPresence(field, file);
        expect(presence, equals(FIELD_PRESENCE_LEGACY_REQUIRED));
      });

      test('repeated fields do not track presence', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_REPEATED;

        final presence = resolveFieldPresence(field, file);
        expect(presence, equals(FIELD_PRESENCE_IMPLICIT));
      });

      test('message fields cannot have implicit presence', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_MESSAGE
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL;

        final presence = resolveFieldPresence(field, file);
        expect(presence, equals(FIELD_PRESENCE_EXPLICIT));
      });

      test('extensions always track presence', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL;

        final presence = resolveFieldPresence(field, file, isExtension: true);
        expect(presence, equals(FIELD_PRESENCE_EXPLICIT));
      });

      test('edition 2023 fields use explicit presence by default', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023;

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL;

        final presence = resolveFieldPresence(field, file);
        expect(presence, equals(FIELD_PRESENCE_EXPLICIT));
      });

      test('edition 2023 respects field-level feature overrides', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023;

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
              ..options =
                  (FieldOptions()
                    ..features =
                        (FeatureSet()
                          ..fieldPresence = FeatureSet_FieldPresence.IMPLICIT));

        final presence = resolveFieldPresence(field, file);
        expect(presence, equals(FIELD_PRESENCE_IMPLICIT));
      });
    });

    group('Packed Encoding', () {
      test('proto2 repeated fields are not packed by default', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto2';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_REPEATED;

        final packed = resolvePackedEncoding(field, file);
        expect(packed, isFalse);
      });

      test('proto3 repeated fields are packed by default', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_REPEATED;

        final packed = resolvePackedEncoding(field, file);
        expect(packed, isTrue);
      });

      test('string fields cannot be packed', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_STRING
              ..label = FieldDescriptorProto_Label.LABEL_REPEATED;

        final packed = resolvePackedEncoding(field, file);
        expect(packed, isFalse);
      });

      test('message fields cannot be packed', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_MESSAGE
              ..label = FieldDescriptorProto_Label.LABEL_REPEATED;

        final packed = resolvePackedEncoding(field, file);
        expect(packed, isFalse);
      });

      test('explicit packed option overrides defaults', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto2';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_REPEATED
              ..options = (FieldOptions()..packed = true);

        final packed = resolvePackedEncoding(field, file);
        expect(packed, isTrue);
      });

      test('edition 2023 repeated fields are packed by default', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023;

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_REPEATED;

        final packed = resolvePackedEncoding(field, file);
        expect(packed, isTrue);
      });

      test('edition 2023 respects feature overrides', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023;

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_REPEATED
              ..options =
                  (FieldOptions()
                    ..features =
                        (FeatureSet()
                          ..repeatedFieldEncoding =
                              FeatureSet_RepeatedFieldEncoding.EXPANDED));

        final packed = resolvePackedEncoding(field, file);
        expect(packed, isFalse);
      });
    });

    group('Enum Type', () {
      test('proto2 enums are closed by default', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto2';

        final enumDesc = EnumDescriptorProto()..name = 'TestEnum';

        final isOpen = resolveEnumIsOpen(enumDesc, file);
        expect(isOpen, isFalse);
      });

      test('proto3 enums are open by default', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final enumDesc = EnumDescriptorProto()..name = 'TestEnum';

        final isOpen = resolveEnumIsOpen(enumDesc, file);
        expect(isOpen, isTrue);
      });

      test('edition 2023 enums are open by default', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023;

        final enumDesc = EnumDescriptorProto()..name = 'TestEnum';

        final isOpen = resolveEnumIsOpen(enumDesc, file);
        expect(isOpen, isTrue);
      });

      test('edition 2023 respects enum feature overrides', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023;

        final enumDesc =
            EnumDescriptorProto()
              ..name = 'TestEnum'
              ..options =
                  (EnumOptions()
                    ..features =
                        (FeatureSet()..enumType = FeatureSet_EnumType.CLOSED));

        final isOpen = resolveEnumIsOpen(enumDesc, file);
        expect(isOpen, isFalse);
      });
    });

    group('Message Encoding', () {
      test('messages use length-prefixed encoding by default', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_MESSAGE
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL;

        final delimited = resolveDelimitedEncoding(field, file);
        expect(delimited, isFalse);
      });

      test('GROUP type always uses delimited encoding', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto2';

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_GROUP
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL;

        final delimited = resolveDelimitedEncoding(field, file);
        expect(delimited, isTrue);
      });

      test('edition 2023 respects message encoding feature', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023;

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_MESSAGE
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
              ..options =
                  (FieldOptions()
                    ..features =
                        (FeatureSet()
                          ..messageEncoding =
                              FeatureSet_MessageEncoding.DELIMITED));

        final delimited = resolveDelimitedEncoding(field, file);
        expect(delimited, isTrue);
      });
    });

    group('File Features', () {
      test('resolves file features for proto2', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto2';

        final features = resolveFileFeatures(file);
        expect(features.fieldPresence, equals(FIELD_PRESENCE_EXPLICIT));
        expect(features.enumType, equals(ENUM_TYPE_CLOSED));
        expect(
          features.repeatedFieldEncoding,
          equals(REPEATED_FIELD_ENCODING_EXPANDED),
        );
        expect(features.utf8Validation, equals(UTF8_VALIDATION_NONE));
        expect(features.jsonFormat, equals(JSON_FORMAT_LEGACY_BEST_EFFORT));
        expect(
          features.messageEncoding,
          equals(MESSAGE_ENCODING_LENGTH_PREFIXED),
        );
      });

      test('resolves file features for proto3', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final features = resolveFileFeatures(file);
        expect(features.fieldPresence, equals(FIELD_PRESENCE_IMPLICIT));
        expect(features.enumType, equals(ENUM_TYPE_OPEN));
        expect(
          features.repeatedFieldEncoding,
          equals(REPEATED_FIELD_ENCODING_PACKED),
        );
        expect(features.utf8Validation, equals(UTF8_VALIDATION_VERIFY));
        expect(features.jsonFormat, equals(JSON_FORMAT_ALLOW));
        expect(
          features.messageEncoding,
          equals(MESSAGE_ENCODING_LENGTH_PREFIXED),
        );
      });

      test('resolves file features for edition 2023', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023;

        final features = resolveFileFeatures(file);
        expect(features.fieldPresence, equals(FIELD_PRESENCE_EXPLICIT));
        expect(features.enumType, equals(ENUM_TYPE_OPEN));
        expect(
          features.repeatedFieldEncoding,
          equals(REPEATED_FIELD_ENCODING_PACKED),
        );
        expect(features.utf8Validation, equals(UTF8_VALIDATION_VERIFY));
        expect(features.jsonFormat, equals(JSON_FORMAT_ALLOW));
        expect(
          features.messageEncoding,
          equals(MESSAGE_ENCODING_LENGTH_PREFIXED),
        );
      });

      test('file-level features override edition defaults', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023
              ..options =
                  (FileOptions()
                    ..features =
                        (FeatureSet()
                          ..fieldPresence = FeatureSet_FieldPresence.IMPLICIT
                          ..enumType = FeatureSet_EnumType.CLOSED));

        final features = resolveFileFeatures(file);
        expect(features.fieldPresence, equals(FIELD_PRESENCE_IMPLICIT));
        expect(features.enumType, equals(ENUM_TYPE_CLOSED));
      });
    });

    group('Feature Inheritance', () {
      test('field inherits features from parent message', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023;

        final message =
            DescriptorProto()
              ..name = 'TestMessage'
              ..options =
                  (MessageOptions()
                    ..features =
                        (FeatureSet()
                          ..fieldPresence = FeatureSet_FieldPresence.IMPLICIT));

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL;

        final presence = resolveFieldPresence(
          field,
          file,
          parentDescriptor: message,
        );
        expect(presence, equals(FIELD_PRESENCE_IMPLICIT));
      });

      test('enum inherits features from parent message', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023;

        final message =
            DescriptorProto()
              ..name = 'TestMessage'
              ..options =
                  (MessageOptions()
                    ..features =
                        (FeatureSet()..enumType = FeatureSet_EnumType.CLOSED));

        final enumDesc = EnumDescriptorProto()..name = 'TestEnum';

        final isOpen = resolveEnumIsOpen(
          enumDesc,
          file,
          parentDescriptor: message,
        );
        expect(isOpen, isFalse);
      });

      test('field-level features override parent features', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_2023;

        final message =
            DescriptorProto()
              ..name = 'TestMessage'
              ..options =
                  (MessageOptions()
                    ..features =
                        (FeatureSet()
                          ..fieldPresence = FeatureSet_FieldPresence.IMPLICIT));

        final field =
            FieldDescriptorProto()
              ..name = 'test_field'
              ..number = 1
              ..type = FieldDescriptorProto_Type.TYPE_INT32
              ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
              ..options =
                  (FieldOptions()
                    ..features =
                        (FeatureSet()
                          ..fieldPresence = FeatureSet_FieldPresence.EXPLICIT));

        final presence = resolveFieldPresence(
          field,
          file,
          parentDescriptor: message,
        );
        expect(presence, equals(FIELD_PRESENCE_EXPLICIT));
      });
    });

    group('Edition Support', () {
      test('maps proto2 syntax to edition 998', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto2';

        final features = resolveFileFeatures(file);
        // Proto2 defaults
        expect(features.fieldPresence, equals(FIELD_PRESENCE_EXPLICIT));
        expect(features.enumType, equals(ENUM_TYPE_CLOSED));
      });

      test('maps proto3 syntax to edition 999', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'proto3';

        final features = resolveFileFeatures(file);
        // Proto3 defaults
        expect(features.fieldPresence, equals(FIELD_PRESENCE_IMPLICIT));
        expect(features.enumType, equals(ENUM_TYPE_OPEN));
      });

      test('handles unknown editions gracefully', () {
        final file =
            FileDescriptorProto()
              ..name = 'test.proto'
              ..syntax = 'editions'
              ..edition = Edition.EDITION_UNKNOWN;

        // Should default to proto2 (998)
        final features = resolveFileFeatures(file);
        expect(features.fieldPresence, equals(FIELD_PRESENCE_EXPLICIT));
      });
    });
  });
}
