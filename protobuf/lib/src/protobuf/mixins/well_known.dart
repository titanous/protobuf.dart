// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:fixnum/fixnum.dart';

import '../internal.dart';
import '../json_parsing_context.dart';

/// The set of well known protobuf message types which may have customized
/// serialization logic.
enum WellKnownType {
  any,
  timestamp,
  duration,
  struct,
  value,
  listValue,
  fieldMask,
  doubleValue,
  floatValue,
  int64Value,
  uint64Value,
  int32Value,
  uint32Value,
  boolValue,
  stringValue,
  bytesValue,
}

mixin AnyMixin implements GeneratedMessage {
  String get typeUrl;
  set typeUrl(String value);

  List<int> get value;
  set value(List<int> value);

  /// Returns `true` if the encoded message matches the type of [instance].
  ///
  /// Can be used with a default instance:
  /// `any.canUnpackInto(Message.getDefault())`
  bool canUnpackInto(GeneratedMessage instance) {
    return canUnpackIntoHelper(instance, typeUrl);
  }

  /// Unpacks the message in [value] into [instance].
  ///
  /// Throws a [InvalidProtocolBufferException] if [typeUrl] does not correspond
  /// to the type of [instance].
  ///
  /// A typical usage would be `any.unpackInto(Message())`.
  ///
  /// Returns [instance].
  T unpackInto<T extends GeneratedMessage>(
    T instance, {
    ExtensionRegistry extensionRegistry = ExtensionRegistry.EMPTY,
  }) {
    unpackIntoHelper(
      value,
      instance,
      typeUrl,
      extensionRegistry: extensionRegistry,
    );
    return instance;
  }

  /// Updates [target] to be the packed representation of [message].
  ///
  /// The [typeUrl] will be [typeUrlPrefix]/`fullName` where `fullName` is
  /// the fully qualified name of the type of [message].
  static void packIntoAny(
    AnyMixin target,
    GeneratedMessage message, {
    String typeUrlPrefix = 'type.googleapis.com',
  }) {
    target.value = message.writeToBuffer();
    target.typeUrl = '$typeUrlPrefix/${message.info_.qualifiedMessageName}';
  }

  // From google/protobuf/any.proto:
  // JSON
  // ====
  // The JSON representation of an `Any` value uses the regular
  // representation of the deserialized, embedded message, with an
  // additional field `@type` which contains the type URL. Example:
  //
  //     package google.profile;
  //     message Person {
  //       string first_name = 1;
  //       string last_name = 2;
  //     }
  //
  //     {
  //       "@type": "type.googleapis.com/google.profile.Person",
  //       "firstName": <string>,
  //       "lastName": <string>
  //     }
  //
  // If the embedded message type is well-known and has a custom JSON
  // representation, that representation will be embedded adding a field
  // `value` which holds the custom JSON in addition to the `@type`
  // field. Example (for message [google.protobuf.Duration][]):
  //
  //     {
  //       "@type": "type.googleapis.com/google.protobuf.Duration",
  //       "value": "1.212s"
  //     }
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    final any = message as AnyMixin;

    // Handle empty Any case
    if (any.typeUrl.isEmpty && any.value.isEmpty) {
      return <String, dynamic>{};
    }

    final info = typeRegistry.lookup(_typeNameFromUrl(any.typeUrl));
    if (info == null) {
      throw ArgumentError(
        'The type of the Any message (${any.typeUrl}) is not in the given typeRegistry.',
      );
    }
    final unpacked = info.createEmptyInstance!()..mergeFromBuffer(any.value);
    return writeToProto3JsonAny(unpacked.fieldSet, any.typeUrl, typeRegistry);
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is! Map<String, dynamic>) {
      throw context.parseException(
        'Expected Any message encoded as {@type,...},',
        json,
      );
    }
    final object = json;
    final typeUrl = object['@type'];

    if (typeUrl is String) {
      final any = message as AnyMixin;
      final info = typeRegistry.lookup(_typeNameFromUrl(typeUrl));
      if (info == null) {
        throw context.parseException(
          'Decoding Any of type $typeUrl not in TypeRegistry $typeRegistry',
          json,
        );
      }

      final packedMessage = info.createEmptyInstance!();
      mergeFromProto3JsonAny(
        json,
        packedMessage.fieldSet,
        typeRegistry,
        ExtensionRegistry.EMPTY,
        context,
      );
      any.value = packedMessage.writeToBuffer();
      any.typeUrl = typeUrl;
    } else if (typeUrl == null && object.isEmpty) {
      // Handle empty Any case: {} with no @type field
      final any = message as AnyMixin;
      any.typeUrl = '';
      any.value = <int>[];
    } else {
      throw context.parseException('Expected a string', json);
    }
  }
}

