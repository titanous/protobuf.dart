// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'internal.dart';

// Constants for 32-bit integer bounds
const int _int32Min = -2147483648; // -2^31
const int _int32Max = 2147483647; // 2^31 - 1
const int _uint32Max = 0xFFFFFFFF; // 2^32 - 1

// Constants for 32-bit float bounds
const double _float32Max = 3.4028234663852886e38;
const double _float32Min = -3.4028234663852886e38;

/// Validates that a string contains valid UTF-16 sequences.
/// Returns true if valid, false if it contains invalid surrogate sequences.
bool _isValidUtf16(String str) {
  final codeUnits = str.codeUnits;
  for (int i = 0; i < codeUnits.length; i++) {
    final unit = codeUnits[i];

    // Check for high surrogate (0xD800-0xDBFF)
    if (unit >= 0xD800 && unit <= 0xDBFF) {
      // High surrogate must be followed by low surrogate
      if (i + 1 >= codeUnits.length) {
        return false; // Unpaired high surrogate at end
      }
      final nextUnit = codeUnits[i + 1];
      if (nextUnit < 0xDC00 || nextUnit > 0xDFFF) {
        return false; // High surrogate not followed by low surrogate
      }
      i++; // Skip the low surrogate we just validated
    }
    // Check for unpaired low surrogate (0xDC00-0xDFFF)
    else if (unit >= 0xDC00 && unit <= 0xDFFF) {
      return false; // Unpaired low surrogate
    }
  }
  return true;
}

/// Decodes a base64 or base64url encoded string to bytes.
///
/// Supports both standard base64 encoding (using '+' and '/') and
/// base64url encoding (using '-' and '_'). Handles optional padding.
/// Based on the protobuf-es implementation.
Uint8List _decodeBase64OrBase64Url(String base64Str) {
  // Create decode table that supports both base64 and base64url
  final decodeTable = <int, int>{};
  const encodeTable =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  for (int i = 0; i < encodeTable.length; i++) {
    decodeTable[encodeTable.codeUnitAt(i)] = i;
  }

  // Support base64url variants
  decodeTable['-'.codeUnitAt(0)] = encodeTable.indexOf('+'); // 62
  decodeTable['_'.codeUnitAt(0)] = encodeTable.indexOf('/'); // 63

  // Estimate byte size, not accounting for inner padding and whitespace
  int es = (base64Str.length * 3) ~/ 4;
  if (base64Str.length >= 2 && base64Str[base64Str.length - 2] == '=') {
    es -= 2;
  } else if (base64Str.isNotEmpty && base64Str[base64Str.length - 1] == '=') {
    es -= 1;
  }

  final bytes = Uint8List(es);
  int bytePos = 0; // position in byte array
  int groupPos = 0; // position in base64 group
  int b = 0; // current byte
  int p = 0; // previous byte

  for (int i = 0; i < base64Str.length; i++) {
    final decodedByte = decodeTable[base64Str.codeUnitAt(i)];
    if (decodedByte == null) {
      switch (base64Str[i]) {
        case '=':
          groupPos = 0; // reset state when padding found
          continue;
        case '\n':
        case '\r':
        case '\t':
        case ' ':
          continue; // skip white-space
        default:
          throw FormatException('Invalid base64 string');
      }
    }

    b = decodedByte;
    switch (groupPos) {
      case 0:
        p = b;
        groupPos = 1;
        break;
      case 1:
        if (bytePos < bytes.length) {
          bytes[bytePos++] = (p << 2) | ((b & 48) >> 4);
        }
        p = b;
        groupPos = 2;
        break;
      case 2:
        if (bytePos < bytes.length) {
          bytes[bytePos++] = ((p & 15) << 4) | ((b & 60) >> 2);
        }
        p = b;
        groupPos = 3;
        break;
      case 3:
        if (bytePos < bytes.length) {
          bytes[bytePos++] = ((p & 3) << 6) | b;
        }
        groupPos = 0;
        break;
    }
  }

  if (groupPos == 1) {
    throw FormatException('Invalid base64 string');
  }

  return bytes.sublist(0, bytePos);
}

