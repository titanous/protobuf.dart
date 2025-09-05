// This is a generated file - do not edit.
//
// Generated from edition2023_nullability.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use testEnumDescriptor instead')
const TestEnum$json = {
  '1': 'TestEnum',
  '2': [
    {'1': 'TEST_ENUM_UNSPECIFIED', '2': 0},
    {'1': 'TEST_ENUM_VALUE1', '2': 1},
    {'1': 'TEST_ENUM_VALUE2', '2': 2},
  ],
};

/// Descriptor for `TestEnum`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List testEnumDescriptor = $convert.base64Decode(
    'CghUZXN0RW51bRIZChVURVNUX0VOVU1fVU5TUEVDSUZJRUQQABIUChBURVNUX0VOVU1fVkFMVU'
    'UxEAESFAoQVEVTVF9FTlVNX1ZBTFVFMhAC');

@$core.Deprecated('Use testMessageDescriptor instead')
const TestMessage$json = {
  '1': 'TestMessage',
  '2': [
    {'1': 'explicit_string', '3': 1, '4': 1, '5': 9, '10': 'explicitString'},
    {'1': 'explicit_int32', '3': 2, '4': 1, '5': 5, '10': 'explicitInt32'},
    {'1': 'explicit_bool', '3': 3, '4': 1, '5': 8, '10': 'explicitBool'},
    {
      '1': 'explicit_message',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.edition2023_nullability.TestMessage',
      '10': 'explicitMessage'
    },
    {
      '1': 'explicit_enum',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.edition2023_nullability.TestEnum',
      '10': 'explicitEnum'
    },
    {
      '1': 'implicit_string',
      '3': 11,
      '4': 1,
      '5': 9,
      '8': {
        '21': {'1': 2},
      },
      '10': 'implicitString',
    },
    {
      '1': 'implicit_int32',
      '3': 12,
      '4': 1,
      '5': 5,
      '8': {
        '21': {'1': 2},
      },
      '10': 'implicitInt32',
    },
    {
      '1': 'implicit_bool',
      '3': 13,
      '4': 1,
      '5': 8,
      '8': {
        '21': {'1': 2},
      },
      '10': 'implicitBool',
    },
    {
      '1': 'implicit_enum',
      '3': 15,
      '4': 1,
      '5': 14,
      '6': '.edition2023_nullability.TestEnum',
      '8': {
        '21': {'1': 2},
      },
      '10': 'implicitEnum',
    },
    {'1': 'repeated_strings', '3': 21, '4': 3, '5': 9, '10': 'repeatedStrings'},
    {'1': 'repeated_ints', '3': 22, '4': 3, '5': 5, '10': 'repeatedInts'},
    {
      '1': 'repeated_messages',
      '3': 23,
      '4': 3,
      '5': 11,
      '6': '.edition2023_nullability.TestMessage',
      '10': 'repeatedMessages'
    },
    {
      '1': 'string_map',
      '3': 31,
      '4': 3,
      '5': 11,
      '6': '.edition2023_nullability.TestMessage.StringMapEntry',
      '10': 'stringMap'
    },
    {
      '1': 'int_map',
      '3': 32,
      '4': 3,
      '5': 11,
      '6': '.edition2023_nullability.TestMessage.IntMapEntry',
      '10': 'intMap'
    },
    {
      '1': 'message_map',
      '3': 33,
      '4': 3,
      '5': 11,
      '6': '.edition2023_nullability.TestMessage.MessageMapEntry',
      '10': 'messageMap'
    },
    {'1': 'oneof_string', '3': 41, '4': 1, '5': 9, '9': 0, '10': 'oneofString'},
    {'1': 'oneof_int32', '3': 42, '4': 1, '5': 5, '9': 0, '10': 'oneofInt32'},
    {
      '1': 'oneof_message',
      '3': 43,
      '4': 1,
      '5': 11,
      '6': '.edition2023_nullability.TestMessage',
      '9': 0,
      '10': 'oneofMessage'
    },
  ],
  '3': [
    TestMessage_StringMapEntry$json,
    TestMessage_IntMapEntry$json,
    TestMessage_MessageMapEntry$json
  ],
  '8': [
    {'1': 'test_oneof'},
  ],
};

@$core.Deprecated('Use testMessageDescriptor instead')
const TestMessage_StringMapEntry$json = {
  '1': 'StringMapEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use testMessageDescriptor instead')
const TestMessage_IntMapEntry$json = {
  '1': 'IntMapEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use testMessageDescriptor instead')
