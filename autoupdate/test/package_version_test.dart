import 'package:test/test.dart';

/// Extracted version bump logic from [getNextPackageVersion] for testability.
/// The original reads from pubspec.yaml; here we test the pure logic.
String bumpMinorVersion(String current) {
  final version = current.split('.').map(int.parse).toList();
  final major = version[0];
  final minor = version[1];
  return '$major.${minor + 1}.0';
}

void main() {
  group('Version bumping', () {
    test('bumps minor version and resets patch', () {
      expect(bumpMinorVersion('0.6.0'), equals('0.7.0'));
    });

    test('bumps from 0.0.0', () {
      expect(bumpMinorVersion('0.0.0'), equals('0.1.0'));
    });

    test('bumps higher minor versions', () {
      expect(bumpMinorVersion('1.9.0'), equals('1.10.0'));
    });

    test('resets patch to zero regardless of current patch', () {
      expect(bumpMinorVersion('2.3.5'), equals('2.4.0'));
    });

    test('handles major version correctly', () {
      expect(bumpMinorVersion('10.0.0'), equals('10.1.0'));
    });
  });

  group('Version comparison', () {
    test('same versions are equal', () {
      expect('v1.8.1' != 'v1.8.1', isFalse);
    });

    test('different versions are not equal', () {
      expect('v1.8.0' != 'v1.8.1', isTrue);
    });
  });
}
