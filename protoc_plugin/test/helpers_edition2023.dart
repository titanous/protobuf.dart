// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:fixnum/fixnum.dart';

import 'gen/edition2023.pb.dart' as edition2023;
import 'gen/edition2023-proto2.pb.dart' as edition2023_proto2;
import 'gen/edition2023-proto3.pb.dart' as edition2023_proto3;
import 'gen/google/protobuf/wrappers.pb.dart' as wrappers;

List<String> fillEdition2023MessageNames() {
  return const [
    // explicit
    'explicitStringField',
    'explicitInt64Field',
    'explicitInt64JsNumberField',
    'explicitInt64JsStringField',
    'explicitEnumOpenField',
    'explicitEnumClosedField',
    'explicitMessageField',
    'explicitMessageDelimitedField',
    'explicitWrappedUint32Field',
    // implicit
    'implicitStringField',
    'implicitInt64Field',
    'implicitInt64JsNumberField',
    'implicitInt64JsStringField',
    'implicitEnumOpenField',
    // required
    'requiredStringField',
    'requiredBytesField',
    'requiredInt32Field',
    'requiredInt64Field',
    'requiredInt64JsNumberField',
    'requiredInt64JsStringField',
    'requiredFloatField',
    'requiredBoolField',
    'requiredEnumOpenField',
    'requiredEnumClosedField',
    'requiredMessageField',
    'requiredMessageDelimitedField',
    'requiredWrappedUint32Field',
    // required with default
    'requiredDefaultStringField',
    'requiredDefaultBytesField',
    'requiredDefaultInt32Field',
    'requiredDefaultInt64Field',
    'requiredDefaultInt64JsNumberField',
    'requiredDefaultInt64JsStringField',
    'requiredDefaultFloatField',
    'requiredDefaultBoolField',
    'requiredDefaultEnumOpenField',
    'requiredDefaultEnumClosedField',
    // repeated
    'repeatedStringField',
    // map
    'mapStringStringField',
    // oneof
    'oneofBoolField',
  ];
}

edition2023.Edition2023Message fillEdition2023Message(
  edition2023.Edition2023Message msg,
) {
  // explicit
  msg.explicitStringField = '';
  msg.explicitInt64Field = Int64.ZERO;
  msg.explicitInt64JsNumberField = Int64.ZERO;
  msg.explicitInt64JsStringField = Int64.ZERO;
  msg.explicitEnumOpenField =
      edition2023.Edition2023EnumOpen.EDITION2023_ENUM_OPEN_A;
  msg.explicitEnumClosedField =
      edition2023.Edition2023EnumClosed.EDITION2023_ENUM_CLOSED_A;
  msg.explicitMessageField = fillEdition2023Required(
    edition2023.Edition2023Message(),
  );
  msg.explicitMessageDelimitedField = fillEdition2023Required(
    edition2023.Edition2023Message(),
  );
  msg.explicitWrappedUint32Field = wrappers.UInt32Value()..value = 66;

  // implicit
  msg.implicitStringField = 'non-zero';
  msg.implicitInt64Field = Int64(123);
  msg.implicitInt64JsNumberField = Int64(123);
  msg.implicitInt64JsStringField = Int64(456);
  msg.implicitEnumOpenField =
      edition2023.Edition2023EnumOpen.EDITION2023_ENUM_OPEN_A;

  // required
  msg.requiredStringField = 'non-zero';
  msg.requiredBytesField = [];
  msg.requiredInt32Field = 0;
  msg.requiredInt64Field = Int64(123);
  msg.requiredInt64JsNumberField = Int64(123);
  msg.requiredInt64JsStringField = Int64(456);
  msg.requiredFloatField = 0;
  msg.requiredBoolField = false;
  msg.requiredEnumOpenField =
      edition2023.Edition2023EnumOpen.EDITION2023_ENUM_OPEN_A;
  msg.requiredEnumClosedField =
      edition2023.Edition2023EnumClosed.EDITION2023_ENUM_CLOSED_A;
  msg.requiredMessageField = edition2023.Edition2023Message_Child();
  msg.requiredMessageDelimitedField = edition2023.Edition2023Message_Child();
  msg.requiredWrappedUint32Field = wrappers.UInt32Value()..value = 66;

  // required with default
  msg.requiredDefaultStringField = 'non-zero';
  msg.requiredDefaultBytesField = [];
  msg.requiredDefaultInt32Field = 0;
  msg.requiredDefaultInt64Field = Int64(123);
  msg.requiredDefaultInt64JsNumberField = Int64(123);
  msg.requiredDefaultInt64JsStringField = Int64(456);
  msg.requiredDefaultFloatField = 0;
  msg.requiredDefaultBoolField = false;
  msg.requiredDefaultEnumOpenField =
      edition2023.Edition2023EnumOpen.EDITION2023_ENUM_OPEN_A;
  msg.requiredDefaultEnumClosedField =
      edition2023.Edition2023EnumClosed.EDITION2023_ENUM_CLOSED_A;

  // repeated
  msg.repeatedStringField.add('abc');

  // map
  msg.mapStringStringField['foo'] = 'bar';

  // oneof
  msg.oneofBoolField = false;

  return msg;
}