// Public because this is called from the mixins library.
Object writeToProto3JsonAny(
  FieldSet fs,
  String typeUrl,
  TypeRegistry typeRegistry,
) {
  final result = _writeToProto3Json(fs, typeRegistry);
  final wellKnownType = fs._meta._wellKnownType;
  if (wellKnownType != null) {
    switch (wellKnownType) {
      case WellKnownType.any:
      case WellKnownType.timestamp:
      case WellKnownType.duration:
      case WellKnownType.struct:
      case WellKnownType.value:
      case WellKnownType.listValue:
      case WellKnownType.fieldMask:
      case WellKnownType.doubleValue:
      case WellKnownType.floatValue:
      case WellKnownType.int64Value:
      case WellKnownType.uint64Value:
      case WellKnownType.int32Value:
      case WellKnownType.uint32Value:
      case WellKnownType.boolValue:
      case WellKnownType.stringValue:
      case WellKnownType.bytesValue:
        return {'@type': typeUrl, 'value': result};
    }
  }

  (result as Map<String, dynamic>)['@type'] = typeUrl;
  return result;
}

Object? _writeToProto3Json(FieldSet fs, TypeRegistry typeRegistry) {
  String? convertToMapKey(dynamic key, int keyType) {
    final baseType = PbFieldType.baseType(keyType);

    assert(!PbFieldType.isRepeated(keyType));

    switch (baseType) {
      case PbFieldType.BOOL_BIT:
        return key ? 'true' : 'false';
      case PbFieldType.STRING_BIT:
        return key;
      case PbFieldType.UINT64_BIT:
      case PbFieldType.FIXED64_BIT:
        return (key as Int64).toStringUnsigned();
      case PbFieldType.INT32_BIT:
      case PbFieldType.SINT32_BIT:
      case PbFieldType.UINT32_BIT:
      case PbFieldType.FIXED32_BIT:
      case PbFieldType.SFIXED32_BIT:
      case PbFieldType.INT64_BIT:
      case PbFieldType.SINT64_BIT:
      case PbFieldType.SFIXED64_BIT:
        return key.toString();
      default:
        throw StateError('Not a valid key type $keyType');
    }
  }

  Object? valueToProto3Json(dynamic fieldValue, int? fieldType) {
    if (fieldValue == null) return null;

    if (PbFieldType.isGroupOrMessage(fieldType!)) {
      return _writeToProto3Json(
        (fieldValue as GeneratedMessage)._fieldSet,
        typeRegistry,
      );
    } else if (PbFieldType.isEnum(fieldType)) {
      return (fieldValue as ProtobufEnum).name;
    } else {
      final baseType = PbFieldType.baseType(fieldType);
      switch (baseType) {
        case PbFieldType.BOOL_BIT:
          return fieldValue as bool;
        case PbFieldType.STRING_BIT:
          return fieldValue;
        case PbFieldType.INT32_BIT:
        case PbFieldType.SINT32_BIT:
        case PbFieldType.UINT32_BIT:
        case PbFieldType.FIXED32_BIT:
        case PbFieldType.SFIXED32_BIT:
          return fieldValue;
        case PbFieldType.INT64_BIT:
        case PbFieldType.SINT64_BIT:
        case PbFieldType.SFIXED64_BIT:
          return fieldValue.toString();
        case PbFieldType.FIXED64_BIT:
          return (fieldValue as Int64).toStringUnsigned();
        case PbFieldType.FLOAT_BIT:
        case PbFieldType.DOUBLE_BIT:
          final double value = fieldValue;
          if (value.isNaN) {
            return nan;
          }
          if (value.isInfinite) {
            return value.isNegative ? negativeInfinity : infinity;
          }
          if (value.toInt() == fieldValue) {
            return value.toInt();
          }
          return value;
        case PbFieldType.UINT64_BIT:
          return (fieldValue as Int64).toStringUnsigned();
        case PbFieldType.BYTES_BIT:
          return base64Encode(fieldValue);
        default:
          throw StateError(
            'Invariant violation: unexpected value type $fieldType',
          );
      }
    }
  }

  final meta = fs._meta;
  final wellKnownType = meta._wellKnownType;
  if (wellKnownType != null) {
    switch (wellKnownType) {
      case WellKnownType.any:
        return AnyMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.timestamp:
        return TimestampMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.duration:
        return DurationMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.struct:
        return StructMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.value:
        return ValueMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.listValue:
        return ListValueMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.fieldMask:
        return FieldMaskMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.doubleValue:
        return DoubleValueMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.floatValue:
        return FloatValueMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.int64Value:
        return Int64ValueMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.uint64Value:
        return UInt64ValueMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.int32Value:
        return Int32ValueMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.uint32Value:
        return UInt32ValueMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.boolValue:
        return BoolValueMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.stringValue:
        return StringValueMixin.toProto3JsonHelper(fs._message!, typeRegistry);
      case WellKnownType.bytesValue:
        return BytesValueMixin.toProto3JsonHelper(fs._message!, typeRegistry);
    }
    // [WellKnownType] could be used to for messages which have special
    // encodings in other codecs. The set of messages which special encodings in
    // proto3json is handled here, so we intentionally fall through to the
    // default message handling rather than throwing.
  }

  final result = <String, dynamic>{};
  for (final fieldInfo in fs._infosSortedByTag) {
    final value = fs._values[fieldInfo.index!];
    if (value == null) {
      continue; // Field is not set
    }

    // Check if this field is part of a oneof
    final oneofIndex = fs._meta.oneofs[fieldInfo.tagNumber];
    final isInOneof = oneofIndex != null;

    // Skip empty lists only if they are NOT part of a oneof AND are repeated fields
    // For oneof fields or bytes fields, even empty values should be serialized
    if (!isInOneof && value is List && value.isEmpty && 
        PbFieldType.isRepeated(fieldInfo.type)) {
      continue; // Skip empty repeated fields that aren't in a oneof
    }
    dynamic jsonValue;
    if (fieldInfo.isMapField) {
      jsonValue = (value as PbMap).map((key, entryValue) {
        final mapEntryInfo = fieldInfo as MapFieldInfo;
        return MapEntry(
          convertToMapKey(key, mapEntryInfo.keyFieldType),
          valueToProto3Json(entryValue, mapEntryInfo.valueFieldType),
        );
      });
    } else if (fieldInfo.isRepeated) {
      jsonValue =
          (value as PbList)
              .map((element) => valueToProto3Json(element, fieldInfo.type))
              .toList();
    } else {
      jsonValue = valueToProto3Json(value, fieldInfo.type);
    }
    result[fieldInfo.name] = jsonValue;
  }
  // Extensions and unknown fields are not encoded by proto3 JSON.
  return result;
}

