// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: constant_identifier_names

import 'gen/google/protobuf/compiler/plugin.pb.dart';

typedef OnError = void Function(String details);

// Dart API level feature values
const int API_LEVEL_UNSPECIFIED = 0;
const int API_LEVEL_HAZZERS = 1;
const int API_LEVEL_NULLABLE = 2;
const int API_LEVEL_HYBRID = 3;

/// Helper function implementing a generic option parser that reads
/// `request.parameters` and treats each token as either a flag ("name") or a
/// key-value pair ("name=value"). For each option "name", it looks up whether a
/// [SingleOptionParser] exists in [parsers] and delegates the actual parsing of
/// the option to it. Returns `true` if no errors were reported.
bool genericOptionsParser(
  CodeGeneratorRequest request,
  CodeGeneratorResponse response,
  Map<String, SingleOptionParser> parsers,
) {
  final parameter = request.parameter;
  final options = parameter.trim().split(',');
  final errors = [];

  for (var option in options) {
    option = option.trim();
    if (option.isEmpty) continue;
    void reportError(String details) {
      errors.add('Error found trying to parse the option: $option.\n$details');
    }

    final nameValue = option.split('=');
    if (nameValue.length != 1 && nameValue.length != 2) {
      reportError('Options should be a single token, or a name=value pair');
      continue;
    }
    final name = nameValue[0].trim();
    final parser = parsers[name];
    if (parser == null) {
      reportError('Unknown option ($name).');
      continue;
    }

    final value = nameValue.length > 1 ? nameValue[1].trim() : null;
    parser.parse(name, value, reportError);
  }

  if (errors.isEmpty) return true;

  response.error = errors.join('\n');
  return false;
}

/// Options expected by the protoc code generation compiler.
class GenerationOptions {
  final bool useGrpc;
  final bool generateMetadata;
  final bool disableConstructorArgs;
  final String? defaultApiLevel;
  final Map<String, String> apiLevelMappings;

  GenerationOptions({
    this.useGrpc = false,
    this.generateMetadata = false,
    this.disableConstructorArgs = false,
    this.defaultApiLevel,
    Map<String, String>? apiLevelMappings,
  }) : apiLevelMappings = apiLevelMappings ?? {};
}

/// A parser for a name-value pair option. Options parsed in
/// [genericOptionsParser] delegate to instances of this class to
/// parse the value of a specific option.
abstract class SingleOptionParser {
  /// Parse the [name]=[value] value pair and report any errors to [onError]. If
  /// the option is a flag, [value] will be null. Note, [name] is commonly
  /// unused. It is provided because [SingleOptionParser] can be registered for
  /// multiple option names in [genericOptionsParser].
  void parse(String name, String? value, OnError onError);
}

class GrpcOptionParser implements SingleOptionParser {
  bool grpcEnabled = false;

  @override
  void parse(String name, String? value, OnError onError) {
    if (value != null) {
      onError('Invalid grpc option. No value expected.');
      return;
    }
    grpcEnabled = true;
  }
}

class GenerateMetadataParser implements SingleOptionParser {
  bool generateKytheInfo = false;

  @override
  void parse(String name, String? value, OnError onError) {
    if (value != null) {
      onError('Invalid generate_kythe_info option. No value expected.');
      return;
    }
    generateKytheInfo = true;
  }
}

class DisableConstructorArgsParser implements SingleOptionParser {
  bool value = false;

  @override
  void parse(String name, String? value, OnError onError) {
    if (value != null) {
      onError('Invalid disable_constructor_args option. No value expected.');
      return;
    }
    this.value = true;
  }
}

class DefaultApiLevelParser implements SingleOptionParser {
  String? defaultApiLevel;

  @override
  void parse(String name, String? value, OnError onError) {
    if (value == null) {
      onError(
        'default_api_level requires a value: API_LEVEL_HAZZERS, API_LEVEL_NULLABLE, or API_LEVEL_HYBRID',
      );
      return;
    }
    if (![
      'API_LEVEL_HAZZERS',
      'API_LEVEL_NULLABLE',
      'API_LEVEL_HYBRID',
    ].contains(value)) {
      onError(
        'Invalid api_level: $value. Must be one of: API_LEVEL_HAZZERS, API_LEVEL_NULLABLE, API_LEVEL_HYBRID',
      );
      return;
    }
    defaultApiLevel = value;
  }
}

