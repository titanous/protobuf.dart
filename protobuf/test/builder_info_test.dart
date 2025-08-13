// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';

void main() {
  group('className', () {
    final qualifiedmessageName = 'proto.test.TestMessage';
    final expectedMessageName = 'TestMessage';
    test('truncates qualifiedMessageName containing dots', () {
      final info = BuilderInfo(qualifiedmessageName);
      expect(info.messageName, expectedMessageName);
    });

    test('uses qualifiedMessageName if it contains no dots', () {
      final info = BuilderInfo(expectedMessageName);
      expect(info.messageName, expectedMessageName);
    });
  });

  group('oneof names', () {
    test('oo() works without name parameter (backward compatibility)', () {
      final info = BuilderInfo('TestMessage');
      info.oo(0, [1, 2]);
      
      expect(info.oneofs[1], 0);
      expect(info.oneofs[2], 0);
      expect(info.getOneofName(0), null);
    });

    test('oo() stores oneof names when provided', () {
      final info = BuilderInfo('TestMessage');
      info.oo(0, [1, 2], 'choice');
      info.oo(1, [3, 4], 'option');
      
      expect(info.oneofs[1], 0);
      expect(info.oneofs[2], 0);
      expect(info.oneofs[3], 1);
      expect(info.oneofs[4], 1);
      
      expect(info.getOneofName(0), 'choice');
      expect(info.getOneofName(1), 'option');
    });

    test('getOneofName() returns null for invalid indices', () {
      final info = BuilderInfo('TestMessage');
      info.oo(0, [1, 2], 'choice');
      
      expect(info.getOneofName(-1), null);
      expect(info.getOneofName(1), null);
      expect(info.getOneofName(99), null);
    });

    test('getOneofIndexByName() finds oneof by name', () {
      final info = BuilderInfo('TestMessage');
      info.oo(0, [1, 2], 'choice');
      info.oo(2, [5, 6], 'selection'); // Skip index 1
      
      expect(info.getOneofIndexByName('choice'), 0);
      expect(info.getOneofIndexByName('selection'), 2);
      expect(info.getOneofIndexByName('unknown'), null);
    });

    test('handles sparse oneof indices correctly', () {
      final info = BuilderInfo('TestMessage');
      info.oo(5, [10, 11], 'sparse');
      
      expect(info.getOneofName(5), 'sparse');
      expect(info.getOneofIndexByName('sparse'), 5);
      
      // Indices 0-4 should return null
      for (int i = 0; i < 5; i++) {
        expect(info.getOneofName(i), null);
      }
    });

    test('handles empty oneof names correctly', () {
      final info = BuilderInfo('TestMessage');
      info.oo(0, [1, 2], '');
      
      expect(info.getOneofName(0), null); // Empty string treated as null
      expect(info.getOneofIndexByName(''), null);
    });
  });
}