int _tryParse32BitProto3(String s, JsonParsingContext context) {
  // Handle empty string or leading/trailing whitespace
  if (s.isEmpty || s.trim().length != s.length) {
    throw context.parseException('expected integer', s);
  }

  // Check if string contains decimal point or exponential notation
  if (s.contains('.') || s.contains('e') || s.contains('E')) {
    // Parse as double to handle exponential notation (e.g., "1e2", "1.0")
    final num = double.tryParse(s);
    // Check if it's a valid integer (using truncateToDouble to match JS Number.isInteger)
    if (num == null || !num.isFinite || num != num.truncateToDouble()) {
      throw context.parseException('expected integer', s);
    }

    // Check if the value fits in int32 range before converting
    if (num < _int32Min || num > _int32Max) {
      throw context.parseException('expected 32 bit integer', s);
    }

    // Convert to int
    return num.toInt();
  }

  // Regular integer parsing for normal cases
  final intValue = int.tryParse(s);
  if (intValue != null) {
    return intValue;
  }

  throw context.parseException('expected integer', s);
}

int _check32BitSignedProto3(int n, JsonParsingContext context) {
  if (n < _int32Min || n > _int32Max) {
    throw context.parseException('expected 32 bit signed integer', n);
  }
  return n;
}

int _check32BitUnsignedProto3(int n, JsonParsingContext context) {
  if (n < 0 || n > _uint32Max) {
    throw context.parseException('expected 32 bit unsigned integer', n);
  }
  return n;
}

