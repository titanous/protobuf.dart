// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'internal.dart';

/// An object representing an extension field.
class Extension<T> extends FieldInfo<T> {
  final String extendee;
  
  /// The serialized options associated with this extension from the proto descriptor.
  /// This contains the raw bytes of the FieldOptions message that may contain extension options.
  /// Use a deserializer with the appropriate registry to get the FieldOptions.
  final List<int>? optionsBytes;

  Extension(
    this.extendee,
    String name,
    int tagNumber,
    int fieldType, {
    dynamic defaultOrMaker,
    CreateBuilderFunc? subBuilder,
    ValueOfFunc? valueOf,
    List<ProtobufEnum>? enumValues,
    String? protoName,
    this.optionsBytes,
  }) : super(
         name,
         tagNumber,
         null,
         fieldType,
         defaultOrMaker: defaultOrMaker,
         subBuilder: subBuilder,
         valueOf: valueOf,
         enumValues: enumValues,
         protoName: protoName,
       );

  Extension.repeated(
    this.extendee,
    String name,
    int tagNumber,
    int fieldType, {
    required CheckFunc<T> check,
    CreateBuilderFunc? subBuilder,
    ValueOfFunc? valueOf,
    List<ProtobufEnum>? enumValues,
    String? protoName,
    this.optionsBytes,
  }) : super.repeated(
         name,
         tagNumber,
         null,
         fieldType,
         check,
         subBuilder,
         valueOf: valueOf,
         enumValues: enumValues,
         protoName: protoName,
       );

  @override
  int get hashCode => extendee.hashCode * 31 + tagNumber;

  @override
  bool operator ==(Object other) {
    if (other is! Extension) return false;

    final o = other;
    return extendee == o.extendee && tagNumber == o.tagNumber;
  }
}
