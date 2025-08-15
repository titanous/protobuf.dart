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

import 'dart_features.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'dart_features.pbenum.dart';

/// Dart-specific features that can be applied at file or message level
class DartFeatures extends $pb.GeneratedMessage {
  factory DartFeatures({
    DartFeatures_ApiLevel? apiLevel,
  }) {
    final result = create();
    if (apiLevel != null) result.apiLevel = apiLevel;
    return result;
  }

  DartFeatures._();

  factory DartFeatures.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DartFeatures.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DartFeatures',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dart.features'),
      createEmptyInstance: create)
    ..e<DartFeatures_ApiLevel>(
        1, _omitFieldNames ? '' : 'apiLevel', $pb.PbFieldType.OE,
        defaultOrMaker: DartFeatures_ApiLevel.API_LEVEL_UNSPECIFIED,
        valueOf: DartFeatures_ApiLevel.valueOf,
        enumValues: DartFeatures_ApiLevel.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DartFeatures clone() => DartFeatures()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DartFeatures copyWith(void Function(DartFeatures) updates) =>
      super.copyWith((message) => updates(message as DartFeatures))
          as DartFeatures;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DartFeatures create() => DartFeatures._();
  @$core.override
  DartFeatures createEmptyInstance() => create();
  static $pb.PbList<DartFeatures> createRepeated() =>
      $pb.PbList<DartFeatures>();
  @$core.pragma('dart2js:noInline')
  static DartFeatures getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DartFeatures>(create);
  static DartFeatures? _defaultInstance;

  /// Controls the API level for field presence in generated Dart code.
  /// Edition defaults are handled in code:
  /// - EDITION_PROTO2: API_HAZZERS (backward compatibility)
  /// - EDITION_PROTO3: API_HAZZERS (backward compatibility)
  /// - EDITION_2023: API_NULLABLE (modern default)
  /// - EDITION_2024: API_NULLABLE (modern default)
  @$pb.TagNumber(1)
  DartFeatures_ApiLevel get apiLevel => $_getN(0);
  @$pb.TagNumber(1)
  set apiLevel(DartFeatures_ApiLevel value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasApiLevel() => $_has(0);
  @$pb.TagNumber(1)
  void clearApiLevel() => $_clearField(1);
}

class Dart_features {
  static final dart = $pb.Extension<DartFeatures>(
      _omitMessageNames ? '' : 'google.protobuf.FeatureSet',
      _omitFieldNames ? '' : 'dart',
      9995,
      $pb.PbFieldType.OM,
      defaultOrMaker: DartFeatures.getDefault,
      subBuilder: DartFeatures.create);
  static void registerAllExtensions($pb.ExtensionRegistry registry) {
    registry.add(dart);
  }
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
