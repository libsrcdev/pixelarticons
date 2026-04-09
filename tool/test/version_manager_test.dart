import 'package:test/test.dart';

import 'package:pixelarticons_tool/src/version_manager.dart';

void main() {
  group('bumpMinorVersion', () {
    test('bumps minor and resets patch', () {
      expect(bumpMinorVersion('0.6.0'), equals('0.7.0'));
    });

    test('bumps from 0.0.0', () {
      expect(bumpMinorVersion('0.0.0'), equals('0.1.0'));
    });

    test('bumps higher minor versions', () {
      expect(bumpMinorVersion('1.9.0'), equals('1.10.0'));
    });

    test('resets patch regardless of current', () {
      expect(bumpMinorVersion('2.3.5'), equals('2.4.0'));
    });

    test('handles major version', () {
      expect(bumpMinorVersion('10.0.0'), equals('10.1.0'));
    });
  });
}