String _typeNameFromUrl(String typeUrl) {
  final index = typeUrl.lastIndexOf('/');
  return index < 0 ? '' : typeUrl.substring(index + 1);
}

mixin TimestampMixin {
  static final RegExp finalGroupsOfThreeZeroes = RegExp(r'(?:000)*$');

  Int64 get seconds;
  set seconds(Int64 value);

  int get nanos;
  set nanos(int value);

  /// Converts an instance to [DateTime].
  ///
  /// The result is in UTC time zone and has microsecond precision, as
  /// [DateTime] does not support nanosecond precision.
  ///
  /// Use [toLocal] to convert to local time zone, instead of the default UTC.
  DateTime toDateTime({bool toLocal = false}) =>
      DateTime.fromMicrosecondsSinceEpoch(
        seconds.toInt() * Duration.microsecondsPerSecond + nanos ~/ 1000,
        isUtc: !toLocal,
      );

  /// Updates [target] to be the time at [dateTime].
  ///
  /// Time zone information will not be preserved.
  static void setFromDateTime(TimestampMixin target, DateTime dateTime) {
    final micros = dateTime.microsecondsSinceEpoch;
    target.seconds = Int64((micros / Duration.microsecondsPerSecond).floor());
    target.nanos = (micros % Duration.microsecondsPerSecond).toInt() * 1000;
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  static final DateTime _minTimestamp = DateTime.utc(1);
  static final DateTime _maxTimestamp = DateTime.utc(9999, 13, 31, 23, 59, 59);

  // From google/protobuf/timestamp.proto:
  // # JSON Mapping
  //
  // In JSON format, the Timestamp type is encoded as a string in the
  // [RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format. That is, the
  // format is "{year}-{month}-{day}T{hour}:{min}:{sec}[.{frac_sec}]Z"
  // where {year} is always expressed using four digits while {month}, {day},
  // {hour}, {min}, and {sec} are zero-padded to two digits each. The fractional
  // seconds, which can go up to 9 digits (i.e. up to 1 nanosecond resolution),
  // are optional. The "Z" suffix indicates the timezone ("UTC"); the timezone
  // is required. A proto3 JSON serializer should always use UTC (as indicated by
  // "Z") when printing the Timestamp type and a proto3 JSON parser should be
  // able to accept both UTC and other timezones (as indicated by an offset).
  //
  // For example, "2017-01-15T01:30:15.01Z" encodes 15.01 seconds past
  // 01:30 UTC on January 15, 2017.
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    final timestamp = message as TimestampMixin;
    final dateTime = timestamp.toDateTime();

    if (timestamp.nanos < 0) {
      throw ArgumentError(
        'Timestamp with negative `nanos`: ${timestamp.nanos}',
      );
    }
    if (timestamp.nanos > 999999999) {
      throw ArgumentError(
        'Timestamp with `nanos` out of range: ${timestamp.nanos}',
      );
    }
    if (dateTime.isBefore(_minTimestamp) || dateTime.isAfter(_maxTimestamp)) {
      throw ArgumentError(
        'Timestamp Must be from 0001-01-01T00:00:00Z to '
        '9999-12-31T23:59:59Z inclusive. Was: ${dateTime.toIso8601String()}',
      );
    }

    // Because [DateTime] doesn't have nano-second precision, we cannot use
    // dateTime.toIso8601String().
    final y = '${dateTime.year}'.padLeft(4, '0');
    final m = _twoDigits(dateTime.month);
    final d = _twoDigits(dateTime.day);
    final h = _twoDigits(dateTime.hour);
    final min = _twoDigits(dateTime.minute);
    final sec = _twoDigits(dateTime.second);
    var secFrac = '';
    if (timestamp.nanos > 0) {
      secFrac =
          '.${timestamp.nanos.toString().padLeft(9, '0').replaceFirst(finalGroupsOfThreeZeroes, '')}';
    }
    return '$y-$m-${d}T$h:$min:$sec${secFrac}Z';
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is String) {
      // Strict RFC 3339 validation matching protobuf specification
      // Format: YYYY-MM-DDTHH:MM:SS[.fractional]Z or timezone offset
      final timestampRegex = RegExp(
        r'^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})(?:\.([0-9]{1,9}))?(?:Z|([+-][0-9][0-9]:[0-9][0-9]))$',
      );

      final match = timestampRegex.firstMatch(json);
      if (match == null) {
        throw context.parseException(
          'Timestamp not well formatted. Expected RFC 3339 format',
          json,
        );
      }

      // Extract nanoseconds if present
      var nanos = 0;
      if (match[7] != null) {
        final fracSecs = match[7]!;
        nanos = int.parse(fracSecs.padRight(9, '0'));
      }

      // Reconstruct the date string for parsing
      // Use Z if no timezone offset is present (match[8] == null)
      final dateStr =
          '${match[1]}-${match[2]}-${match[3]}T'
          '${match[4]}:${match[5]}:${match[6]}'
          '${match[8] ?? 'Z'}';

      final dateTime = DateTime.tryParse(dateStr);
      if (dateTime == null) {
        throw context.parseException('Timestamp not well formatted.', json);
      }

      // Validate range: must be from 0001-01-01T00:00:00Z to 9999-12-31T23:59:59Z
      if (dateTime.isBefore(_minTimestamp) || dateTime.isAfter(_maxTimestamp)) {
        throw context.parseException(
          'Timestamp must be from 0001-01-01T00:00:00Z to '
          '9999-12-31T23:59:59Z inclusive',
          json,
        );
      }

      final timestamp = message as TimestampMixin;
      setFromDateTime(timestamp, dateTime);
      timestamp.nanos = nanos;
    } else {
      throw context.parseException(
        'Expected timestamp represented as String',
        json,
      );
    }
  }
}

