import 'dart:io';

import 'package:test/test.dart';

import 'package:pixelarticons_tool/src/pubspec_updater.dart';

void main() {
  late Directory tempDir;
  late PubspecUpdater updater;

  const samplePubspec = '''name: pixelarticons
description: "Pixel Art Icons made simple for Flutter"
version: 0.6.0
pixelarticons_commit: abc123def456

environment:
  sdk: ">=2.14.0 <3.0.0"
  flutter: ">=1.17.0"

dependencies:
  flutter:
    sdk: flutter''';

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('pubspec_test_');
    File('${tempDir.path}/pubspec.yaml').writeAsStringSync(samplePubspec);
    updater = PubspecUpdater(projectRoot: tempDir.path);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('getKey', () {
    test('reads version', () {
      expect(updater.getKey<String>('version'), equals('0.6.0'));
    });

    test('reads commit hash', () {
      expect(
        updater.getKey<String>('pixelarticons_commit'),
        equals('abc123def456'),
      );
    });
  });

  group('getKeyOrNull', () {
    test('returns null for missing key', () {
      expect(updater.getKeyOrNull<String>('nonexistent'), isNull);
    });

    test('returns value for existing key', () {
      expect(updater.getKeyOrNull<String>('version'), equals('0.6.0'));
    });
  });

  group('setKey', () {
    test('updates version', () {
      updater.setKey('version', '0.7.0');
      expect(updater.getKey<String>('version'), equals('0.7.0'));
    });

    test('updates commit hash', () {
      updater.setKey('pixelarticons_commit', 'new123hash456');
      expect(
        updater.getKey<String>('pixelarticons_commit'),
        equals('new123hash456'),
      );
    });

    test('does not modify nested keys', () {
      updater.setKey('version', '1.0.0');
      final content = updater.readContent();
      expect(content, contains('  sdk: ">=2.14.0 <3.0.0"'));
      expect(content, contains('  flutter: ">=1.17.0"'));
    });

    test('does not modify section headers', () {
      updater.setKey('version', '1.0.0');
      final content = updater.readContent();
      expect(content, contains('environment:'));
      expect(content, contains('dependencies:'));
    });

    test('adds new key if not found', () {
      updater.setKey('new_key', 'new_value');
      expect(updater.getKey<String>('new_key'), equals('new_value'));
      // Other keys still intact
      expect(updater.getKey<String>('version'), equals('0.6.0'));
    });
  });

  group('removeKey', () {
    test('removes existing key', () {
      updater.removeKey('pixelarticons_commit');
      expect(updater.getKeyOrNull<String>('pixelarticons_commit'), isNull);
      // Other keys intact
      expect(updater.getKey<String>('version'), equals('0.6.0'));
    });

    test('does not remove nested keys', () {
      updater.removeKey('sdk');
      final content = updater.readContent();
      expect(content, contains('  sdk: ">=2.14.0 <3.0.0"'));
    });
  });
}
