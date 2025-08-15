// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../protoc.dart';

/// Feature definitions and resolution logic for protobuf editions support.
///
/// This file implements the feature system that allows treating proto2/proto3
/// as special editions (EDITION_PROTO2=998, EDITION_PROTO3=999) and provides
/// unified feature-based code generation logic.

// Field presence feature values (matching protobuf descriptor values)
// ignore_for_file: constant_identifier_names
const int FIELD_PRESENCE_UNKNOWN = 0;
const int FIELD_PRESENCE_EXPLICIT = 1;
const int FIELD_PRESENCE_IMPLICIT = 2;
const int FIELD_PRESENCE_LEGACY_REQUIRED = 3;

// Enum type feature values
const int ENUM_TYPE_UNKNOWN = 0;
const int ENUM_TYPE_OPEN = 1;
const int ENUM_TYPE_CLOSED = 2;

// Repeated field encoding feature values
const int REPEATED_FIELD_ENCODING_UNKNOWN = 0;
const int REPEATED_FIELD_ENCODING_PACKED = 1;
const int REPEATED_FIELD_ENCODING_EXPANDED = 2;

// UTF-8 validation feature values
const int UTF8_VALIDATION_UNKNOWN = 0;
const int UTF8_VALIDATION_UNSPECIFIED = 1;
const int UTF8_VALIDATION_VERIFY = 2;
const int UTF8_VALIDATION_NONE = 3;

// JSON format feature values
const int JSON_FORMAT_UNKNOWN = 0;
const int JSON_FORMAT_ALLOW = 1;
const int JSON_FORMAT_LEGACY_BEST_EFFORT = 2;

// Message encoding feature values
const int MESSAGE_ENCODING_UNKNOWN = 0;
const int MESSAGE_ENCODING_LENGTH_PREFIXED = 1;
const int MESSAGE_ENCODING_DELIMITED = 2;

/// Feature set with numeric values matching protobuf descriptors
class ResolvedFeatures {
  final int fieldPresence;
  final int enumType;
  final int repeatedFieldEncoding;
  final int utf8Validation;
  final int jsonFormat;
  final int messageEncoding;
  final int dartApiLevel;

  const ResolvedFeatures({
    required this.fieldPresence,
    required this.enumType,
    required this.repeatedFieldEncoding,
    required this.utf8Validation,
    required this.jsonFormat,
    required this.messageEncoding,
    required this.dartApiLevel,
  });

  ResolvedFeatures copyWith({
    int? fieldPresence,
    int? enumType,
    int? repeatedFieldEncoding,
    int? utf8Validation,
    int? jsonFormat,
    int? messageEncoding,
    int? dartApiLevel,
  }) {
    return ResolvedFeatures(
      fieldPresence: fieldPresence ?? this.fieldPresence,
      enumType: enumType ?? this.enumType,
      repeatedFieldEncoding:
          repeatedFieldEncoding ?? this.repeatedFieldEncoding,
      utf8Validation: utf8Validation ?? this.utf8Validation,
      jsonFormat: jsonFormat ?? this.jsonFormat,
      messageEncoding: messageEncoding ?? this.messageEncoding,
      dartApiLevel: dartApiLevel ?? this.dartApiLevel,
    );
  }
}

/// Default feature sets for different editions (matching protobuf-es structure)
const Map<int, ResolvedFeatures> _featureDefaults = {
  // EDITION_PROTO2 = 998
  998: ResolvedFeatures(
    fieldPresence: FIELD_PRESENCE_EXPLICIT,
    enumType: ENUM_TYPE_CLOSED,
    repeatedFieldEncoding: REPEATED_FIELD_ENCODING_EXPANDED,
    utf8Validation: UTF8_VALIDATION_NONE,
    jsonFormat: JSON_FORMAT_LEGACY_BEST_EFFORT,
    messageEncoding: MESSAGE_ENCODING_LENGTH_PREFIXED,
    dartApiLevel: API_LEVEL_HAZZERS,
  ),
  // EDITION_PROTO3 = 999
  999: ResolvedFeatures(
    fieldPresence: FIELD_PRESENCE_IMPLICIT,
    enumType: ENUM_TYPE_OPEN,
    repeatedFieldEncoding: REPEATED_FIELD_ENCODING_PACKED,
    utf8Validation: UTF8_VALIDATION_VERIFY,
    jsonFormat: JSON_FORMAT_ALLOW,
    messageEncoding: MESSAGE_ENCODING_LENGTH_PREFIXED,
    dartApiLevel: API_LEVEL_HAZZERS,
  ),
  // EDITION_2023 = 1000
  1000: ResolvedFeatures(
    fieldPresence: FIELD_PRESENCE_EXPLICIT,
    enumType: ENUM_TYPE_OPEN,
    repeatedFieldEncoding: REPEATED_FIELD_ENCODING_PACKED,
    utf8Validation: UTF8_VALIDATION_VERIFY,
    jsonFormat: JSON_FORMAT_ALLOW,
    messageEncoding: MESSAGE_ENCODING_LENGTH_PREFIXED,
    dartApiLevel: API_LEVEL_NULLABLE,
  ),
};