mixin DurationMixin {
  Int64 get seconds;
  set seconds(Int64 value);

  int get nanos;
  set nanos(int value);

  static final Int64 _durationMaxSeconds = Int64.parseInt('315576000000');
  static final Int64 _durationMinSeconds = Int64.parseInt('-315576000000');

  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    final duration = message as DurationMixin;

    // Validate duration range (±10,000 years)
    if (duration.seconds > _durationMaxSeconds ||
        duration.seconds < _durationMinSeconds) {
      throw ArgumentError(
        'cannot encode message ${message.info_.qualifiedMessageName} to JSON: value out of range',
      );
    }

    if (duration.nanos == 0) {
      return '${duration.seconds}s';
    }

    String nanosStr = duration.nanos.abs().toString().padLeft(9, '0');

    // Preserve fractional seconds in groups of 3, 6, or 9 digits
    // Similar to protobuf-es implementation
    if (nanosStr.substring(3) == '000000') {
      nanosStr = nanosStr.substring(0, 3);
    } else if (nanosStr.substring(6) == '000') {
      nanosStr = nanosStr.substring(0, 6);
    }
    // Otherwise keep all 9 digits

    // Add negative sign if seconds are 0 and nanos are negative
    final text =
        duration.nanos < 0 && duration.seconds == Int64.ZERO
            ? '-${duration.seconds}.${nanosStr}s'
            : '${duration.seconds}.${nanosStr}s';

    return text;
  }

  static final RegExp durationPattern = RegExp(r'(-?\d*)(?:\.(\d*))?s$');

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    final duration = message as DurationMixin;
    if (json is String) {
      final match = durationPattern.matchAsPrefix(json);
      if (match == null) {
        throw context.parseException(
          'Expected a String of the form `<seconds>.<nanos>s`',
          json,
        );
      } else {
        final secondsString = match[1]!;
        // Parse seconds as a regular number first for range validation
        final longSeconds = secondsString == '' ? 0 : num.parse(secondsString);

        // Validate duration range (±10,000 years)
        if (longSeconds > 315576000000 || longSeconds < -315576000000) {
          throw context.parseException('Duration out of valid range', json);
        }

        final seconds = Int64.parseInt(
          secondsString == '' ? '0' : secondsString,
        );
        duration.seconds = seconds;

        if (match[2] != null && match[2]!.isNotEmpty) {
          final nanosStr = match[2]!.padRight(9, '0');
          final nanos = int.parse(nanosStr);
          // Handle negative nanos: if seconds are negative or -0, negate nanos
          duration.nanos =
              (longSeconds < 0 ||
                      (longSeconds == 0 && secondsString.startsWith('-')))
                  ? -nanos
                  : nanos;
        } else {
          duration.nanos = 0;
        }
      }
    } else {
      throw context.parseException(
        'Expected a String of the form `<seconds>.<nanos>s`',
        json,
      );
    }
  }
}

