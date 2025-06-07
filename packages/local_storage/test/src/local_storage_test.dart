// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage/local_storage.dart';

void main() {
  group('LocalStorage', () {
    test('can be instantiated', () {
      expect(LocalStorage(), isNotNull);
    });
  });
}
