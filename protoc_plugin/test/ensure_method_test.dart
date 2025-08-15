// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('vm')
library;

import 'package:protoc_plugin/protoc.dart';
import 'package:protoc_plugin/src/gen/google/protobuf/compiler/plugin.pb.dart';
import 'package:protoc_plugin/src/gen/google/protobuf/descriptor.pb.dart';
import 'package:protoc_plugin/src/linker.dart';
import 'package:protoc_plugin/src/options.dart';
import 'package:test/test.dart';

import 'src/golden_file.dart';

// Helper functions for tests
ExtensionRegistry createTestExtensionRegistry() =>
    ExtensionRegistry(CodeGeneratorRequest());
ExtensionValueDecoder createTestExtensionDecoder() =>
    ExtensionValueDecoder(createTestExtensionRegistry());

FileDescriptorProto buildMessageWithSubMessageFields() {
  final fd = FileDescriptorProto()
    ..name = 'test.proto'
    ..syntax = 'proto3';

  // Add SubMessage type
  fd.messageType.add(
    DescriptorProto()
      ..name = 'SubMessage'
      ..field.add(
        FieldDescriptorProto()
          ..name = 'value'
          ..number = 1
          ..type = FieldDescriptorProto_Type.TYPE_STRING
          ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
          ..jsonName = 'value',
      ),
  );

  // Add main message with message fields
  fd.messageType.add(
    DescriptorProto()
      ..name = 'TestMessage'
      ..field.addAll([
        // optional SubMessage optional_msg = 1;
        FieldDescriptorProto()
          ..name = 'optional_msg'
          ..number = 1
          ..type = FieldDescriptorProto_Type.TYPE_MESSAGE
          ..typeName = '.SubMessage'
          ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
          ..jsonName = 'optionalMsg'
          ..proto3Optional = true,
        // SubMessage implicit_msg = 2;
        FieldDescriptorProto()
          ..name = 'implicit_msg'
          ..number = 2
          ..type = FieldDescriptorProto_Type.TYPE_MESSAGE
          ..typeName = '.SubMessage'
          ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
          ..jsonName = 'implicitMsg',
        // optional string optional_string = 3;
        FieldDescriptorProto()
          ..name = 'optional_string'
          ..number = 3
          ..type = FieldDescriptorProto_Type.TYPE_STRING
          ..label = FieldDescriptorProto_Label.LABEL_OPTIONAL
          ..jsonName = 'optionalString'
          ..proto3Optional = true,
      ]),
  );

  return fd;
}

/// Extract just the message field methods for comparison
String extractMessageFieldMethods(String code) {
  final lines = code.split('\n');
  final methods = <String>[];
  
  // Look for the TestMessage class
  bool inTestMessage = false;
  for (final line in lines) {
    if (line.contains('class TestMessage extends')) {
      inTestMessage = true;
      continue;
    }
    if (inTestMessage) {
      // Stop at the next class or end of methods
      if (line.contains('class ') && !line.contains('class TestMessage')) {
        break;
      }
      
      // Extract field accessor/mutator methods
      if (line.contains('get optionalMsg') || 
          line.contains('set optionalMsg(') ||
          line.contains('hasOptionalMsg()') ||
          line.contains('clearOptionalMsg()') ||
          line.contains('ensureOptionalMsg()') ||
          line.contains('get implicitMsg') ||
          line.contains('set implicitMsg(') ||
          line.contains('clearImplicitMsg()') ||
          line.contains('ensureImplicitMsg()') ||
          line.contains('get optionalString') ||
          line.contains('set optionalString(') ||
          line.contains('hasOptionalString()') ||
          line.contains('clearOptionalString()')) {
        // Clean up the line for comparison
        methods.add(line.trim());
      }
    }
  }
  
  return methods.join('\n');
}