mixin StructMixin implements GeneratedMessage {
  Map<String, ValueMixin> get fields;
  static const _fieldsFieldTagNumber = 1;

  // From google/protobuf/struct.proto:
  // The JSON representation for `Struct` is JSON object.
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    final struct = message as StructMixin;
    return struct.fields.map(
      (key, value) =>
          MapEntry(key, ValueMixin.toProto3JsonHelper(value, typeRegistry)),
    );
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is Map) {
      // Check for emptiness to avoid setting `.fields` if there are no
      // values.
      if (json.isNotEmpty) {
        final fields = (message as StructMixin).fields;
        final valueCreator =
            (message.info_.fieldInfo[_fieldsFieldTagNumber] as MapFieldInfo)
                .valueCreator!;

        json.forEach((key, value) {
          if (key is! String) {
            throw context.parseException('Expected String key', json);
          }
          final v = valueCreator() as ValueMixin;
          context.addMapIndex(key);
          ValueMixin.fromProto3JsonHelper(v, value, typeRegistry, context);
          context.popIndex();
          fields[key] = v;
        });
      }
    } else {
      throw context.parseException(
        'Expected a JSON object literal (map)',
        json,
      );
    }
  }
}

mixin ValueMixin implements GeneratedMessage {
  bool hasNullValue();
  ProtobufEnum get nullValue;
  set nullValue(covariant ProtobufEnum value);

  bool hasNumberValue();
  double get numberValue;
  set numberValue(double v);

  bool hasStringValue();
  String get stringValue;
  set stringValue(String v);

  bool hasBoolValue();
  bool get boolValue;
  set boolValue(bool v);

  bool hasStructValue();
  StructMixin get structValue;
  set structValue(covariant StructMixin v);

  bool hasListValue();
  ListValueMixin get listValue;
  set listValue(covariant ListValueMixin v);

  // From google/protobuf/struct.proto:
  // The JSON representation for `Value` is JSON value
  static Object? toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    final value = message as ValueMixin;
    // This would ideally be a switch, but we cannot import the enum we are
    // switching over.
    if (value.hasNullValue()) {
      return null;
    } else if (value.hasNumberValue()) {
      return value.numberValue;
    } else if (value.hasStringValue()) {
      return value.stringValue;
    } else if (value.hasBoolValue()) {
      return value.boolValue;
    } else if (value.hasStructValue()) {
      return StructMixin.toProto3JsonHelper(value.structValue, typeRegistry);
    } else if (value.hasListValue()) {
      return ListValueMixin.toProto3JsonHelper(value.listValue, typeRegistry);
    } else {
      throw ArgumentError('Serializing google.protobuf.Value with no value');
    }
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object? json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    final value = message as ValueMixin;
    if (json == null) {
      // Rely on the getter retrieving the default to provide an instance.
      value.nullValue = value.nullValue;
    } else if (json is num) {
      value.numberValue = json.toDouble();
    } else if (json is String) {
      value.stringValue = json;
    } else if (json is bool) {
      value.boolValue = json;
    } else if (json is Map) {
      // Clone because the default instance is frozen.
      final structValue = value.structValue.deepCopy();
      StructMixin.fromProto3JsonHelper(
        structValue,
        json,
        typeRegistry,
        context,
      );
      value.structValue = structValue;
    } else if (json is List) {
      // Clone because the default instance is frozen.
      final listValue = value.listValue.deepCopy();
      ListValueMixin.fromProto3JsonHelper(
        listValue,
        json,
        typeRegistry,
        context,
      );
      value.listValue = listValue;
    } else {
      throw context.parseException(
        'Expected a json-value (Map, List, String, number, bool or null)',
        json,
      );
    }
  }
}

