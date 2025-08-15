// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'internal.dart';

/// Type definition for a function that deserializes FieldOptions.
typedef FieldOptionsDeserializer =
    GeneratedMessage Function(List<int> bytes, ExtensionRegistry registry);

/// Get the options for an extension, deserializing them if needed.
///
/// The deserializer should be a function that creates a FieldOptions message
/// from the bytes. Typically this would be FieldOptions.fromBuffer.
///
/// Returns null if the extension has no options.
GeneratedMessage? getExtensionOptions(
  Extension ext,
  FieldOptionsDeserializer deserializer,
  ExtensionRegistry registry,
) {
  if (ext.optionsBytes == null || ext.optionsBytes!.isEmpty) {
    return null;
  }
  try {
    return deserializer(ext.optionsBytes!, registry);
  } catch (e) {
    // Failed to deserialize options
    return null;
  }
}

/// Check if an extension has a specific option set.
///
/// Options are extensions to the `google.protobuf.*Options` messages defined in
/// google/protobuf/descriptor.proto.
bool hasOption<T>(
  Extension ext,
  Extension<T> option,
  FieldOptionsDeserializer deserializer,
  ExtensionRegistry registry,
) {
  final options = getExtensionOptions(ext, deserializer, registry);
  if (options == null) {
    return false;
  }
  return options.hasExtension(option);
}

/// Retrieve an option value from an extension.
///
/// Options are extensions to the `google.protobuf.*Options` messages defined in
/// google/protobuf/descriptor.proto.
T? getOption<T>(
  Extension ext,
  Extension<T> option,
  FieldOptionsDeserializer deserializer,
  ExtensionRegistry registry,
) {
  final options = getExtensionOptions(ext, deserializer, registry);
  if (options == null) {
    return null;
  }
  if (!options.hasExtension(option)) {
    return null;
  }
  return options.getExtension(option);
}

/// Retrieve an option value from an extension, with a default value.
///
/// Similar to getOption, but returns a default value if the option is not set.
T getOptionWithDefault<T>(
  Extension ext,
  Extension<T> option,
  T defaultValue,
  FieldOptionsDeserializer deserializer,
  ExtensionRegistry registry,
) {
  final value = getOption(ext, option, deserializer, registry);
  return value ?? defaultValue;
}
