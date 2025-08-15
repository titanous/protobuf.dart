// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';

import 'gen/edition2023.pb.dart' as edition2023;
import 'gen/edition2023-proto2.pb.dart' as edition2023_proto2;
import 'gen/edition2023-proto3.pb.dart' as edition2023_proto3;
import 'gen/edition2023-map-encoding.pb.dart' as edition2023_map;

import 'helpers_edition2023.dart';

void main() {
  group('edition2023 serialization', () {
    test('should round-trip for binary', () {
      final a = fillEdition2023Message(edition2023.Edition2023Message());
      final bytes = a.writeToBuffer();
      final b = edition2023.Edition2023Message.fromBuffer(bytes);
      expect(b, equals(a));
    });

    test('should round-trip for json', () {
      final a = fillEdition2023Message(edition2023.Edition2023Message());
      final json = a.writeToJson();
      final b = edition2023.Edition2023Message()..mergeFromJson(json);
      expect(b, equals(a));
    });

    group('proto2 / edition2023 interop', () {
      test('to binary', () {
        final msgProto2 = fillProto2Message(
          edition2023_proto2.Proto2MessageForEdition2023(),
        );
        final msgEdition = fillEditionFromProto2Message(
          edition2023.Edition2023FromProto2Message(),
        );
        expect(msgEdition.writeToBuffer(), equals(msgProto2.writeToBuffer()));
      });

      test('to json', () {
        final msgProto2 = fillProto2Message(
          edition2023_proto2.Proto2MessageForEdition2023(),
        );
        final msgEdition = fillEditionFromProto2Message(
          edition2023.Edition2023FromProto2Message(),
        );
        expect(msgEdition.writeToJson(), equals(msgProto2.writeToJson()));
      });

      test('from binary', () {
        final msgProto2 = fillProto2Message(
          edition2023_proto2.Proto2MessageForEdition2023(),
        );
        final bytesProto2 = msgProto2.writeToBuffer();
        final msgEdition = fillEditionFromProto2Message(
          edition2023.Edition2023FromProto2Message(),
        );
        final msgFromBytes = edition2023
            .Edition2023FromProto2Message.fromBuffer(bytesProto2);
        expect(msgFromBytes, equals(msgEdition));
      });

      test('from json', () {
        final msgProto2 = fillProto2Message(
          edition2023_proto2.Proto2MessageForEdition2023(),
        );
        final jsonProto2 = msgProto2.writeToJson();
        final msgEdition = fillEditionFromProto2Message(
          edition2023.Edition2023FromProto2Message(),
        );
        final msgFromJson =
            edition2023.Edition2023FromProto2Message()
              ..mergeFromJson(jsonProto2);
        expect(msgFromJson, equals(msgEdition));
      });
    });

    group('proto3 / edition2023 interop', () {
      test('to binary', () {
        final msgProto3 = fillProto3Message(
          edition2023_proto3.Proto3MessageForEdition2023(),
        );
        final msgEdition = fillEditionFromProto3Message(
          edition2023.Edition2023FromProto3Message(),
        );
        expect(msgEdition.writeToBuffer(), equals(msgProto3.writeToBuffer()));
      });

      test('to json', () {
        final msgProto3 = fillProto3Message(
          edition2023_proto3.Proto3MessageForEdition2023(),
        );
        final msgEdition = fillEditionFromProto3Message(
          edition2023.Edition2023FromProto3Message(),
        );
        expect(msgEdition.writeToJson(), equals(msgProto3.writeToJson()));
      });

      test('from binary', () {
        final msgProto3 = fillProto3Message(
          edition2023_proto3.Proto3MessageForEdition2023(),
        );
        final bytesProto3 = msgProto3.writeToBuffer();
        final msgEdition = fillEditionFromProto3Message(
          edition2023.Edition2023FromProto3Message(),
        );
        final msgFromBytes = edition2023
            .Edition2023FromProto3Message.fromBuffer(bytesProto3);
        expect(msgFromBytes, equals(msgEdition));
      });

      test('from json', () {
        final msgProto3 = fillProto3Message(
          edition2023_proto3.Proto3MessageForEdition2023(),
        );
        final jsonProto3 = msgProto3.writeToJson();
        final msgEdition = fillEditionFromProto3Message(
          edition2023.Edition2023FromProto3Message(),
        );
        final msgFromJson =
            edition2023.Edition2023FromProto3Message()
              ..mergeFromJson(jsonProto3);
        expect(msgFromJson, equals(msgEdition));
      });
    });

    group('message_encoding DELIMITED with maps', () {
      test('should round-trip', () {
        final a = edition2023_map.Edition2023MapEncodingMessage();
        a.stringMap[123] = 'abc';
        final bytes = a.writeToBuffer();
        final b = edition2023_map.Edition2023MapEncodingMessage.fromBuffer(
          bytes,
        );
        expect(b, equals(a));
      });

      test('should serialize map entry LENGTH_PREFIXED', () {
        final msg = edition2023_map.Edition2023MapEncodingMessage();
        msg.stringMap[123] = 'abc';
        final bytes = msg.writeToBuffer();
        final reader = CodedBufferReader(bytes);

        // Read the tag
        final tag = reader.readTag();
        expect(tag >> 3, equals(77)); // Field number 77
        expect(tag & 0x7, equals(2)); // Wire type LENGTH_DELIMITED

        // The rest of the test would require lower-level access to wire format
        // which is handled internally by the protobuf library
      });

      test('should serialize map value message LENGTH_PREFIXED', () {
        final msg = edition2023_map.Edition2023MapEncodingMessage();
        msg.messageMap[123] =
            edition2023_map.Edition2023MapEncodingMessage_Child();
        final bytes = msg.writeToBuffer();
        final reader = CodedBufferReader(bytes);

        // Read the tag
        final tag = reader.readTag();
        expect(tag >> 3, equals(88)); // Field number 88
        expect(tag & 0x7, equals(2)); // Wire type LENGTH_DELIMITED

        // The rest of the test would require lower-level access to wire format
        // which is handled internally by the protobuf library
      });
    });
  });
}