mixin ListValueMixin implements GeneratedMessage {
  List<ValueMixin> get values;

  // From google/protobuf/struct.proto:
  // The JSON representation for `ListValue` is JSON array.
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    final list = message as ListValueMixin;
    return list.values
        .map((value) => ValueMixin.toProto3JsonHelper(value, typeRegistry))
        .toList();
  }

  static const _valueFieldTagNumber = 1;

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    final list = message as ListValueMixin;
    if (json is List) {
      final subBuilder = message.info_.subBuilder(_valueFieldTagNumber)!;
      for (var i = 0; i < json.length; i++) {
        final Object element = json[i];
        final v = subBuilder() as ValueMixin;
        context.addListIndex(i);
        ValueMixin.fromProto3JsonHelper(v, element, typeRegistry, context);
        context.popIndex();
        list.values.add(v);
      }
    } else {
      throw context.parseException('Expected a json-List', json);
    }
  }
}

mixin FieldMaskMixin {
  List<String> get paths;

  // From google/protobuf/field_mask.proto:
  // # JSON Encoding of Field Masks
  //
  // In JSON, a field mask is encoded as a single string where paths are
  // separated by a comma. Fields name in each path are converted
  // to/from lower-camel naming conventions.
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    final fieldMask = message as FieldMaskMixin;
    for (final path in fieldMask.paths) {
      if (path.contains(RegExp('[A-Z]|_[^a-z]'))) {
        throw ArgumentError(
          'Bad fieldmask $path. Does not round-trip to json.',
        );
      }
    }
    return fieldMask.paths.map(_toCamelCase).join(',');
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is String) {
      if (json.contains('_')) {
        throw context.parseException(
          'Invalid Character `_` in FieldMask',
          json,
        );
      }
      if (json == '') {
        // The empty string splits to a single value. So this is a special case.
        return;
      }
      (message as FieldMaskMixin).paths.addAll(
        json.split(',').map(_fromCamelCase),
      );
    } else {
      throw context.parseException(
        'Expected String formatted as FieldMask',
        json,
      );
    }
  }

  static String _toCamelCase(String name) {
    return name.replaceAllMapped(
      RegExp('_([a-z])'),
      (Match m) => m.group(1)!.toUpperCase(),
    );
  }

  static String _fromCamelCase(String name) {
    return name.replaceAllMapped(
      RegExp('[A-Z]'),
      (Match m) => '_${m.group(0)!.toLowerCase()}',
    );
  }
}

mixin DoubleValueMixin {
  double get value;
  set value(double value);

  // From google/protobuf/wrappers.proto:
  // The JSON representation for `DoubleValue` is JSON number.
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    return (message as DoubleValueMixin).value;
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is num) {
      (message as DoubleValueMixin).value = json.toDouble();
    } else if (json is String) {
      (message as DoubleValueMixin).value =
          double.tryParse(json) ??
          (throw context.parseException(
            'Expected string to encode a double',
            json,
          ));
    } else {
      throw context.parseException(
        'Expected a double as a String or number',
        json,
      );
    }
  }
}

mixin FloatValueMixin {
  double get value;
  set value(double value);

  // From google/protobuf/wrappers.proto:
  // The JSON representation for `FloatValue` is JSON number.
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    return (message as FloatValueMixin).value;
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is num) {
      (message as FloatValueMixin).value = json.toDouble();
    } else if (json is String) {
      (message as FloatValueMixin).value =
          double.tryParse(json) ??
          (throw context.parseException(
            'Expected a float as a String or number',
            json,
          ));
    } else {
      throw context.parseException(
        'Expected a float as a String or number',
        json,
      );
    }
  }
}