/// Get the edition number for a file
int _getFileEdition(FileDescriptorProto file) {
  if (file.hasEdition() && file.edition != Edition.EDITION_UNKNOWN) {
    return file.edition.value;
  }
  // Map legacy syntax to edition numbers
  return file.syntax == 'proto3' ? 999 : 998;
}

/// Generic feature resolution function (similar to protobuf-es)
///
/// Resolves a specific feature by walking up the hierarchy:
/// field/enum → message → file → edition defaults
T _resolveFeatureInternal<T>(
  String featureName,
  dynamic descriptor,
  FileDescriptorProto file,
  dynamic parent,
) {
  // Check if the descriptor has options with features set
  var options = descriptor?.options;
  if (options != null && options.hasFeatures()) {
    final features = options.features;
    final value = _getFeatureValue(features, featureName);
    if (value != null && value != 0) {
      return value as T;
    }
  }

  // If we have a parent descriptor, recurse up the hierarchy
  if (parent != null) {
    return _resolveFeatureInternal<T>(
      featureName,
      parent,
      file,
      _getParentDescriptor(parent),
    );
  }

  // Check file-level features
  if (file.hasOptions() && file.options.hasFeatures()) {
    final value = _getFeatureValue(file.options.features, featureName);
    if (value != null && value != 0) {
      return value as T;
    }
  }

  // Fall back to edition defaults
  final edition = _getFileEdition(file);
  final defaults = _featureDefaults[edition];
  if (defaults == null) {
    throw ArgumentError('Unsupported edition: $edition');
  }
  return _getFeatureFromDefaults(defaults, featureName) as T;
}

/// Get the parent descriptor for feature resolution
dynamic _getParentDescriptor(dynamic descriptor) {
  // For nested messages/enums, we need to return the parent message descriptor
  // This will be handled by the calling code which has access to the parent
  return null;
}

/// Extract a feature value from a FeatureSet message
dynamic _getFeatureValue(FeatureSet features, String featureName) {
  switch (featureName) {
    case 'fieldPresence':
      return features.hasFieldPresence() ? features.fieldPresence.value : null;
    case 'enumType':
      return features.hasEnumType() ? features.enumType.value : null;
    case 'repeatedFieldEncoding':
      return features.hasRepeatedFieldEncoding()
          ? features.repeatedFieldEncoding.value
          : null;
    case 'utf8Validation':
      return features.hasUtf8Validation()
          ? features.utf8Validation.value
          : null;
    case 'jsonFormat':
      return features.hasJsonFormat() ? features.jsonFormat.value : null;
    case 'messageEncoding':
      return features.hasMessageEncoding()
          ? features.messageEncoding.value
          : null;
    default:
      return null;
  }
}

/// Extract a feature value from resolved defaults
dynamic _getFeatureFromDefaults(ResolvedFeatures defaults, String featureName) {
  switch (featureName) {
    case 'fieldPresence':
      return defaults.fieldPresence;
    case 'enumType':
      return defaults.enumType;
    case 'repeatedFieldEncoding':
      return defaults.repeatedFieldEncoding;
    case 'utf8Validation':
      return defaults.utf8Validation;
    case 'jsonFormat':
      return defaults.jsonFormat;
    case 'messageEncoding':
      return defaults.messageEncoding;
    default:
      return null;
  }
}

/// Resolve all features for a file
ResolvedFeatures resolveFileFeatures(FileDescriptorProto file) {
  final edition = _getFileEdition(file);
  var features = _featureDefaults[edition];
  if (features == null) {
    throw ArgumentError('Unsupported edition: $edition');
  }

  // Apply file-level feature overrides if present
  if (file.hasOptions() && file.options.hasFeatures()) {
    final overrides = file.options.features;
    features = features.copyWith(
      fieldPresence:
          overrides.hasFieldPresence() ? overrides.fieldPresence.value : null,
      enumType: overrides.hasEnumType() ? overrides.enumType.value : null,
      repeatedFieldEncoding:
          overrides.hasRepeatedFieldEncoding()
              ? overrides.repeatedFieldEncoding.value
              : null,
      utf8Validation:
          overrides.hasUtf8Validation() ? overrides.utf8Validation.value : null,
      jsonFormat: overrides.hasJsonFormat() ? overrides.jsonFormat.value : null,
      messageEncoding:
          overrides.hasMessageEncoding()
              ? overrides.messageEncoding.value
              : null,
    );
  }

  return features;
}

