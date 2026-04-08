import 'dart:io';
import 'package:test/test.dart';

/// Extracted from [setPackagePubspecKey] for testability.
/// Replaces a top-level YAML key's value in a pubspec string.
String setPubspecKeyInContent(String content, String key, String value) {
  final emptySpace = RegExp(r'\s');

  return content.split('\n').map((line) {
    if (line.isEmpty || line.startsWith(emptySpace)) return line;

    const separator = ':';
    final parts = line.split(separator);
    final k = parts.take(1).join().trim();
    final v = parts.skip(1).join(separator).trim();

    if (v.isEmpty) return line;

    return k == key ? '$key: $value' : '$k: $v';
  }).join('\n');
}

void main() {
  group('Pubspec key manipulation', () {
    const samplePubspec = '''name: pixelarticons
description: "Pixel Art Icons made simple for Flutter"
version: 0.6.0
pixelarticons_version: v1.8.0

environment:
  sdk: ">=2.14.0 <3.0.0"
  flutter: ">=1.17.0"

dependencies:
  flutter:
    sdk: flutter''';

    test('updates version key', () {
      final result = setPubspecKeyInContent(samplePubspec, 'version', '0.7.0');
      expect(result, contains('version: 0.7.0'));
      // Should not change other keys
      expect(result, contains('name: pixelarticons'));
      expect(result, contains('pixelarticons_version: v1.8.0'));
    });

    test('updates pixelarticons_version key', () {
      final result = setPubspecKeyInContent(
          samplePubspec, 'pixelarticons_version', 'v2.0.0');
      expect(result, contains('pixelarticons_version: v2.0.0'));
      expect(result, contains('version: 0.6.0'));
    });

    test('does not modify nested keys', () {
      final result = setPubspecKeyInContent(samplePubspec, 'version', '1.0.0');
      // Indented lines (like sdk under environment) should stay unchanged
      expect(result, contains('  sdk: ">=2.14.0 <3.0.0"'));
      expect(result, contains('  flutter: ">=1.17.0"'));
    });

    test('does not modify multi-value keys without values', () {
      final result = setPubspecKeyInContent(samplePubspec, 'version', '1.0.0');
      // Lines like "environment:" or "dependencies:" have no value, so stay untouched
      expect(result, contains('environment:'));
      expect(result, contains('dependencies:'));
    });

    test('handles description with colons', () {
      final result =
          setPubspecKeyInContent(samplePubspec, 'description', '"New desc"');
      expect(result, contains('description: "New desc"'));
    });

    test('key that does not exist leaves content unchanged', () {
      final result =
          setPubspecKeyInContent(samplePubspec, 'nonexistent', 'value');
      expect(result, equals(samplePubspec));
    });
  });

  group('Pubspec file I/O', () {
    late File tempPubspec;

    setUp(() {
      tempPubspec = File('test_pubspec_temp.yaml');
      tempPubspec.writeAsStringSync(
          'name: testpkg\nversion: 1.0.0\nhomepage: https://example.com\n');
    });

    tearDown(() {
      if (tempPubspec.existsSync()) {
        tempPubspec.deleteSync();
      }
    });

    test('reads and writes pubspec content correctly', () {
      final content = tempPubspec.readAsStringSync();
      expect(content, contains('name: testpkg'));

      final updated = setPubspecKeyInContent(content, 'version', '2.0.0');
      tempPubspec.writeAsStringSync(updated);

      final result = tempPubspec.readAsStringSync();
      expect(result, contains('version: 2.0.0'));
      expect(result, contains('name: testpkg'));
    });
  });
}
