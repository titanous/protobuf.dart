// This is a generated file - do not edit.
//
// Generated from dart_features.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// API level controls the generated Dart API style for field presence.
class DartFeatures_ApiLevel extends $pb.ProtobufEnum {
  /// Unspecified defaults to edition-specific behavior
  static const DartFeatures_ApiLevel API_LEVEL_UNSPECIFIED =
      DartFeatures_ApiLevel._(0, _omitEnumNames ? '' : 'API_LEVEL_UNSPECIFIED');

  /// HAZZERS: Traditional mode with hasXxx() methods for presence tracking.
  /// Non-nullable types for optional fields.
  /// This is the default for proto2 and proto3.
  static const DartFeatures_ApiLevel API_HAZZERS =
      DartFeatures_ApiLevel._(1, _omitEnumNames ? '' : 'API_HAZZERS');

  /// NULLABLE: Modern mode using nullable types without hazzer methods.
  /// Null indicates field absence.
  /// This is the default for edition 2023 and later.
  static const DartFeatures_ApiLevel API_NULLABLE =
      DartFeatures_ApiLevel._(2, _omitEnumNames ? '' : 'API_NULLABLE');

  /// HYBRID: Both nullable types AND hazzer methods.
  /// Provides flexibility for transition.
  static const DartFeatures_ApiLevel API_HYBRID =
      DartFeatures_ApiLevel._(3, _omitEnumNames ? '' : 'API_HYBRID');

  static const $core.List<DartFeatures_ApiLevel> values =
      <DartFeatures_ApiLevel>[
    API_LEVEL_UNSPECIFIED,
    API_HAZZERS,
    API_NULLABLE,
    API_HYBRID,
  ];

  static final $core.List<DartFeatures_ApiLevel?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static DartFeatures_ApiLevel? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DartFeatures_ApiLevel._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