/// Resolve field presence with special case handling
int resolveFieldPresence(
  FieldDescriptorProto field,
  FileDescriptorProto file, {
  dynamic parentDescriptor,
  bool isExtension = false,
}) {
  // Handle proto2 required fields
  if (field.label == FieldDescriptorProto_Label.LABEL_REQUIRED) {
    return FIELD_PRESENCE_LEGACY_REQUIRED;
  }

  // Repeated fields (including maps) do not track presence
  if (field.label == FieldDescriptorProto_Label.LABEL_REPEATED) {
    return FIELD_PRESENCE_IMPLICIT;
  }

  // Oneof fields always use explicit presence
  if (field.hasOneofIndex()) {
    return FIELD_PRESENCE_EXPLICIT;
  }

  // Proto3 optional fields use explicit presence
  if (field.hasProto3Optional() && field.proto3Optional) {
    return FIELD_PRESENCE_EXPLICIT;
  }

  // Extensions always track presence
  if (isExtension) {
    return FIELD_PRESENCE_EXPLICIT;
  }

  // Get the resolved feature value
  final presence = _resolveFeatureInternal<int>(
    'fieldPresence',
    field,
    file,
    parentDescriptor,
  );

  // Message and group fields cannot have implicit presence
  if (presence == FIELD_PRESENCE_IMPLICIT) {
    if (field.type == FieldDescriptorProto_Type.TYPE_MESSAGE ||
        field.type == FieldDescriptorProto_Type.TYPE_GROUP) {
      return FIELD_PRESENCE_EXPLICIT;
    }
  }

  return presence;
}

/// Resolve packed encoding for repeated fields
bool resolvePackedEncoding(
  FieldDescriptorProto field,
  FileDescriptorProto file, {
  dynamic parentDescriptor,
}) {
  // Only repeated fields can be packed
  if (field.label != FieldDescriptorProto_Label.LABEL_REPEATED) {
    return false;
  }

  // Length-delimited types cannot be packed
  switch (field.type) {
    case FieldDescriptorProto_Type.TYPE_STRING:
    case FieldDescriptorProto_Type.TYPE_BYTES:
    case FieldDescriptorProto_Type.TYPE_MESSAGE:
    case FieldDescriptorProto_Type.TYPE_GROUP:
      return false;
    default:
      // All other types can be packed
      break;
  }

  // Check for explicit packed option first
  if (field.hasOptions() && field.options.hasPacked()) {
    return field.options.packed;
  }

  // Use feature resolution
  final encoding = _resolveFeatureInternal<int>(
    'repeatedFieldEncoding',
    field,
    file,
    parentDescriptor,
  );

  return encoding == REPEATED_FIELD_ENCODING_PACKED;
}

/// Resolve if an enum is open or closed
bool resolveEnumIsOpen(
  EnumDescriptorProto enumDesc,
  FileDescriptorProto file, {
  dynamic parentDescriptor,
}) {
  final enumType = _resolveFeatureInternal<int>(
    'enumType',
    enumDesc,
    file,
    parentDescriptor,
  );

  return enumType == ENUM_TYPE_OPEN;
}

/// Resolve message encoding (delimited vs length-prefixed)
bool resolveDelimitedEncoding(
  FieldDescriptorProto field,
  FileDescriptorProto file, {
  dynamic parentDescriptor,
  bool isMapValueField = false,
}) {
  // GROUP type always uses delimited encoding
  if (field.type == FieldDescriptorProto_Type.TYPE_GROUP) {
    return true;
  }

  // Only message fields can have delimited encoding
  if (field.type != FieldDescriptorProto_Type.TYPE_MESSAGE) {
    return false;
  }

  // Map value fields always use LENGTH_PREFIXED encoding
  // (map entries are synthetic and never use group encoding)
  if (isMapValueField) {
    return false;
  }

  final encoding = _resolveFeatureInternal<int>(
    'messageEncoding',
    field,
    file,
    parentDescriptor,
  );

  return encoding == MESSAGE_ENCODING_DELIMITED;
}

/// Convert string API level to constant
int _apiLevelFromString(String apiLevel) {
  switch (apiLevel) {
    case 'API_LEVEL_HAZZERS':
      return API_LEVEL_HAZZERS;
    case 'API_LEVEL_NULLABLE':
      return API_LEVEL_NULLABLE;
    case 'API_LEVEL_HYBRID':
      return API_LEVEL_HYBRID;
    default:
      return API_LEVEL_UNSPECIFIED;
  }
}

/// Resolve Dart API level for a file with command-line overrides
int resolveDartApiLevel(FileDescriptorProto file, GenerationOptions options) {
  // 1. Check for per-file command-line override
  final filename = file.name;
  if (options.apiLevelMappings.containsKey(filename)) {
    return _apiLevelFromString(options.apiLevelMappings[filename]!);
  }

  // 2. Check for global default command-line option
  if (options.defaultApiLevel != null) {
    return _apiLevelFromString(options.defaultApiLevel!);
  }

  // 3. TODO: Check for proto file features once dart_features.proto is compiled
  // This will require access to the dart extension
  // if (file.hasOptions() && file.options.hasFeatures()) {
  //   final dartFeatures = file.options.features.getExtension(dart);
  //   if (dartFeatures?.hasApiLevel()) {
  //     return dartFeatures.apiLevel.value;
  //   }
  // }

  // 4. Use edition defaults
  final edition = _getFileEdition(file);
  final defaults = _featureDefaults[edition];
  if (defaults != null) {
    return defaults.dartApiLevel;
  }

  // Safe fallback to HAZZERS for unknown editions
  return API_LEVEL_HAZZERS;
}
