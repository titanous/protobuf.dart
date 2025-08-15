// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:protoc_plugin/protoc.dart';
import 'package:protoc_plugin/src/gen/google/protobuf/compiler/plugin.pb.dart';
import 'package:protoc_plugin/src/gen/google/protobuf/descriptor.pb.dart';
import 'package:protoc_plugin/src/linker.dart';
import 'package:protoc_plugin/src/options.dart';
import 'package:test/test.dart';

import 'src/test_util.dart';

const coreImportPrefix = r'$core';

void main() {
  group('API Level Tests', () {
    test(
      'API_LEVEL_HAZZERS generates traditional non-nullable with hazzers',
      () {
        final request =
            CodeGeneratorRequest()
              ..parameter =
                  '' // No options, should default to HAZZERS for proto3
              ..protoFile.add(
                FileDescriptorProto()
                  ..name = 'test.proto'
                  ..syntax = 'proto3'
                  ..messageType.add(
                    DescriptorProto()
                      ..name = 'TestMessage'
                      ..field.add(
                        FieldDescriptorProto()
                          ..name = 'optional_field'
                          ..number = 1
                          ..type = FieldDescriptorProto_Type.TYPE_STRING
                          ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
                          ..jsonName = 'optionalField'
                          ..proto3Optional = true,
                      ),
                  ),
              );

        final response = CodeGeneratorResponse();
        final options = parseGenerationOptions(request, response);
        expect(options, isNotNull);

        final fileGen = FileGenerator(
          request.protoFile.first,
          options!,
          createTestExtensionRegistry(),
          createTestExtensionDecoder(),
        );
        final ctx = GenerationContext(options);
        fileGen.resolve(ctx);

        final out = fileGen.generateMainFile();
        final code = out.emitSource(format: false);

        // Should generate non-nullable type with hazzer
        expect(code, contains('$coreImportPrefix.String get optionalField'));
        expect(code, contains('$coreImportPrefix.bool hasOptionalField()'));
        expect(code, contains('void clearOptionalField()'));

        // Should not have nullable type
        expect(
          code,
          isNot(contains('$coreImportPrefix.String? get optionalField')),
        );
      },
    );

    test('API_LEVEL_NULLABLE generates nullable types without hazzers', () {
      final request =
          CodeGeneratorRequest()
            ..parameter = 'default_api_level=API_LEVEL_NULLABLE'
            ..protoFile.add(
              FileDescriptorProto()
                ..name = 'test.proto'
                ..syntax = 'proto3'
                ..messageType.add(
                  DescriptorProto()
                    ..name = 'TestMessage'
                    ..field.add(
                      FieldDescriptorProto()
                        ..name = 'optional_field'
                        ..number = 1
                        ..type = FieldDescriptorProto_Type.TYPE_STRING
                        ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
                        ..jsonName = 'optionalField'
                        ..proto3Optional = true,
                    ),
                ),
            );

      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);
      expect(options, isNotNull);
      expect(options!.defaultApiLevel, equals('API_LEVEL_NULLABLE'));

      final fileGen = FileGenerator(
        request.protoFile.first,
        options,
        createTestExtensionRegistry(),
        createTestExtensionDecoder(),
      );
      final ctx = GenerationContext(options);
      fileGen.resolve(ctx);

      final out = fileGen.generateMainFile();
      final code = out.emitSource(format: false);

      // Should generate nullable type without hazzer
      expect(code, contains('$coreImportPrefix.String? get optionalField'));
      expect(
        code,
        isNot(contains('$coreImportPrefix.bool hasOptionalField()')),
      );
      expect(code, contains('void clearOptionalField()'));
    });

    test('API_LEVEL_HYBRID generates nullable types with hazzers', () {
      final request =
          CodeGeneratorRequest()
            ..parameter = 'default_api_level=API_LEVEL_HYBRID'
            ..protoFile.add(
              FileDescriptorProto()
                ..name = 'test.proto'
                ..syntax = 'proto3'
                ..messageType.add(
                  DescriptorProto()
                    ..name = 'TestMessage'
                    ..field.add(
                      FieldDescriptorProto()
                        ..name = 'optional_field'
                        ..number = 1
                        ..type = FieldDescriptorProto_Type.TYPE_STRING
                        ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
                        ..jsonName = 'optionalField'
                        ..proto3Optional = true,
                    ),
                ),
            );

      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);
      expect(options, isNotNull);
      expect(options!.defaultApiLevel, equals('API_LEVEL_HYBRID'));

      final fileGen = FileGenerator(
        request.protoFile.first,
        options,
        createTestExtensionRegistry(),
        createTestExtensionDecoder(),
      );
      final ctx = GenerationContext(options);
      fileGen.resolve(ctx);

      final out = fileGen.generateMainFile();
      final code = out.emitSource(format: false);

      // Should generate nullable type with hazzer
      expect(code, contains('$coreImportPrefix.String? get optionalField'));
      expect(code, contains('$coreImportPrefix.bool hasOptionalField()'));
      expect(code, contains('void clearOptionalField()'));
    });

    test('api_levelM option overrides per file', () {
      final request =
          CodeGeneratorRequest()
            ..parameter =
                'default_api_level=API_LEVEL_NULLABLE,api_levelMtest.proto=API_LEVEL_HAZZERS'
            ..protoFile.add(
              FileDescriptorProto()
                ..name = 'test.proto'
                ..syntax = 'proto3'
                ..messageType.add(
                  DescriptorProto()
                    ..name = 'TestMessage'
                    ..field.add(
                      FieldDescriptorProto()
                        ..name = 'optional_field'
                        ..number = 1
                        ..type = FieldDescriptorProto_Type.TYPE_STRING
                        ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
                        ..jsonName = 'optionalField'
                        ..proto3Optional = true,
                    ),
                ),
            );

      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);
      expect(options, isNotNull);
      expect(options!.defaultApiLevel, equals('API_LEVEL_NULLABLE'));
      expect(
        options.apiLevelMappings['test.proto'],
        equals('API_LEVEL_HAZZERS'),
      );

      final fileGen = FileGenerator(
        request.protoFile.first,
        options,
        createTestExtensionRegistry(),
        createTestExtensionDecoder(),
      );
      final ctx = GenerationContext(options);
      fileGen.resolve(ctx);

      final out = fileGen.generateMainFile();
      final code = out.emitSource(format: false);

      // Should use API_LEVEL_HAZZERS due to per-file override
      expect(code, contains('$coreImportPrefix.String get optionalField'));
      expect(code, contains('$coreImportPrefix.bool hasOptionalField()'));
      expect(
        code,
        isNot(contains('$coreImportPrefix.String? get optionalField')),
      );
    });

    test('Edition 2023 defaults to API_LEVEL_NULLABLE', () {
      final request =
          CodeGeneratorRequest()
            ..parameter =
                '' // No options
            ..protoFile.add(
              FileDescriptorProto()
                ..name = 'test.proto'
                ..edition = Edition.EDITION_2023
                ..messageType.add(
                  DescriptorProto()
                    ..name = 'TestMessage'
                    ..field.add(
                      FieldDescriptorProto()
                        ..name = 'optional_field'
                        ..number = 1
                        ..type = FieldDescriptorProto_Type.TYPE_STRING
                        ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
                        ..jsonName = 'optionalField'
                        ..proto3Optional = true,
                    ),
                ),
            );

      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);
      expect(options, isNotNull);

      final fileGen = FileGenerator(
        request.protoFile.first,
        options!,
        createTestExtensionRegistry(),
        createTestExtensionDecoder(),
      );
      final ctx = GenerationContext(options);
      fileGen.resolve(ctx);

      final out = fileGen.generateMainFile();
      final code = out.emitSource(format: false);

      // Edition 2023 should default to API_LEVEL_NULLABLE
      expect(code, contains('$coreImportPrefix.String? get optionalField'));
      expect(
        code,
        isNot(contains('$coreImportPrefix.bool hasOptionalField()')),
      );
    });

    test('Proto2 defaults to API_LEVEL_HAZZERS', () {
      final request =
          CodeGeneratorRequest()
            ..parameter =
                '' // No options
            ..protoFile.add(
              FileDescriptorProto()
                ..name = 'test.proto'
                ..syntax = 'proto2'
                ..messageType.add(
                  DescriptorProto()
                    ..name = 'TestMessage'
                    ..field.add(
                      FieldDescriptorProto()
                        ..name = 'optional_field'
                        ..number = 1
                        ..type = FieldDescriptorProto_Type.TYPE_STRING
                        ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
                        ..jsonName = 'optionalField',
                    ),
                ),
            );

      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);
      expect(options, isNotNull);

      final fileGen = FileGenerator(
        request.protoFile.first,
        options!,
        createTestExtensionRegistry(),
        createTestExtensionDecoder(),
      );
      final ctx = GenerationContext(options);
      fileGen.resolve(ctx);

      final out = fileGen.generateMainFile();
      final code = out.emitSource(format: false);

      // Proto2 should default to API_LEVEL_HAZZERS
      expect(code, contains('$coreImportPrefix.String get optionalField'));
      expect(code, contains('$coreImportPrefix.bool hasOptionalField()'));
      expect(
        code,
        isNot(contains('$coreImportPrefix.String? get optionalField')),
      );
    });

    test('Invalid API level parameter is rejected', () {
      final request =
          CodeGeneratorRequest()..parameter = 'default_api_level=INVALID_API';

      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);

      expect(options, isNull);
      expect(response.error, contains('Invalid api_level'));
    });

    test('Multiple file overrides work correctly', () {
      final request =
          CodeGeneratorRequest()
            ..parameter =
                'api_levelMfile1.proto=API_LEVEL_NULLABLE,api_levelMfile2.proto=API_LEVEL_HYBRID'
            ..protoFile.add(
              FileDescriptorProto()
                ..name = 'file1.proto'
                ..syntax = 'proto3',
            )
            ..protoFile.add(
              FileDescriptorProto()
                ..name = 'file2.proto'
                ..syntax = 'proto3',
            );

      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);

      expect(options, isNotNull);
      expect(
        options!.apiLevelMappings['file1.proto'],
        equals('API_LEVEL_NULLABLE'),
      );
      expect(
        options.apiLevelMappings['file2.proto'],
        equals('API_LEVEL_HYBRID'),
      );
    });

    group('Field type generation', () {
      test('Required fields do not have hazzers in nullable mode', () {
        final request =
            CodeGeneratorRequest()
              ..parameter = 'default_api_level=API_LEVEL_NULLABLE'
              ..protoFile.add(
                FileDescriptorProto()
                  ..name = 'test.proto'
                  ..syntax = 'proto2'
                  ..messageType.add(
                    DescriptorProto()
                      ..name = 'TestMessage'
                      ..field.add(
                        FieldDescriptorProto()
                          ..name = 'required_field'
                          ..number = 1
                          ..type = FieldDescriptorProto_Type.TYPE_STRING
                          ..label = FieldDescriptorProto_Label.LABEL_REQUIRED
                          ..jsonName = 'requiredField',
                      ),
                  ),
              );

        final response = CodeGeneratorResponse();
        final options = parseGenerationOptions(request, response);
        final fileGen = FileGenerator(
          request.protoFile.first,
          options!,
          createTestExtensionRegistry(),
          createTestExtensionDecoder(),
        );
        final ctx = GenerationContext(options);
        fileGen.resolve(ctx);

        final out = fileGen.generateMainFile();
        final code = out.emitSource(format: false);

        // Required fields do not have hazzers in nullable mode
        expect(
          code,
          isNot(contains('$coreImportPrefix.bool hasRequiredField()')),
        );
      });

      test('Repeated fields never have hazzers', () {
        final request =
            CodeGeneratorRequest()
              ..parameter = 'default_api_level=API_LEVEL_HYBRID'
              ..protoFile.add(
                FileDescriptorProto()
                  ..name = 'test.proto'
                  ..syntax = 'proto3'
                  ..messageType.add(
                    DescriptorProto()
                      ..name = 'TestMessage'
                      ..field.add(
                        FieldDescriptorProto()
                          ..name = 'repeated_field'
                          ..number = 1
                          ..type = FieldDescriptorProto_Type.TYPE_STRING
                          ..label = FieldDescriptorProto_Label.LABEL_REPEATED
                          ..jsonName = 'repeatedField',
                      ),
                  ),
              );

        final response = CodeGeneratorResponse();
        final options = parseGenerationOptions(request, response);
        final fileGen = FileGenerator(
          request.protoFile.first,
          options!,
          createTestExtensionRegistry(),
          createTestExtensionDecoder(),
        );
        final ctx = GenerationContext(options);
        fileGen.resolve(ctx);

        final out = fileGen.generateMainFile();
        final code = out.emitSource(format: false);

        // Repeated fields never have hazzers
        expect(code, isNot(contains('hasRepeatedField')));
      });

      test('Non-optional proto3 fields follow API level', () {
        final request =
            CodeGeneratorRequest()
              ..parameter = 'default_api_level=API_LEVEL_NULLABLE'
              ..protoFile.add(
                FileDescriptorProto()
                  ..name = 'test.proto'
                  ..syntax = 'proto3'
                  ..messageType.add(
                    DescriptorProto()
                      ..name = 'TestMessage'
                      ..field.add(
                        FieldDescriptorProto()
                          ..name = 'plain_field'
                          ..number = 1
                          ..type = FieldDescriptorProto_Type.TYPE_STRING
                          ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
                          ..jsonName = 'plainField'
                          ..proto3Optional = false,
                      ),
                  ),
              ); // Not proto3 optional

        final response = CodeGeneratorResponse();
        final options = parseGenerationOptions(request, response);
        final fileGen = FileGenerator(
          request.protoFile.first,
          options!,
          createTestExtensionRegistry(),
          createTestExtensionDecoder(),
        );
        final ctx = GenerationContext(options);
        fileGen.resolve(ctx);

        final out = fileGen.generateMainFile();
        final code = out.emitSource(format: false);

        // Non-optional proto3 fields don't get nullable treatment
        expect(code, contains('$coreImportPrefix.String get plainField'));
        expect(
          code,
          isNot(contains('$coreImportPrefix.String? get plainField')),
        );
        expect(code, isNot(contains('hasPlainField')));
      });
    });
  });

  group('CLI Option Parsing', () {
    test('Handles empty parameter gracefully', () {
      final request = CodeGeneratorRequest()..parameter = '';
      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);

      expect(options, isNotNull);
      expect(options!.defaultApiLevel, isNull);
      expect(options.apiLevelMappings, isEmpty);
    });

    test('Handles spaces in parameter', () {
      final request =
          CodeGeneratorRequest()
            ..parameter =
                'default_api_level = API_LEVEL_NULLABLE , api_levelMtest.proto = API_LEVEL_HAZZERS';
      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);

      expect(options, isNotNull);
      expect(options!.defaultApiLevel, equals('API_LEVEL_NULLABLE'));
      expect(
        options.apiLevelMappings['test.proto'],
        equals('API_LEVEL_HAZZERS'),
      );
    });

    test('Combines with other options', () {
      final request =
          CodeGeneratorRequest()
            ..parameter =
                'grpc,default_api_level=API_LEVEL_NULLABLE,generate_kythe_info';
      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);

      expect(options, isNotNull);
      expect(options!.useGrpc, isTrue);
      expect(options.generateMetadata, isTrue);
      expect(options.defaultApiLevel, equals('API_LEVEL_NULLABLE'));
    });

    test('api_levelM without filename is rejected', () {
      final request =
          CodeGeneratorRequest()..parameter = 'api_levelM=API_LEVEL_NULLABLE';
      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);

      expect(options, isNull);
      expect(response.error, contains('requires a filename'));
    });

    test('api_levelM without value is rejected', () {
      final request =
          CodeGeneratorRequest()..parameter = 'api_levelMtest.proto';
      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);

      expect(options, isNull);
      expect(response.error, contains('requires a value'));
    });
  });
}