edition2023.Edition2023Message fillEdition2023Required(
  edition2023.Edition2023Message msg,
) {
  // required
  msg.requiredStringField = 'non-zero';
  msg.requiredBytesField = [];
  msg.requiredInt32Field = 0;
  msg.requiredInt64Field = Int64(123);
  msg.requiredInt64JsNumberField = Int64(123);
  msg.requiredInt64JsStringField = Int64(456);
  msg.requiredFloatField = 0;
  msg.requiredBoolField = false;
  msg.requiredEnumOpenField =
      edition2023.Edition2023EnumOpen.EDITION2023_ENUM_OPEN_A;
  msg.requiredEnumClosedField =
      edition2023.Edition2023EnumClosed.EDITION2023_ENUM_CLOSED_A;
  msg.requiredMessageField = edition2023.Edition2023Message_Child();
  msg.requiredMessageDelimitedField = edition2023.Edition2023Message_Child();
  msg.requiredWrappedUint32Field = wrappers.UInt32Value()..value = 66;

  // required with default
  msg.requiredDefaultStringField = 'non-zero';
  msg.requiredDefaultBytesField = [];
  msg.requiredDefaultInt32Field = 0;
  msg.requiredDefaultInt64Field = Int64(123);
  msg.requiredDefaultInt64JsNumberField = Int64(123);
  msg.requiredDefaultInt64JsStringField = Int64(456);
  msg.requiredDefaultFloatField = 0;
  msg.requiredDefaultBoolField = false;
  msg.requiredDefaultEnumOpenField =
      edition2023.Edition2023EnumOpen.EDITION2023_ENUM_OPEN_A;
  msg.requiredDefaultEnumClosedField =
      edition2023.Edition2023EnumClosed.EDITION2023_ENUM_CLOSED_A;

  return msg;
}

edition2023.Edition2023FromProto2Message fillEditionFromProto2Message(
  edition2023.Edition2023FromProto2Message msg,
) {
  msg.optionalBoolField = false;
  msg.optionalClosedEnumField =
      edition2023.Edition2023EnumClosed.EDITION2023_ENUM_CLOSED_A;
  msg.optionalStringFieldWithDefault = '';
  msg.optionalgroup =
      edition2023.Edition2023FromProto2Message_OptionalGroup()
        ..int32Field = 123;
  msg.requiredBoolField = false;
  msg.requiredClosedEnumField =
      edition2023.Edition2023EnumClosed.EDITION2023_ENUM_CLOSED_A;
  msg.requiredStringFieldWithDefault = '';
  msg.requiredgroup =
      edition2023.Edition2023FromProto2Message_RequiredGroup()
        ..int32Field = 123;
  msg.packedDoubleField.addAll([1, 2, 3]);
  msg.unpackedDoubleField.addAll([4, 5, 6]);
  return msg;
}

edition2023_proto2.Proto2MessageForEdition2023 fillProto2Message(
  edition2023_proto2.Proto2MessageForEdition2023 msg,
) {
  msg.optionalBoolField = false;
  msg.optionalClosedEnumField =
      edition2023_proto2.Proto2EnumForEdition2023.PROTO2_ENUM_FOR_EDITION2023_A;
  msg.optionalStringFieldWithDefault = '';
  msg.optionalGroup =
      edition2023_proto2.Proto2MessageForEdition2023_OptionalGroup()
        ..int32Field = 123;
  msg.requiredBoolField = false;
  msg.requiredClosedEnumField =
      edition2023_proto2.Proto2EnumForEdition2023.PROTO2_ENUM_FOR_EDITION2023_A;
  msg.requiredStringFieldWithDefault = '';
  msg.requiredGroup =
      edition2023_proto2.Proto2MessageForEdition2023_RequiredGroup()
        ..int32Field = 123;
  msg.packedDoubleField.addAll([1, 2, 3]);
  msg.unpackedDoubleField.addAll([4, 5, 6]);
  return msg;
}

edition2023.Edition2023FromProto3Message fillEditionFromProto3Message(
  edition2023.Edition2023FromProto3Message msg,
) {
  msg.implicitBoolField = true;
  msg.implicitOpenEnumField =
      edition2023.Edition2023EnumOpen.EDITION2023_ENUM_OPEN_A;
  msg.explicitBoolField = false;
  msg.explicitOpenEnumField =
      edition2023.Edition2023EnumOpen.EDITION2023_ENUM_OPEN_UNSPECIFIED;
  msg.packedDoubleField.addAll([1, 2, 3]);
  msg.unpackedDoubleField.addAll([4, 5, 6]);
  return msg;
}

edition2023_proto3.Proto3MessageForEdition2023 fillProto3Message(
  edition2023_proto3.Proto3MessageForEdition2023 msg,
) {
  msg.implicitBoolField = true;
  msg.implicitOpenEnumField =
      edition2023_proto3.Proto3EnumForEdition2023.PROTO3_ENUM_FOR_EDITION2023_A;
  msg.explicitBoolField = false;
  msg.explicitOpenEnumField =
      edition2023_proto3
          .Proto3EnumForEdition2023
          .PROTO3_ENUM_FOR_EDITION2023_UNSPECIFIED;
  msg.packedDoubleField.addAll([1, 2, 3]);
  msg.unpackedDoubleField.addAll([4, 5, 6]);
  return msg;
}
