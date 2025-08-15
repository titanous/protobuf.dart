// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../protoc.dart';

/// Represents the base type of a particular field in a proto definition.
/// (Doesn't include List<> for repeated fields.)
class BaseType {
  final FieldDescriptorProto_Type descriptor;

  /// The name of the Dart type when in the same package.
  final String unprefixed;

  /// The suffix of the constant for this type in PbFieldType.
  /// (For example, 'B' for boolean or '3' for int32.)
  final String typeConstantSuffix;

  /// Whether this field uses group encoding (for editions delimited messages)
  final bool usesGroupEncoding;

  // Method name of the setter method for this type.
  final String? setter;

  // The generator corresponding to this type.
  // (Null for primitive types.)
  final ProtobufContainer? generator;

  const BaseType._raw(
    this.descriptor,
    this.typeConstantSuffix,
    this.unprefixed,
    this.setter,
    this.generator, {
    this.usesGroupEncoding = false,
  });

  bool get isGroup =>
      descriptor == FieldDescriptorProto_Type.TYPE_GROUP || usesGroupEncoding;
  bool get isMessage => descriptor == FieldDescriptorProto_Type.TYPE_MESSAGE;
  bool get isEnum => descriptor == FieldDescriptorProto_Type.TYPE_ENUM;
  bool get isString => descriptor == FieldDescriptorProto_Type.TYPE_STRING;
  bool get isBytes => descriptor == FieldDescriptorProto_Type.TYPE_BYTES;
  bool get isPackable => (generator == null && !isString && !isBytes) || isEnum;

  /// The package where this type is declared.
  /// (Always the empty string for primitive types.)
  String get package => generator == null ? '' : generator!.package;

  /// The Dart expression to use for this type when in a different file.
  String prefixed(FileGenerator fileGen) =>
      generator == null
          ? unprefixed
          : '${generator!.importPrefix(context: fileGen)}.$unprefixed';

  /// Returns the name to use in generated code for this Dart type.
  ///
  /// Doesn't include the List type for repeated fields.
  /// [FileGenerator.protoFileUri] represents the current proto file where we
  /// are generating code.
  /// The Dart class might be imported from a different proto file.
  String getDartType(FileGenerator fileGen) =>
      (fileGen.protoFileUri == generator?.fileGen?.protoFileUri)
          ? unprefixed
          : prefixed(fileGen);

  String getRepeatedDartType(FileGenerator fileGen) =>
      '$protobufImportPrefix.PbList<${getDartType(fileGen)}>';

  String getRepeatedDartTypeIterable(FileGenerator fileGen) =>
      '$coreImportPrefix.Iterable<${getDartType(fileGen)}>';

  factory BaseType(
    FieldDescriptorProto field,
    GenerationContext ctx, {
    ProtobufContainer? parent,
  }) {
    String constSuffix;

    switch (field.type) {
      case FieldDescriptorProto_Type.TYPE_BOOL:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_BOOL,
          'B',
          '$coreImportPrefix.bool',
          r'$_setBool',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_FLOAT:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_FLOAT,
          'F',
          '$coreImportPrefix.double',
          r'$_setFloat',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_DOUBLE:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_DOUBLE,
          'D',
          '$coreImportPrefix.double',
          r'$_setDouble',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_INT32:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_INT32,
          '3',
          '$coreImportPrefix.int',
          r'$_setSignedInt32',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_UINT32:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_UINT32,
          'U3',
          '$coreImportPrefix.int',
          r'$_setUnsignedInt32',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_SINT32:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_SINT32,
          'S3',
          '$coreImportPrefix.int',
          r'$_setSignedInt32',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_FIXED32:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_FIXED32,
          'F3',
          '$coreImportPrefix.int',
          r'$_setUnsignedInt32',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_SFIXED32:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_SFIXED32,
          'SF3',
          '$coreImportPrefix.int',
          r'$_setSignedInt32',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_INT64:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_INT64,
          '6',
          '$fixnumImportPrefix.Int64',
          r'$_setInt64',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_UINT64:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_UINT64,
          'U6',
          '$fixnumImportPrefix.Int64',
          r'$_setInt64',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_SINT64:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_SINT64,
          'S6',
          '$fixnumImportPrefix.Int64',
          r'$_setInt64',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_FIXED64:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_FIXED64,
          'F6',
          '$fixnumImportPrefix.Int64',
          r'$_setInt64',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_SFIXED64:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_SFIXED64,
          'SF6',
          '$fixnumImportPrefix.Int64',
          r'$_setInt64',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_STRING:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_STRING,
          'S',
          '$coreImportPrefix.String',
          r'$_setString',
          null,
        );
      case FieldDescriptorProto_Type.TYPE_BYTES:
        return const BaseType._raw(
          FieldDescriptorProto_Type.TYPE_BYTES,
          'Y',
          '$coreImportPrefix.List<$coreImportPrefix.int>',
          r'$_setBytes',
          null,
        );

      case FieldDescriptorProto_Type.TYPE_GROUP:
        constSuffix = 'G';
        break;
      case FieldDescriptorProto_Type.TYPE_MESSAGE:
        // Check if this message field should use delimited encoding in editions
        if (parent != null && parent.fileGen != null) {
          // Get the parent descriptor - could be message or file
          dynamic parentDesc;
          bool isMapEntry = false;
          if (parent is MessageGenerator) {
            parentDesc = parent.descriptor;
            // Check if the parent message is a map entry
            isMapEntry = parent.descriptor.options.mapEntry;
          } else if (parent is FileGenerator) {
            parentDesc = parent.descriptor;
          }

          final useDelimited = resolveDelimitedEncoding(
            field,
            parent.fileGen!.descriptor,
            parentDescriptor: parentDesc,
            isMapValueField: isMapEntry,
          );
          constSuffix = useDelimited ? 'G' : 'M';
        } else {
          constSuffix = 'M';
        }
        break;
      case FieldDescriptorProto_Type.TYPE_ENUM:
        constSuffix = 'E';
        break;

      default:
        throw ArgumentError('unimplemented type: ${field.type.name}');
    }

    final generator = ctx.getFieldType(field.typeName);
    if (generator == null) {
      throw 'FAILURE: Unknown type reference ${field.typeName}';
    }

    return BaseType._raw(
      field.type,
      constSuffix,
      generator.classname!,
      null,
      generator,
      usesGroupEncoding: constSuffix == 'G',
    );
  }
}
