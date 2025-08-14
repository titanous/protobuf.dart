// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../protoc.dart';

/// Decodes extension values from unknown fields in options.
class ExtensionValueDecoder {
  final ExtensionRegistry registry;

  ExtensionValueDecoder(this.registry);

  /// Extract and decode extension values from field options.
  Map<ExtensionDefinition, dynamic>? extractFieldExtensions(
    FieldDescriptorProto field,
  ) {
    if (!field.hasOptions()) return null;

    return _extractExtensions(
      field.options.unknownFields,
      '.google.protobuf.FieldOptions',
    );
  }

  /// Extract and decode extension values from message options.
  Map<ExtensionDefinition, dynamic>? extractMessageExtensions(
    DescriptorProto message,
  ) {
    if (!message.hasOptions()) return null;

    return _extractExtensions(
      message.options.unknownFields,
      '.google.protobuf.MessageOptions',
    );
  }

  /// Extract extensions from unknown fields.
  Map<ExtensionDefinition, dynamic>? _extractExtensions(
    UnknownFieldSet unknownFields,
    String extendeeType,
  ) {
    if (unknownFields.isEmpty) return null;

    final extensions = <ExtensionDefinition, dynamic>{};

    // Iterate through unknown fields
    for (final entry in unknownFields.asMap().entries) {
      final tagNumber = entry.key;
      final field = entry.value;

      // Look up the extension definition
      final extensionDef = registry.getExtension(extendeeType, tagNumber);
      if (extensionDef == null) continue;

      // Decode the value based on the extension type
      final value = _decodeExtensionValue(field, extensionDef);
      if (value != null) {
        extensions[extensionDef] = value;
      }
    }

    return extensions.isEmpty ? null : extensions;
  }

  /// Decode an extension value from an unknown field.
  dynamic _decodeExtensionValue(
    UnknownFieldSetField field,
    ExtensionDefinition extensionDef,
  ) {
    // The decoding depends on the field type
    switch (extensionDef.type) {
      case FieldDescriptorProto_Type.TYPE_BOOL:
        return field.varints.isNotEmpty ? field.varints.first == 1 : null;

      case FieldDescriptorProto_Type.TYPE_INT32:
      case FieldDescriptorProto_Type.TYPE_SINT32:
      case FieldDescriptorProto_Type.TYPE_SFIXED32:
        return field.varints.isNotEmpty ? field.varints.first.toInt() : null;

      case FieldDescriptorProto_Type.TYPE_INT64:
      case FieldDescriptorProto_Type.TYPE_SINT64:
      case FieldDescriptorProto_Type.TYPE_SFIXED64:
        return field.varints.isNotEmpty ? field.varints.first : null;

      case FieldDescriptorProto_Type.TYPE_UINT32:
      case FieldDescriptorProto_Type.TYPE_FIXED32:
        return field.fixed32s.isNotEmpty ? field.fixed32s.first : null;

      case FieldDescriptorProto_Type.TYPE_UINT64:
      case FieldDescriptorProto_Type.TYPE_FIXED64:
        return field.fixed64s.isNotEmpty ? field.fixed64s.first : null;

      case FieldDescriptorProto_Type.TYPE_FLOAT:
        // Need to convert fixed32 to float
        return field.fixed32s.isNotEmpty ? field.fixed32s.first : null;

      case FieldDescriptorProto_Type.TYPE_DOUBLE:
        // Need to convert fixed64 to double
        return field.fixed64s.isNotEmpty ? field.fixed64s.first : null;

      case FieldDescriptorProto_Type.TYPE_STRING:
        return field.lengthDelimited.isNotEmpty
            ? String.fromCharCodes(field.lengthDelimited.first)
            : null;

      case FieldDescriptorProto_Type.TYPE_BYTES:
        return field.lengthDelimited.isNotEmpty
            ? field.lengthDelimited.first
            : null;

      case FieldDescriptorProto_Type.TYPE_MESSAGE:
        // For message types, we have the serialized bytes
        // We would need to deserialize based on the type
        // For now, return the raw bytes
        return field.lengthDelimited;

      case FieldDescriptorProto_Type.TYPE_ENUM:
        return field.varints.isNotEmpty ? field.varints.first.toInt() : null;

      default:
        // Unknown type
        return null;
    }
  }

  /// Generate Dart code for an extension value.
  String? generateDartValue(dynamic value, ExtensionDefinition extensionDef) {
    if (value == null) return null;

    switch (extensionDef.type) {
      case FieldDescriptorProto_Type.TYPE_BOOL:
        return value.toString();

      case FieldDescriptorProto_Type.TYPE_INT32:
      case FieldDescriptorProto_Type.TYPE_SINT32:
      case FieldDescriptorProto_Type.TYPE_SFIXED32:
      case FieldDescriptorProto_Type.TYPE_UINT32:
      case FieldDescriptorProto_Type.TYPE_FIXED32:
      case FieldDescriptorProto_Type.TYPE_INT64:
      case FieldDescriptorProto_Type.TYPE_SINT64:
      case FieldDescriptorProto_Type.TYPE_SFIXED64:
      case FieldDescriptorProto_Type.TYPE_UINT64:
      case FieldDescriptorProto_Type.TYPE_FIXED64:
        return value.toString();

      case FieldDescriptorProto_Type.TYPE_FLOAT:
      case FieldDescriptorProto_Type.TYPE_DOUBLE:
        return value.toString();

      case FieldDescriptorProto_Type.TYPE_STRING:
        // Escape the string for Dart code
        return _escapeString(value as String);

      case FieldDescriptorProto_Type.TYPE_BYTES:
        // Generate a byte array literal
        final bytes = value as List<int>;
        return '<int>[${bytes.join(', ')}]';

      case FieldDescriptorProto_Type.TYPE_MESSAGE:
        // For message types, we would need to generate the constructor
        // For now, return a TODO comment
        return '/* TODO: Generate ${extensionDef.typeName} value */';

      case FieldDescriptorProto_Type.TYPE_ENUM:
        // For enum values, we need to reference the enum constant
        // For now, just return the numeric value
        return value.toString();

      default:
        return null;
    }
  }

  String _escapeString(String str) {
    // Simple string escaping for Dart code generation
    return "'${str
            .replaceAll('\\', '\\\\')
            .replaceAll("'", "\\'")
            .replaceAll('\n', '\\n')
            .replaceAll('\r', '\\r')
            .replaceAll('\t', '\\t')}'";
  }
}