mixin Int64ValueMixin {
  Int64 get value;
  set value(Int64 value);

  // From google/protobuf/wrappers.proto:
  // The JSON representation for `Int64Value` is JSON string.
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    return (message as Int64ValueMixin).value.toString();
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is int) {
      (message as Int64ValueMixin).value = Int64(json);
    } else if (json is String) {
      try {
        (message as Int64ValueMixin).value = Int64.parseInt(json);
      } on FormatException {
        throw context.parseException('Expected string to encode integer', json);
      }
    } else {
      throw context.parseException(
        'Expected an integer encoded as a String or number',
        json,
      );
    }
  }
}

mixin UInt64ValueMixin {
  Int64 get value;
  set value(Int64 value);

  // From google/protobuf/wrappers.proto:
  // The JSON representation for `UInt64Value` is JSON string.
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    return (message as UInt64ValueMixin).value.toStringUnsigned();
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is int) {
      (message as UInt64ValueMixin).value = Int64(json);
    } else if (json is String) {
      try {
        (message as UInt64ValueMixin).value = Int64.parseInt(json);
      } on FormatException {
        throw context.parseException(
          'Expected string to encode unsigned integer',
          json,
        );
      }
    } else {
      throw context.parseException(
        'Expected an unsigned integer as a String or integer',
        json,
      );
    }
  }
}

mixin Int32ValueMixin {
  int get value;
  set value(int value);

  // From google/protobuf/wrappers.proto:
  // The JSON representation for `Int32Value` is JSON number.
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    return (message as Int32ValueMixin).value;
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is int) {
      (message as Int32ValueMixin).value = json;
    } else if (json is String) {
      (message as Int32ValueMixin).value =
          int.tryParse(json) ??
          (throw context.parseException(
            'Expected string to encode integer',
            json,
          ));
    } else {
      throw context.parseException(
        'Expected an integer encoded as a String or number',
        json,
      );
    }
  }
}

mixin UInt32ValueMixin {
  int get value;
  set value(int value);

  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    return (message as UInt32ValueMixin).value;
  }

  // From google/protobuf/wrappers.proto:
  // The JSON representation for `UInt32Value` is JSON number.
  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is int) {
      (message as UInt32ValueMixin).value = json;
    } else if (json is String) {
      (message as UInt32ValueMixin).value =
          int.tryParse(json) ??
          (throw context.parseException(
            'Expected String to encode an integer',
            json,
          ));
    } else {
      throw context.parseException(
        'Expected an unsigned integer as a String or integer',
        json,
      );
    }
  }
}

mixin BoolValueMixin {
  bool get value;
  set value(bool value);

  // From google/protobuf/wrappers.proto:
  // The JSON representation for `BoolValue` is JSON `true` and `false`
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    return (message as BoolValueMixin).value;
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is bool) {
      (message as BoolValueMixin).value = json;
    } else {
      throw context.parseException('Expected a bool', json);
    }
  }
}

mixin StringValueMixin {
  String get value;
  set value(String value);

  // From google/protobuf/wrappers.proto:
  // The JSON representation for `StringValue` is JSON string.
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    return (message as StringValueMixin).value;
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is String) {
      (message as StringValueMixin).value = json;
    } else {
      throw context.parseException('Expected a String', json);
    }
  }
}

mixin BytesValueMixin {
  List<int> get value;
  set value(List<int> value);

  // From google/protobuf/wrappers.proto:
  // The JSON representation for `BytesValue` is JSON string.
  static Object toProto3JsonHelper(
    GeneratedMessage message,
    TypeRegistry typeRegistry,
  ) {
    return base64.encode((message as BytesValueMixin).value);
  }

  static void fromProto3JsonHelper(
    GeneratedMessage message,
    Object json,
    TypeRegistry typeRegistry,
    JsonParsingContext context,
  ) {
    if (json is String) {
      try {
        (message as BytesValueMixin).value = base64.decode(json);
      } on FormatException {
        throw context.parseException(
          'Expected bytes encoded as base64 String',
          json,
        );
      }
    } else {
      throw context.parseException(
        'Expected bytes encoded as base64 String',
        json,
      );
    }
  }
}