void main() {
  group('Ensure method generation', () {
    test('API_LEVEL_HAZZERS generates ensure methods', () {
      final request = CodeGeneratorRequest()
        ..parameter = '' // Default is HAZZERS for proto3
        ..protoFile.add(buildMessageWithSubMessageFields());

      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);
      expect(options, isNotNull);

      // Create generators and link them
      final generators = <FileGenerator>[];
      generators.add(FileGenerator(
        request.protoFile.first,
        options!,
        createTestExtensionRegistry(),
        createTestExtensionDecoder(),
      ));
      link(options, generators);

      final out = generators.first.generateMainFile();
      final code = out.emitSource(format: false);

      // Extract actual generated methods
      final extractedMethods = extractMessageFieldMethods(code);

      // Check that all expected methods are present
      expect(code, contains('SubMessage get optionalMsg =>'));
      expect(code, contains('set optionalMsg(SubMessage value)'));
      expect(code, contains('\$core.bool hasOptionalMsg()'));
      expect(code, contains('void clearOptionalMsg()'));
      expect(code, contains('SubMessage ensureOptionalMsg()'));
      
      expect(code, contains('SubMessage get implicitMsg =>'));
      expect(code, contains('set implicitMsg(SubMessage value)'));
      expect(code, contains('void clearImplicitMsg()'));
      expect(code, contains('SubMessage ensureImplicitMsg()'));
      
      // Store the actual extracted methods as golden
      expectGolden(extractedMethods, 'ensure_methods_hazzers.golden');
    });

    test('API_LEVEL_NULLABLE does not generate ensure methods', () {
      final request = CodeGeneratorRequest()
        ..parameter = 'default_api_level=API_LEVEL_NULLABLE'
        ..protoFile.add(buildMessageWithSubMessageFields());

      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);
      expect(options, isNotNull);

      // Create generators and link them
      final generators = <FileGenerator>[];
      generators.add(FileGenerator(
        request.protoFile.first,
        options!,
        createTestExtensionRegistry(),
        createTestExtensionDecoder(),
      ));
      link(options, generators);

      final out = generators.first.generateMainFile();
      final code = out.emitSource(format: false);

      // Extract actual generated methods
      final extractedMethods = extractMessageFieldMethods(code);

      // Check that expected methods are present/absent
      expect(code, contains('SubMessage? get optionalMsg =>'));
      expect(code, contains('set optionalMsg(SubMessage? value)'));
      expect(code, isNot(contains('hasOptionalMsg')));
      expect(code, contains('void clearOptionalMsg()'));
      expect(code, isNot(contains('ensureOptionalMsg')));
      
      expect(code, contains('SubMessage get implicitMsg =>'));
      expect(code, contains('set implicitMsg(SubMessage value)'));
      expect(code, contains('void clearImplicitMsg()'));
      expect(code, isNot(contains('ensureImplicitMsg')));
      
      // Store the actual extracted methods as golden
      expectGolden(extractedMethods, 'ensure_methods_nullable.golden');
    });

    test('API_LEVEL_HYBRID generates ensure methods with nullable types', () {
      final request = CodeGeneratorRequest()
        ..parameter = 'default_api_level=API_LEVEL_HYBRID'
        ..protoFile.add(buildMessageWithSubMessageFields());

      final response = CodeGeneratorResponse();
      final options = parseGenerationOptions(request, response);
      expect(options, isNotNull);

      // Create generators and link them
      final generators = <FileGenerator>[];
      generators.add(FileGenerator(
        request.protoFile.first,
        options!,
        createTestExtensionRegistry(),
        createTestExtensionDecoder(),
      ));
      link(options, generators);

      final out = generators.first.generateMainFile();
      final code = out.emitSource(format: false);

      // Extract actual generated methods
      final extractedMethods = extractMessageFieldMethods(code);

      // Check that all expected methods are present
      expect(code, contains('SubMessage? get optionalMsg =>'));
      expect(code, contains('set optionalMsg(SubMessage? value)'));
      expect(code, contains('\$core.bool hasOptionalMsg()'));
      expect(code, contains('void clearOptionalMsg()'));
      expect(code, contains('SubMessage? ensureOptionalMsg()'));
      
      expect(code, contains('SubMessage get implicitMsg =>'));
      expect(code, contains('set implicitMsg(SubMessage value)'));
      expect(code, contains('void clearImplicitMsg()'));
      expect(code, contains('SubMessage ensureImplicitMsg()'));
      
      // Store the actual extracted methods as golden
      expectGolden(extractedMethods, 'ensure_methods_hybrid.golden');
    });
  });
}