Int64 _tryParse64BitProto3(Object? json, String s, JsonParsingContext context) {
  // Handle empty string or leading/trailing whitespace
  if (s.isEmpty || s.trim().length != s.length) {
    throw context.parseException('expected integer', json);
  }

  // Check if string contains decimal point or exponential notation
  if (s.contains('.') || s.contains('e') || s.contains('E')) {
    // Parse as double to handle exponential notation (e.g., "1e2", "1.0")
    final num = double.tryParse(s);
    // Check if it's a valid integer
    if (num == null || !num.isFinite || num != num.truncateToDouble()) {
      throw context.parseException('expected integer', json);
    }

    // For 64-bit integers, we need to be careful about precision loss
    // JavaScript's Number type can only safely represent integers up to 2^53
    // So for larger values, we should reject the float representation
    if (num.abs() > 9007199254740992) {
      // 2^53
      throw context.parseException(
        'integer value too large for safe conversion from float',
        json,
      );
    }

    return Int64(num.toInt());
  }

  // Regular Int64 parsing for normal cases
  try {
    return Int64.parseInt(s);
  } on FormatException {
    throw context.parseException('expected integer', json);
  }
}

/// TODO(paulberry): find a better home for this?
extension _FindFirst<E> on Iterable<E> {
  E? findFirst(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// Public because this is called from the mixins library.
void mergeFromProto3JsonAny(
  Object? json,
  FieldSet fieldSet,
  TypeRegistry typeRegistry,
  JsonParsingContext context,
) {
  if (json is! Map<String, dynamic>) {
    throw context.parseException('Expected JSON object', json);
  }

  final wellKnownType = fieldSet._meta._wellKnownType;
  if (wellKnownType != null) {
    switch (wellKnownType) {
      case WellKnownType.any:
      case WellKnownType.timestamp:
      case WellKnownType.duration:
      case WellKnownType.struct:
      case WellKnownType.value:
      case WellKnownType.listValue:
      case WellKnownType.fieldMask:
      case WellKnownType.doubleValue:
      case WellKnownType.floatValue:
      case WellKnownType.int64Value:
      case WellKnownType.uint64Value:
      case WellKnownType.int32Value:
      case WellKnownType.uint32Value:
      case WellKnownType.boolValue:
      case WellKnownType.stringValue:
      case WellKnownType.bytesValue:
        final value = json['value'];
        return _mergeFromProto3JsonWithContext(
          value,
          fieldSet,
          typeRegistry,
          context,
        );
    }
  }

  // TODO(sigurdm): avoid cloning [object] here.
  final withoutType = Map<String, dynamic>.from(json)..remove('@type');
  return _mergeFromProto3JsonWithContext(
    withoutType,
    fieldSet,
    typeRegistry,
    context,
  );
}

/// Merge a JSON object representing a message in proto3 JSON format ([json])
/// to [fieldSet].
void _mergeFromProto3Json(
  Object? json,
  FieldSet fieldSet,
  TypeRegistry typeRegistry,
  bool ignoreUnknownFields,
  bool supportNamesWithUnderscores,
  bool permissiveEnums,
  bool allowUnknownEnumIntegers,
) {
  final context = JsonParsingContext(
    ignoreUnknownFields,
    supportNamesWithUnderscores,
    permissiveEnums,
    allowUnknownEnumIntegers,
  );
  return _mergeFromProto3JsonWithContext(json, fieldSet, typeRegistry, context);
}

/// Merge a JSON object representing a message in proto3 JSON format ([json])
/// to [fieldSet].
void _mergeFromProto3JsonWithContext(
  Object? json,
  FieldSet fieldSet,
  TypeRegistry typeRegistry,
  JsonParsingContext context,
) {
  // Reject top-level null for proto3 JSON
  if (json == null) {
    throw context.parseException('Expected JSON object, got null', json);
  }

  fieldSet._ensureWritable();

  void recursionHelper(Object? json, FieldSet fieldSet) {
    Object? convertProto3JsonValue(Object value, FieldInfo fieldInfo) {
      final fieldType = fieldInfo.type;
      switch (PbFieldType.baseType(fieldType)) {
        case PbFieldType.BOOL_BIT:
          if (value is bool) {
            return value;
          }
          throw context.parseException('Expected bool value', json);
        case PbFieldType.BYTES_BIT:
          if (value is String) {
            Uint8List result;
            try {
              result = _decodeBase64OrBase64Url(value);
            } on FormatException {
              throw context.parseException(
                'Expected bytes encoded as base64 String',
                json,
              );
            }
            return result;
          }
          throw context.parseException(
            'Expected bytes encoded as base64 String',
            value,
          );
        case PbFieldType.STRING_BIT:
          if (value is String) {
            if (!_isValidUtf16(value)) {
              throw context.parseException('Invalid UTF-16 string', value);
            }
            return value;
          }
          throw context.parseException('Expected String value', value);
        case PbFieldType.FLOAT_BIT:
        case PbFieldType.DOUBLE_BIT:
          final isFloat = fieldType == PbFieldType.FLOAT_BIT;
          final typeName = isFloat ? 'float' : 'double';

          if (value is double) {
            // Reject numeric NaN and Infinity - they must be encoded as strings
            if (value.isNaN || !value.isFinite) {
              throw context.parseException(
                'NaN and Infinity must be encoded as strings',
                value,
              );
            }
            // Check float32 range for float fields
            if (isFloat && (value > _float32Max || value < _float32Min)) {
              throw context.parseException(
                '$typeName field value out of range',
                value,
              );
            }
            return value;
          } else if (value is num) {
            final doubleValue = value.toDouble();
            if (doubleValue.isNaN || !doubleValue.isFinite) {
              throw context.parseException(
                'NaN and Infinity must be encoded as strings',
                value,
              );
            }
            // Check float32 range for float fields
            if (isFloat &&
                (doubleValue > _float32Max || doubleValue < _float32Min)) {
              throw context.parseException(
                '$typeName field value out of range',
                value,
              );
            }
            return doubleValue;
          } else if (value is String) {
            // Handle special string values
            if (value == 'NaN') return double.nan;
            if (value == 'Infinity') return double.infinity;
            if (value == '-Infinity') return double.negativeInfinity;

            final parsed = double.tryParse(value);
            if (parsed == null) {
              throw context.parseException(
                'Expected String to encode a $typeName',
                value,
              );
            }
            // Check for overflow - if parsing resulted in infinity but input wasn't "Infinity"
            if (!parsed.isFinite &&
                value != 'Infinity' &&
                value != '-Infinity') {
              throw context.parseException(
                '$typeName field value out of range',
                value,
              );
            }
            // Check float32 range for float fields with finite values
            if (isFloat &&
                parsed.isFinite &&
                (parsed > _float32Max || parsed < _float32Min)) {
              throw context.parseException(
                '$typeName field value out of range',
                value,
              );
            }
            return parsed;
          }
          throw context.parseException(
            'Expected a $typeName represented as a String or number',
            value,
          );
        case PbFieldType.ENUM_BIT:
          if (value is String) {
            // First try valueByName if available (for handling aliases)
            if (fieldInfo.valueByName != null) {
              final result = fieldInfo.valueByName!(value);
              if (result != null) return result;
              if (context.ignoreUnknownFields) return null;
              throw context.parseException('Unknown enum value', value);
            }

            // Fall back to linear search through enumValues
            // TODO(sigurdm): Do we want to avoid linear search here? Measure...
            final result =
                context.permissiveEnums
                    ? fieldInfo.enumValues!.findFirst(
                      (e) => permissiveCompare(e.name, value),
                    )
                    : fieldInfo.enumValues!.findFirst((e) => e.name == value);
            if ((result != null) || context.ignoreUnknownFields) return result;
            throw context.parseException('Unknown enum value', value);
          } else if (value is int) {
            final knownEnumValue = fieldInfo.valueOf!(value);
            if (knownEnumValue != null) {
              return knownEnumValue;
            } else {
              // Handle unknown enum integer values for proto3 compatibility
              if (context.allowUnknownEnumIntegers || context.permissiveEnums) {
                // Store unknown enum values as _UnknownEnumValue to preserve them
                // while allowing type-safe access via generated getters
                return _UnknownEnumValue(value);
              } else if (context.ignoreUnknownFields) {
                return null;
              } else {
                throw context.parseException('Unknown enum value', value);
              }
            }
          }
          throw context.parseException(
            'Expected enum as a string or integer',
            value,
          );
        case PbFieldType.UINT32_BIT:
        case PbFieldType.FIXED32_BIT:
          int result;
          if (value is int) {
            result = value;
          } else if (value is double) {
            // Handle double values that represent integers
            if (value.isFinite && value == value.truncateToDouble()) {
              result = value.toInt();
            } else {
              throw context.parseException('Expected integer value', value);
            }
          } else if (value is String) {
            result = _tryParse32BitProto3(value, context);
          } else {
            throw context.parseException(
              'Expected int or stringified int',
              value,
            );
          }
          return _check32BitUnsignedProto3(result, context);
        case PbFieldType.INT32_BIT:
        case PbFieldType.SINT32_BIT:
        case PbFieldType.SFIXED32_BIT:
          int result;
          if (value is int) {
            result = value;
          } else if (value is double) {
            // Handle double values that represent integers
            if (value.isFinite && value == value.truncateToDouble()) {
              result = value.toInt();
            } else {
              throw context.parseException('Expected integer value', value);
            }
          } else if (value is String) {
            result = _tryParse32BitProto3(value, context);
          } else {
            throw context.parseException(
              'Expected int or stringified int',
              value,
            );
          }
          _check32BitSignedProto3(result, context);
          return result;
        case PbFieldType.UINT64_BIT:
          Int64 result;
          if (value is int) {
            if (value < 0) {
              throw context.parseException('Expected unsigned integer', value);
            }
            result = Int64(value);
          } else if (value is double) {
            // Handle double values that represent integers
            if (value.isFinite && value == value.truncateToDouble()) {
              if (value < 0) {
                throw context.parseException(
                  'Expected unsigned integer',
                  value,
                );
              }
              // Check if value exceeds UINT64_MAX (2^64 - 1)
              // Note: Due to double precision, we check against 2^64
              if (value >= 18446744073709551616.0) {
                throw context.parseException(
                  'uint64 field value out of range',
                  value,
                );
              }
              // For large uint64 values, convert to string first to avoid overflow
              // when calling toInt() on doubles larger than max signed int64
              result = Int64.parseInt(value.toStringAsFixed(0));
            } else {
              throw context.parseException('Expected integer value', value);
            }
          } else if (value is String) {
            // Check for negative values
            if (value.startsWith('-')) {
              throw context.parseException('Expected unsigned integer', value);
            }
            result = _tryParse64BitProto3(json, value, context);
            // Check for overflow (values > UINT64_MAX)
            // When parsing large unsigned values, Int64.parseInt may wrap around
            // We need to verify the parsed value matches the original string
            if (result.toStringUnsigned() != value) {
              throw context.parseException(
                'uint64 field value out of range',
                value,
              );
            }
          } else {
            throw context.parseException(
              'Expected int or stringified int',
              value,
            );
          }
          return result;
        case PbFieldType.INT64_BIT:
        case PbFieldType.SINT64_BIT:
        case PbFieldType.FIXED64_BIT:
        case PbFieldType.SFIXED64_BIT:
          if (value is int) return Int64(value);
          if (value is double) {
            // Handle double values that represent integers
            if (value.isFinite && value == value.truncateToDouble()) {
              return Int64(value.toInt());
            } else {
              throw context.parseException('Expected integer value', value);
            }
          }
          if (value is String) {
            Int64 result;
            try {
              result = Int64.parseInt(value);
              // Check for overflow by comparing string representation
              if (result.toString() != value) {
                throw context.parseException(
                  'int64 field value out of range',
                  value,
                );
              }
            } on FormatException {
              throw context.parseException(
                'Expected int or stringified int',
                value,
              );
            }
            return result;
          }
          throw context.parseException(
            'Expected int or stringified int',
            value,
          );
        case PbFieldType.GROUP_BIT:
        case PbFieldType.MESSAGE_BIT:
          final subMessage = fieldInfo.subBuilder!();
          recursionHelper(value, subMessage._fieldSet);
          return subMessage;
        default:
          throw StateError('Unknown type $fieldType');
      }
    }

    Object decodeMapKey(String key, int fieldType) {
      switch (PbFieldType.baseType(fieldType)) {
        case PbFieldType.BOOL_BIT:
          switch (key) {
            case 'true':
              return true;
            case 'false':
              return false;
            default:
              throw context.parseException(
                'Wrong boolean key, should be one of ("true", "false")',
                key,
              );
          }
        case PbFieldType.STRING_BIT:
          return key;
        case PbFieldType.UINT64_BIT:
          // TODO(sigurdm): We do not throw on negative values here.
          // That would probably require going via bignum.
          return _tryParse64BitProto3(json, key, context);
        case PbFieldType.INT64_BIT:
        case PbFieldType.SINT64_BIT:
        case PbFieldType.SFIXED64_BIT:
        case PbFieldType.FIXED64_BIT:
          return _tryParse64BitProto3(json, key, context);
        case PbFieldType.INT32_BIT:
        case PbFieldType.SINT32_BIT:
        case PbFieldType.FIXED32_BIT:
        case PbFieldType.SFIXED32_BIT:
          return _check32BitSignedProto3(
            _tryParse32BitProto3(key, context),
            context,
          );
        case PbFieldType.UINT32_BIT:
          return _check32BitUnsignedProto3(
            _tryParse32BitProto3(key, context),
            context,
          );
        default:
          throw StateError('Not a valid key type $fieldType');
      }
    }

    final meta = fieldSet._meta;
    final wellKnownType = meta._wellKnownType;

    // Special handling for google.protobuf.Value which accepts null
    if (wellKnownType == WellKnownType.value) {
      ValueMixin.fromProto3JsonHelper(
        fieldSet._message!,
        json,
        typeRegistry,
        context,
      );
      return;
    }

    if (json == null) {
      // `null` represents the default value. Do nothing more.
      return;
    }

    if (wellKnownType != null) {
      switch (wellKnownType) {
        case WellKnownType.any:
          AnyMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.timestamp:
          TimestampMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.duration:
          DurationMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.struct:
          StructMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.value:
          // Already handled above for null case
          ValueMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.listValue:
          ListValueMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.fieldMask:
          FieldMaskMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.doubleValue:
          DoubleValueMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.floatValue:
          FloatValueMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.int64Value:
          Int64ValueMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.uint64Value:
          UInt64ValueMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.int32Value:
          Int32ValueMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.uint32Value:
          UInt32ValueMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.boolValue:
          BoolValueMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.stringValue:
          StringValueMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
        case WellKnownType.bytesValue:
          BytesValueMixin.fromProto3JsonHelper(
            fieldSet._message!,
            json,
            typeRegistry,
            context,
          );
          return;
      }

      // [WellKnownType] could be used to for messages which have special
      // encodings in other codecs. The set of messages which special encodings
      // in proto3json is handled here, so we intentionally fall through to the
      // default message handling rather than throwing.
    }

    if (json is Map) {
      final byName = meta.byName;
      // Track which oneof groups have been set to detect duplicates
      final Map<int, String> seenOneofs = {};

      json.forEach((key, Object? value) {
        if (key is! String) {
          throw context.parseException('Key was not a String', key);
        }
        context.addMapIndex(key);

        var fieldInfo = byName[key];
        if (fieldInfo == null && context.supportNamesWithUnderscores) {
          // We don't optimize for field names with underscores, instead do a
          // linear search for the index.
          fieldInfo = byName.values.findFirst(
            (FieldInfo info) => info.protoName == key,
          );
        }
        if (fieldInfo == null) {
          if (context.ignoreUnknownFields) {
            return;
          } else {
            throw context.parseException('Unknown field name \'$key\'', key);
          }
        }

        // Handle null values - skip them unless the field is google.protobuf.Value
        if (value == null) {
          // Check if this field is a google.protobuf.Value message type
          if (PbFieldType.isGroupOrMessage(fieldInfo.type) &&
              fieldInfo.subBuilder != null) {
            final subMessage = fieldInfo.subBuilder!();
            if (subMessage._fieldSet._meta._wellKnownType ==
                WellKnownType.value) {
              // This is a google.protobuf.Value field, pass null to its handler
              recursionHelper(null, subMessage._fieldSet);
              fieldSet._setNonExtensionFieldUnchecked(
                meta,
                fieldInfo,
                subMessage,
              );
              context.popIndex();
              return;
            }
          }
          // For non-Value fields, skip null values (don't track in oneofs)
          context.popIndex();
          return;
        }

        // Check for duplicate oneof fields (only for non-null values)
        final oneofIndex = meta.oneofs[fieldInfo.tagNumber];
        if (oneofIndex != null) {
          final previousField = seenOneofs[oneofIndex];
          if (previousField != null) {
            throw context.parseException(
              'Cannot set multiple fields in the same oneof. '
              'Field "$key" is already set by field "$previousField".',
              key,
            );
          }
          seenOneofs[oneofIndex] = key;
        }

        if (PbFieldType.isMapField(fieldInfo.type)) {
          if (value is Map) {
            final mapFieldInfo = fieldInfo as MapFieldInfo<dynamic, dynamic>;
            final Map fieldValues = fieldSet._ensureMapField(meta, fieldInfo);
            value.forEach((subKey, subValue) {
              if (subKey is! String) {
                throw context.parseException('Expected a String key', subKey);
              }
              context.addMapIndex(subKey);
              final convertedValue = convertProto3JsonValue(
                subValue,
                mapFieldInfo.valueFieldInfo,
              );
              // Skip null values (e.g., unknown enum strings when ignoreUnknownFields is true)
              if (convertedValue != null) {
                fieldValues[decodeMapKey(subKey, mapFieldInfo.keyFieldType)] =
                    convertedValue;
              }
              context.popIndex();
            });
          } else {
            throw context.parseException('Expected a map', value);
          }
        } else if (PbFieldType.isRepeated(fieldInfo.type)) {
          if (value is List) {
            final values = fieldSet._ensureRepeatedField(meta, fieldInfo);
            for (var i = 0; i < value.length; i++) {
              final entry = value[i];
              context.addListIndex(i);
              final convertedValue = convertProto3JsonValue(entry, fieldInfo);
              // Skip null values (e.g., unknown enum strings when ignoreUnknownFields is true)
              if (convertedValue != null) {
                values.add(convertedValue);
              }
              context.popIndex();
            }
          } else {
            throw context.parseException('Expected a list', value);
          }
        } else if (PbFieldType.isGroupOrMessage(fieldInfo.type)) {
          // TODO(sigurdm) consider a cleaner separation between parsing and
          // merging.
          final parsedSubMessage =
              convertProto3JsonValue(value, fieldInfo) as GeneratedMessage;
          final GeneratedMessage? original = fieldSet._values[fieldInfo.index!];
          if (original == null) {
            fieldSet._setNonExtensionFieldUnchecked(
              meta,
              fieldInfo,
              parsedSubMessage,
            );
          } else {
            original.mergeFromMessage(parsedSubMessage);
          }
        } else {
          fieldSet._setFieldUnchecked(
            meta,
            fieldInfo,
            convertProto3JsonValue(value, fieldInfo),
          );
        }
        context.popIndex();
      });
    } else {
      throw context.parseException('Expected JSON object', json);
    }
  }

  recursionHelper(json, fieldSet);
}

/// A synthetic ProtobufEnum that preserves unknown integer enum values.
/// This allows proto3 JSON parsing to handle unknown enum integers gracefully,
/// matching the behavior of other protobuf implementations like protobuf-es.
class _UnknownEnumValue extends ProtobufEnum {
  _UnknownEnumValue(int value) : super(value, 'UNKNOWN_ENUM_VALUE_$value');

  @override
  String toString() => 'UNKNOWN_ENUM_VALUE_$value';

  @override
  bool operator ==(Object other) {
    return other is _UnknownEnumValue && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
