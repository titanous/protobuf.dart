// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../protoc.dart';

/// Information about a protobuf extension definition.
class ExtensionDefinition {
  /// The fully qualified name of the extension (e.g., "test.field_options.custom_validator")
  final String fullName;
  
  /// The tag number for this extension
  final int tagNumber;
  
  /// The type of the extended message (e.g., "google.protobuf.FieldOptions")
  final String extendee;
  
  /// The field type of the extension
  final FieldDescriptorProto_Type type;
  
  /// The type name if this is a message or enum type
  final String? typeName;
  
  /// The file where this extension is defined
  final FileDescriptorProto file;
  
  /// The field descriptor for this extension
  final FieldDescriptorProto descriptor;
  
  ExtensionDefinition({
    required this.fullName,
    required this.tagNumber,
    required this.extendee,
    required this.type,
    this.typeName,
    required this.file,
    required this.descriptor,
  });
  
  /// Generate the Dart code to reference this extension.
  /// Returns something like: "test_field_options.customValidator"
  String getDartReference() {
    // Convert proto package.name to Dart reference
    final parts = fullName.split('.');
    if (parts.length < 2) return fullName;
    
    // Last part is the extension name
    final extensionName = parts.last;
    // Convert to camelCase for Dart
    return _toCamelCase(extensionName);
  }
  
  String _toCamelCase(String snakeCase) {
    final parts = snakeCase.split('_');
    if (parts.isEmpty) return snakeCase;
    
    return parts.first + 
        parts.skip(1).map((p) => p.isEmpty ? '' : 
            p[0].toUpperCase() + p.substring(1)).join();
  }
}

/// Registry of all known extensions in the current code generation context.
class ExtensionRegistry {
  /// Map from extendee type to list of extensions that extend it
  final Map<String, List<ExtensionDefinition>> _extensionsByExtendee = {};
  
  /// Map from tag number to extension definition for each extendee
  final Map<String, Map<int, ExtensionDefinition>> _extensionsByTag = {};
  
  /// All known extensions
  final List<ExtensionDefinition> _allExtensions = [];
  
  /// Build the registry from the CodeGeneratorRequest
  ExtensionRegistry(CodeGeneratorRequest request) {
    // Process all proto files to find extension definitions
    for (final file in request.protoFile) {
      _processFile(file);
    }
  }
  
  /// Process a single proto file to extract extension definitions
  void _processFile(FileDescriptorProto file) {
    // Extensions can be defined at the top level
    for (final extension in file.extension) {
      _addExtension(file, extension);
    }
    
    // Extensions can also be defined inside messages
    for (final message in file.messageType) {
      _processMessageType(file, message, file.package);
    }
  }
  
  /// Process a message type recursively to find nested extensions
  void _processMessageType(FileDescriptorProto file, 
                          DescriptorProto message, 
                          String parentPackage) {
    final fullName = parentPackage.isEmpty 
        ? message.name 
        : '$parentPackage.${message.name}';
    
    // Check for extensions defined in this message
    for (final extension in message.extension) {
      _addExtension(file, extension, parentName: fullName);
    }
    
    // Recursively process nested messages
    for (final nested in message.nestedType) {
      _processMessageType(file, nested, fullName);
    }
  }
  
  /// Add an extension to the registry
  void _addExtension(FileDescriptorProto file, 
                     FieldDescriptorProto extension,
                     {String? parentName}) {
    final fullName = parentName != null 
        ? '$parentName.${extension.name}'
        : '${file.package}.${extension.name}';
    
    final def = ExtensionDefinition(
      fullName: fullName,
      tagNumber: extension.number,
      extendee: extension.extendee,
      type: extension.type,
      typeName: extension.typeName,
      file: file,
      descriptor: extension,
    );
    
    _allExtensions.add(def);
    
    // Index by extendee
    _extensionsByExtendee.putIfAbsent(extension.extendee, () => []).add(def);
    
    // Index by tag number
    _extensionsByTag
        .putIfAbsent(extension.extendee, () => {})
        [extension.number] = def;
  }
  
  /// Get all extensions that extend a specific message type
  List<ExtensionDefinition> getExtensionsForType(String extendee) {
    return _extensionsByExtendee[extendee] ?? [];
  }
  
  /// Get a specific extension by extendee and tag number
  ExtensionDefinition? getExtension(String extendee, int tagNumber) {
    // Try with and without leading dot
    var result = _extensionsByTag[extendee]?[tagNumber];
    if (result == null && !extendee.startsWith('.')) {
      result = _extensionsByTag['.${extendee}']?[tagNumber];
    }
    return result;
  }
  
  /// Get extensions for field options
  List<ExtensionDefinition> getFieldExtensions() {
    return getExtensionsForType('.google.protobuf.FieldOptions');
  }
  
  /// Get extensions for message options  
  List<ExtensionDefinition> getMessageExtensions() {
    return getExtensionsForType('.google.protobuf.MessageOptions');
  }
  
  /// Check if we have any extensions for field options
  bool hasFieldExtensions() {
    return _extensionsByExtendee.containsKey('.google.protobuf.FieldOptions');
  }
  
  /// Check if we have any extensions for message options
  bool hasMessageExtensions() {
    return _extensionsByExtendee.containsKey('.google.protobuf.MessageOptions');
  }
}