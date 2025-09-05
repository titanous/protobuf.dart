// This is a generated file - do not edit.
//
// Generated from edition2023_nullability.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'edition2023_nullability.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'edition2023_nullability.pbenum.dart';

enum TestMessage_TestOneof { oneofString, oneofInt32, oneofMessage, notSet }

class TestMessage extends $pb.GeneratedMessage {
  factory TestMessage({
    $core.String? explicitString,
    $core.int? explicitInt32,
    $core.bool? explicitBool,
    TestMessage? explicitMessage,
    TestEnum? explicitEnum,
    $core.String? implicitString,
    $core.int? implicitInt32,
    $core.bool? implicitBool,
    TestEnum? implicitEnum,
    $core.Iterable<$core.String>? repeatedStrings,
    $core.Iterable<$core.int>? repeatedInts,
    $core.Iterable<TestMessage>? repeatedMessages,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? stringMap,
    $core.Iterable<$core.MapEntry<$core.int, $core.int>>? intMap,
    $core.Iterable<$core.MapEntry<$core.String, TestMessage>>? messageMap,
    $core.String? oneofString,
    $core.int? oneofInt32,
    TestMessage? oneofMessage,
  }) {
    final result = create();
    if (explicitString != null) result.explicitString = explicitString;
    if (explicitInt32 != null) result.explicitInt32 = explicitInt32;
    if (explicitBool != null) result.explicitBool = explicitBool;
    if (explicitMessage != null) result.explicitMessage = explicitMessage;
    if (explicitEnum != null) result.explicitEnum = explicitEnum;
    if (implicitString != null) result.implicitString = implicitString;
    if (implicitInt32 != null) result.implicitInt32 = implicitInt32;
    if (implicitBool != null) result.implicitBool = implicitBool;
    if (implicitEnum != null) result.implicitEnum = implicitEnum;
    if (repeatedStrings != null) result.repeatedStrings.addAll(repeatedStrings);
    if (repeatedInts != null) result.repeatedInts.addAll(repeatedInts);
    if (repeatedMessages != null)
      result.repeatedMessages.addAll(repeatedMessages);
    if (stringMap != null) result.stringMap.addEntries(stringMap);
    if (intMap != null) result.intMap.addEntries(intMap);
    if (messageMap != null) result.messageMap.addEntries(messageMap);
    if (oneofString != null) result.oneofString = oneofString;
    if (oneofInt32 != null) result.oneofInt32 = oneofInt32;
    if (oneofMessage != null) result.oneofMessage = oneofMessage;
    return result;
  }

  TestMessage._();

