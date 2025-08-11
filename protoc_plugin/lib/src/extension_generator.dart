// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../protoc.dart';

class ExtensionGenerator {
  final FieldDescriptorProto _descriptor;
  final ProtobufContainer _parent;

  // populated by resolve()
  late ProtobufField _field;
  bool _resolved = false;
  final String _extensionName;
  String _extendedFullName = '';
  final List<int> _fieldPathSegment;

  /// See [ProtobufContainer]
  late final List<int> fieldPath = [..._parent.fieldPath, ..._fieldPathSegment];

  ExtensionGenerator._(
    this._descriptor,
    this._parent,
    Set<String> usedNames,
    int repeatedFieldIndex,
    int fieldIdTag,
  ) : _extensionName = extensionName(_descriptor, usedNames),
      _fieldPathSegment = [fieldIdTag, repeatedFieldIndex];

  static const _topLevelFieldTag = 7;
  static const _nestedFieldTag = 6;

  ExtensionGenerator.topLevel(
    FieldDescriptorProto descriptor,
    ProtobufContainer parent,
    Set<String> usedNames,
    int repeatedFieldIndex,
  ) : this._(
        descriptor,
        parent,
        usedNames,
        repeatedFieldIndex,
        _topLevelFieldTag,
      );
  ExtensionGenerator.nested(
    FieldDescriptorProto descriptor,
    ProtobufContainer parent,
    Set<String> usedNames,
    int repeatedFieldIndex,
  ) : this._(
        descriptor,
        parent,
        usedNames,
        repeatedFieldIndex,
        _nestedFieldTag,
      );

  void resolve(GenerationContext ctx) {
    _field = ProtobufField.extension(_descriptor, _parent, ctx);
    _resolved = true;

    final extendedType = ctx.getFieldType(_descriptor.extendee);
    // TODO(skybrian) When would this be null?
    if (extendedType != null) {
      _extendedFullName = extendedType.fullName;
    }
  }

  String get package => _parent.package;

  /// The generator of the .pb.dart file where this extension will be defined.
  FileGenerator? get fileGen => _parent.fileGen;

  String get name {
    if (!_resolved) throw StateError('resolve not called');
    final name = _extensionName;
    return _parent is MessageGenerator ? '${_parent.classname}.$name' : name;
  }

  bool get needsFixnumImport {
    if (!_resolved) throw StateError('resolve not called');
    return _field.needsFixnumImport;
  }
  
  /// Returns true if this extension needs the FieldOptions import.
  bool get needsFieldOptionsImport {
    return _descriptor.hasOptions();
  }

  /// Adds dependencies of [generate] to [imports].
  ///
  /// For each .pb.dart file that the generated code needs to import,
  /// add its generator.
  void addImportsTo(
    Set<FileGenerator> imports,
    Set<FileGenerator> enumImports,
  ) {
    if (!_resolved) throw StateError('resolve not called');
    final typeGen = _field.baseType.generator;
    if (typeGen is EnumGenerator) {
      // Enums are always in a different file.
      enumImports.add(typeGen.fileGen!);
    } else if (typeGen != null && typeGen.fileGen != fileGen) {
      imports.add(typeGen.fileGen!);
    }
  }

  /// For each .pb.dart file that the generated code needs to import,
  /// add its generator.
  void addConstantImportsTo(Set<FileGenerator> imports) {
    if (!_resolved) throw StateError('resolve not called');
    // No dependencies - nothing to do.
  }

  /// Generates code to create a FieldOptions object with preserved extensions.
  String? _generateOptionsInitializer(FieldOptions options) {
    final optionsBytes = options.writeToBuffer();
    if (optionsBytes.isEmpty) {
      return null;
    }
    
    // Generate a compact byte array representation
    // Group bytes in chunks for readability
    final chunks = <String>[];
    for (var i = 0; i < optionsBytes.length; i += 16) {
      final end = (i + 16 < optionsBytes.length) ? i + 16 : optionsBytes.length;
      final chunk = optionsBytes
          .sublist(i, end)
          .map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}')
          .join(',');
      chunks.add(chunk);
    }
    
    // Generate the code to reconstruct FieldOptions
    // The file generator will need to import the descriptor types
    final buffer = StringBuffer();
    buffer.write('(() {');
    buffer.write('final _bytes = <int>[');
    buffer.write(chunks.join(','));
    buffer.write('];');
    // Use the global extension registry that should have all extensions registered
    // FieldOptions needs to be imported from google/protobuf/descriptor.pb.dart
    buffer.write('return FieldOptions.fromBuffer(_bytes, $protobufImportPrefix.ExtensionRegistry.EMPTY);');
    buffer.write('})()');
    
    return buffer.toString();
  }
  
  void generate(IndentingWriter out) {
    if (!_resolved) throw StateError('resolve not called');

    final name = _extensionName;
    final type = _field.baseType;
    final dartType = type.getDartType(fileGen!);

    final omitFieldNames = ConditionalConstDefinition('omit_field_names');
    out.addSuffix(
      omitFieldNames.constFieldName,
      omitFieldNames.constDefinition,
    );
    final conditionalName = omitFieldNames.createTernary(_extensionName);
    final omitMessageNames = ConditionalConstDefinition('omit_message_names');
    out.addSuffix(
      omitMessageNames.constFieldName,
      omitMessageNames.constDefinition,
    );
    final conditionalExtendedName = omitMessageNames.createTernary(
      _extendedFullName,
    );

    String invocation;
    final positionals = <String>[];
    positionals.add(conditionalExtendedName);
    positionals.add(conditionalName);
    positionals.add('${_field.number}');
    positionals.add(_field.typeConstant);

    final named = <String, String?>{};
    named['protoName'] = _field.quotedProtoName;
    if (_field.isRepeated) {
      invocation = '$protobufImportPrefix.Extension<$dartType>.repeated';
      named['check'] =
          '$protobufImportPrefix.getCheckFunction(${_field.typeConstant})';
      if (type.isMessage || type.isGroup) {
        named['subBuilder'] = '$dartType.create';
      } else if (type.isEnum) {
        named['valueOf'] = '$dartType.valueOf';
        named['enumValues'] = '$dartType.values';
      }
    } else {
      invocation = '$protobufImportPrefix.Extension<$dartType>';
      named['defaultOrMaker'] = _field.generateDefaultFunction();
      if (type.isMessage || type.isGroup) {
        named['subBuilder'] = '$dartType.create';
      } else if (type.isEnum) {
        final dartEnum = type.getDartType(fileGen!);
        named['valueOf'] = '$dartEnum.valueOf';
        named['enumValues'] = '$dartEnum.values';
      }
    }
    
    // Add options bytes if they exist
    if (_descriptor.hasOptions()) {
      final optionsBytes = _descriptor.options.writeToBuffer();
      if (optionsBytes.isNotEmpty) {
        // Pass the serialized bytes as a list literal
        // Use the core import prefix to qualify int type
        final bytesLiteral = '<$coreImportPrefix.int>[' + optionsBytes.map((b) => b.toString()).join(',') + ']';
        named['optionsBytes'] = bytesLiteral;
      }
    }
    
    final fieldDefinition = 'static final ';
    out.printAnnotated(
      '$fieldDefinition$name = '
      '$invocation(${ProtobufField._formatArguments(positionals, named)});\n',
      [
        NamedLocation(
          name: name,
          fieldPathSegment: List.from(fieldPath),
          start: fieldDefinition.length,
        ),
      ],
    );
  }
}
