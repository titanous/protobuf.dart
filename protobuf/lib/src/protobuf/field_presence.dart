// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'internal.dart';

/// Field presence semantics for protobuf fields.
///
/// Distinguishes between proto2 explicit presence and proto3 implicit presence.
enum FieldPresence {
  /// Proto3 implicit presence: fields are considered "set" only when they
  /// differ from their default value. Used by default for proto3 singular
  /// fields (except optional fields).
  implicit,

  /// Proto2 explicit presence: fields track whether they have been explicitly
  /// set, regardless of their value. Used by default for proto2 singular fields
  /// and proto3 optional fields.
  explicit,

  /// Legacy required fields from proto2.
  legacyRequired,
}
