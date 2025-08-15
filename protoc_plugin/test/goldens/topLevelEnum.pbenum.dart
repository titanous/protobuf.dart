// This is a generated file - do not edit.
//
// Generated from test.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

enum PhoneType implements $pb.ProtobufEnum {
  MOBILE(0, _omitEnumNames ? '' : 'MOBILE'),

  HOME(1, _omitEnumNames ? '' : 'HOME'),

  WORK(2, _omitEnumNames ? '' : 'WORK'),
  ;

  static const PhoneType BUSINESS = WORK;

  static final $core.Map<$core.int, PhoneType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static PhoneType? valueOf($core.int value) => _byValue[value];

  static PhoneType? valueByName($core.String name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    switch (name) {
      case 'BUSINESS':
        return WORK;
      default:
        return null;
    }
  }

  static const $core.List<PhoneType> valuesWithAliases = <PhoneType>[
    MOBILE,
    HOME,
    WORK,
    BUSINESS,
  ];

  @$core.override
  final $core.int value;

  @$core.override
  final $core.String name;

  const PhoneType(this.value, this.name);

  /// Returns this enum's [name] or the [value] if names are not represented.
  @$core.override
  $core.String toString() => name == '' ? value.toString() : name;
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