const TestMessage_MessageMapEntry$json = {
  '1': 'MessageMapEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.edition2023_nullability.TestMessage',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `TestMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testMessageDescriptor = $convert.base64Decode(
    'CgtUZXN0TWVzc2FnZRInCg9leHBsaWNpdF9zdHJpbmcYASABKAlSDmV4cGxpY2l0U3RyaW5nEi'
    'UKDmV4cGxpY2l0X2ludDMyGAIgASgFUg1leHBsaWNpdEludDMyEiMKDWV4cGxpY2l0X2Jvb2wY'
    'AyABKAhSDGV4cGxpY2l0Qm9vbBJPChBleHBsaWNpdF9tZXNzYWdlGAQgASgLMiQuZWRpdGlvbj'
    'IwMjNfbnVsbGFiaWxpdHkuVGVzdE1lc3NhZ2VSD2V4cGxpY2l0TWVzc2FnZRJGCg1leHBsaWNp'
    'dF9lbnVtGAUgASgOMiEuZWRpdGlvbjIwMjNfbnVsbGFiaWxpdHkuVGVzdEVudW1SDGV4cGxpY2'
    'l0RW51bRIuCg9pbXBsaWNpdF9zdHJpbmcYCyABKAlCBaoBAggCUg5pbXBsaWNpdFN0cmluZxIs'
    'Cg5pbXBsaWNpdF9pbnQzMhgMIAEoBUIFqgECCAJSDWltcGxpY2l0SW50MzISKgoNaW1wbGljaX'
    'RfYm9vbBgNIAEoCEIFqgECCAJSDGltcGxpY2l0Qm9vbBJNCg1pbXBsaWNpdF9lbnVtGA8gASgO'
    'MiEuZWRpdGlvbjIwMjNfbnVsbGFiaWxpdHkuVGVzdEVudW1CBaoBAggCUgxpbXBsaWNpdEVudW'
    '0SKQoQcmVwZWF0ZWRfc3RyaW5ncxgVIAMoCVIPcmVwZWF0ZWRTdHJpbmdzEiMKDXJlcGVhdGVk'
    'X2ludHMYFiADKAVSDHJlcGVhdGVkSW50cxJRChFyZXBlYXRlZF9tZXNzYWdlcxgXIAMoCzIkLm'
    'VkaXRpb24yMDIzX251bGxhYmlsaXR5LlRlc3RNZXNzYWdlUhByZXBlYXRlZE1lc3NhZ2VzElIK'
    'CnN0cmluZ19tYXAYHyADKAsyMy5lZGl0aW9uMjAyM19udWxsYWJpbGl0eS5UZXN0TWVzc2FnZS'
    '5TdHJpbmdNYXBFbnRyeVIJc3RyaW5nTWFwEkkKB2ludF9tYXAYICADKAsyMC5lZGl0aW9uMjAy'
    'M19udWxsYWJpbGl0eS5UZXN0TWVzc2FnZS5JbnRNYXBFbnRyeVIGaW50TWFwElUKC21lc3NhZ2'
    'VfbWFwGCEgAygLMjQuZWRpdGlvbjIwMjNfbnVsbGFiaWxpdHkuVGVzdE1lc3NhZ2UuTWVzc2Fn'
    'ZU1hcEVudHJ5UgptZXNzYWdlTWFwEiMKDG9uZW9mX3N0cmluZxgpIAEoCUgAUgtvbmVvZlN0cm'
    'luZxIhCgtvbmVvZl9pbnQzMhgqIAEoBUgAUgpvbmVvZkludDMyEksKDW9uZW9mX21lc3NhZ2UY'
    'KyABKAsyJC5lZGl0aW9uMjAyM19udWxsYWJpbGl0eS5UZXN0TWVzc2FnZUgAUgxvbmVvZk1lc3'
    'NhZ2UaPAoOU3RyaW5nTWFwRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlS'
    'BXZhbHVlOgI4ARo5CgtJbnRNYXBFbnRyeRIQCgNrZXkYASABKAVSA2tleRIUCgV2YWx1ZRgCIA'
    'EoBVIFdmFsdWU6AjgBGmMKD01lc3NhZ2VNYXBFbnRyeRIQCgNrZXkYASABKAlSA2tleRI6CgV2'
    'YWx1ZRgCIAEoCzIkLmVkaXRpb24yMDIzX251bGxhYmlsaXR5LlRlc3RNZXNzYWdlUgV2YWx1ZT'
    'oCOAFCDAoKdGVzdF9vbmVvZg==');