  factory TestMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TestMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, TestMessage_TestOneof>
      _TestMessage_TestOneofByTag = {
    41: TestMessage_TestOneof.oneofString,
    42: TestMessage_TestOneof.oneofInt32,
    43: TestMessage_TestOneof.oneofMessage,
    0: TestMessage_TestOneof.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TestMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'edition2023_nullability'),
      createEmptyInstance: create)
    ..oo(0, [41, 42, 43], 'test_oneof')
    ..aOS(1, _omitFieldNames ? '' : 'explicitString')
    ..a<$core.int>(
        2, _omitFieldNames ? '' : 'explicitInt32', $pb.PbFieldType.O3)
    ..aOB(3, _omitFieldNames ? '' : 'explicitBool')
    ..aOM<TestMessage>(4, _omitFieldNames ? '' : 'explicitMessage',
        subBuilder: TestMessage.create)
    ..e<TestEnum>(5, _omitFieldNames ? '' : 'explicitEnum', $pb.PbFieldType.OE,
        defaultOrMaker: TestEnum.TEST_ENUM_UNSPECIFIED,
        valueOf: TestEnum.valueOf,
        enumValues: TestEnum.values)
    ..aOS(11, _omitFieldNames ? '' : 'implicitString',
        presence: $pb.FieldPresence.implicit)
    ..a<$core.int>(
        12, _omitFieldNames ? '' : 'implicitInt32', $pb.PbFieldType.O3,
        presence: $pb.FieldPresence.implicit)
    ..aOB(13, _omitFieldNames ? '' : 'implicitBool',
        presence: $pb.FieldPresence.implicit)
    ..e<TestEnum>(15, _omitFieldNames ? '' : 'implicitEnum', $pb.PbFieldType.OE,
        presence: $pb.FieldPresence.implicit,
        defaultOrMaker: TestEnum.TEST_ENUM_UNSPECIFIED,
        valueOf: TestEnum.valueOf,
        enumValues: TestEnum.values)
    ..pPS(21, _omitFieldNames ? '' : 'repeatedStrings')
    ..p<$core.int>(
        22, _omitFieldNames ? '' : 'repeatedInts', $pb.PbFieldType.K3)
    ..pc<TestMessage>(
        23, _omitFieldNames ? '' : 'repeatedMessages', $pb.PbFieldType.PM,
        subBuilder: TestMessage.create)
    ..m<$core.String, $core.String>(31, _omitFieldNames ? '' : 'stringMap',
        entryClassName: 'TestMessage.StringMapEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('edition2023_nullability'))
    ..m<$core.int, $core.int>(32, _omitFieldNames ? '' : 'intMap',
        entryClassName: 'TestMessage.IntMapEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('edition2023_nullability'))
    ..m<$core.String, TestMessage>(33, _omitFieldNames ? '' : 'messageMap',
        entryClassName: 'TestMessage.MessageMapEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: TestMessage.create,
        valueDefaultOrMaker: TestMessage.getDefault,
        packageName: const $pb.PackageName('edition2023_nullability'))
    ..aOS(41, _omitFieldNames ? '' : 'oneofString')
    ..a<$core.int>(42, _omitFieldNames ? '' : 'oneofInt32', $pb.PbFieldType.O3)
    ..aOM<TestMessage>(43, _omitFieldNames ? '' : 'oneofMessage',
        subBuilder: TestMessage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestMessage copyWith(void Function(TestMessage) updates) =>
      super.copyWith((message) => updates(message as TestMessage))
          as TestMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestMessage create() => TestMessage._();
  @$core.override
  TestMessage createEmptyInstance() => create();
  static $pb.PbList<TestMessage> createRepeated() => $pb.PbList<TestMessage>();
  @$core.pragma('dart2js:noInline')
  static TestMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TestMessage>(create);
  static TestMessage? _defaultInstance;

  TestMessage_TestOneof whichTestOneof() =>
      _TestMessage_TestOneofByTag[$_whichOneof(0)]!;
  void clearTestOneof() => $_clearField($_whichOneof(0));

  /// Explicit presence fields (default for edition 2023)
  @$pb.TagNumber(1)
  $core.String? get explicitString => $_getSNullable(0);
  @$pb.TagNumber(1)
  set explicitString($core.String? value) => $_setStringNullable(0, value);
  @$pb.TagNumber(1)
  void clearExplicitString() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int? get explicitInt32 => $_getINullable(1);
  @$pb.TagNumber(2)
  set explicitInt32($core.int? value) => $_setSignedInt32Nullable(1, value);
  @$pb.TagNumber(2)
  void clearExplicitInt32() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool? get explicitBool => $_getBNullable(2);
  @$pb.TagNumber(3)
  set explicitBool($core.bool? value) => $_setBoolNullable(2, value);
  @$pb.TagNumber(3)
  void clearExplicitBool() => $_clearField(3);

  @$pb.TagNumber(4)
  TestMessage? get explicitMessage => $_getNullable(3);
  @$pb.TagNumber(4)
  set explicitMessage(TestMessage? value) => $_setFieldNullable(4, value);
  @$pb.TagNumber(4)
  void clearExplicitMessage() => $_clearField(4);

  @$pb.TagNumber(5)
  TestEnum? get explicitEnum => $_getNullable(4);
  @$pb.TagNumber(5)
  set explicitEnum(TestEnum? value) => $_setFieldNullable(5, value);
  @$pb.TagNumber(5)
  void clearExplicitEnum() => $_clearField(5);

  /// Implicit presence fields (scalar and enum only - messages can't have implicit presence)
  @$pb.TagNumber(11)
  $core.String get implicitString => $_getSZ(5);
  @$pb.TagNumber(11)
  set implicitString($core.String value) => $_setString(5, value);
  @$pb.TagNumber(11)
  void clearImplicitString() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get implicitInt32 => $_getIZ(6);
  @$pb.TagNumber(12)
  set implicitInt32($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(12)
  void clearImplicitInt32() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get implicitBool => $_getBF(7);
  @$pb.TagNumber(13)
  set implicitBool($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(13)
  void clearImplicitBool() => $_clearField(13);

  @$pb.TagNumber(15)
  TestEnum get implicitEnum => $_getN(8);
  @$pb.TagNumber(15)
  set implicitEnum(TestEnum value) => $_setField(15, value);
  @$pb.TagNumber(15)
  void clearImplicitEnum() => $_clearField(15);

  /// Collections (always non-nullable)
  @$pb.TagNumber(21)
  $pb.PbList<$core.String> get repeatedStrings => $_getList(9);

  @$pb.TagNumber(22)
  $pb.PbList<$core.int> get repeatedInts => $_getList(10);

  @$pb.TagNumber(23)
  $pb.PbList<TestMessage> get repeatedMessages => $_getList(11);

  @$pb.TagNumber(31)
  $pb.PbMap<$core.String, $core.String> get stringMap => $_getMap(12);

  @$pb.TagNumber(32)
  $pb.PbMap<$core.int, $core.int> get intMap => $_getMap(13);

  @$pb.TagNumber(33)
  $pb.PbMap<$core.String, TestMessage> get messageMap => $_getMap(14);

  @$pb.TagNumber(41)
  $core.String? get oneofString => $_getSNullable(15);
  @$pb.TagNumber(41)
  set oneofString($core.String? value) => $_setStringNullable(15, value);
  @$pb.TagNumber(41)
  void clearOneofString() => $_clearField(41);

  @$pb.TagNumber(42)
  $core.int? get oneofInt32 => $_getINullable(16);
  @$pb.TagNumber(42)
  set oneofInt32($core.int? value) => $_setSignedInt32Nullable(16, value);
  @$pb.TagNumber(42)
  void clearOneofInt32() => $_clearField(42);

  @$pb.TagNumber(43)
  TestMessage? get oneofMessage => $_getNullable(17);
  @$pb.TagNumber(43)
  set oneofMessage(TestMessage? value) => $_setFieldNullable(43, value);
  @$pb.TagNumber(43)
  void clearOneofMessage() => $_clearField(43);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