class ApiLevelMappingParser implements SingleOptionParser {
  final Map<String, String> apiLevelMappings = {};

  @override
  void parse(String name, String? value, OnError onError) {
    // Extract the filename from the option name
    // Format: api_levelMfilename.proto=API_LEVEL
    // The name parameter will be: api_levelMfilename.proto
    if (!name.startsWith('api_levelM')) {
      onError('Invalid api_levelM option format');
      return;
    }

    final filename = name.substring('api_levelM'.length);
    if (filename.isEmpty) {
      onError('api_levelM requires a filename: api_levelMfile.proto=API_LEVEL');
      return;
    }

    if (value == null) {
      onError(
        'api_levelM requires a value: API_LEVEL_HAZZERS, API_LEVEL_NULLABLE, or API_LEVEL_HYBRID',
      );
      return;
    }

    if (![
      'API_LEVEL_HAZZERS',
      'API_LEVEL_NULLABLE',
      'API_LEVEL_HYBRID',
    ].contains(value)) {
      onError('Invalid api_level for $filename: $value');
      return;
    }

    apiLevelMappings[filename] = value;
  }
}

/// Parser used by the compiler, which supports the `rpc` option (see
/// [GrpcOptionParser]) and any additional option added in [parsers]. If
/// [parsers] has a key for `rpc`, it will be ignored.
GenerationOptions? parseGenerationOptions(
  CodeGeneratorRequest request,
  CodeGeneratorResponse response, [
  Map<String, SingleOptionParser>? parsers,
]) {
  final newParsers = <String, SingleOptionParser>{};
  if (parsers != null) newParsers.addAll(parsers);

  final grpcOptionParser = GrpcOptionParser();
  newParsers['grpc'] = grpcOptionParser;

  final generateMetadataParser = GenerateMetadataParser();
  newParsers['generate_kythe_info'] = generateMetadataParser;

  final defaultApiLevelParser = DefaultApiLevelParser();
  newParsers['default_api_level'] = defaultApiLevelParser;

  final apiLevelMappingParser = ApiLevelMappingParser();
  // Register a parser that handles all api_levelM* options
  // We need to handle these specially in genericOptionsParser

  final disableConstructorArgsParser = DisableConstructorArgsParser();
  newParsers['disable_constructor_args'] = disableConstructorArgsParser;

  // Handle api_levelM options specially and filter them out
  final parameter = request.parameter;
  final options = parameter.trim().split(',');
  final filteredOptions = <String>[];

  for (var option in options) {
    option = option.trim();
    if (option.isEmpty) continue;

    final nameValue = option.split('=');
    final name = nameValue.isNotEmpty ? nameValue[0].trim() : '';

    if (name.startsWith('api_levelM')) {
      final filename = name.substring('api_levelM'.length);
      if (filename.isEmpty) {
        // api_levelM= without filename
        response.error =
            '${response.error}api_levelM requires a filename: api_levelMfile.proto=API_LEVEL\n';
        return null;
      }
      if (nameValue.length == 1) {
        // api_levelMfile.proto without value
        response.error =
            '${response.error}api_levelM requires a value: api_levelMfile.proto=API_LEVEL\n';
        return null;
      } else if (nameValue.length == 2) {
        final value = nameValue[1].trim();
        apiLevelMappingParser.parse(name, value, (error) {
          response.error = '${response.error}$error\n';
        });
        // Check if there was an error during parsing
        if (response.error.isNotEmpty) {
          return null;
        }
      }
    } else {
      // Keep non-api_levelM options for genericOptionsParser
      filteredOptions.add(option);
    }
  }

  // Create a new request with filtered options
  final filteredRequest =
      CodeGeneratorRequest()
        ..parameter = filteredOptions.join(',')
        ..protoFile.addAll(request.protoFile);

  if (genericOptionsParser(filteredRequest, response, newParsers)) {
    return GenerationOptions(
      useGrpc: grpcOptionParser.grpcEnabled,
      generateMetadata: generateMetadataParser.generateKytheInfo,
      disableConstructorArgs: disableConstructorArgsParser.value,
      defaultApiLevel: defaultApiLevelParser.defaultApiLevel,
      apiLevelMappings: apiLevelMappingParser.apiLevelMappings,
    );
  }
  return null;
}
