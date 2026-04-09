import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Package structure', () {
    test('pubspec.yaml exists and has required fields', () {
      final file = File('pubspec.yaml');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains('name: pixelarticons'));
      expect(content, contains('pixelarticons_commit:'));
      expect(content, contains("family: Pixel Art Icons"));
      expect(content, contains('asset: fonts/pixelarticons.otf'));
    });

    test('library entry point exports pixel.dart', () {
      final file = File('lib/pixelarticons.dart');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains("export './pixel.dart'"));
    });

    test('font file exists', () {
      final file = File('fonts/pixelarticons.otf');
      expect(file.existsSync(), isTrue,
          reason: 'Font file must be generated before running tests');
      expect(file.lengthSync(), greaterThan(0));
    });

    test('pixel.dart is generated with Pixel class', () {
      final file = File('lib/pixel.dart');
      expect(file.existsSync(), isTrue,
          reason: 'pixel.dart must be generated before running tests');

      final content = file.readAsStringSync();
      expect(content, contains('class Pixel'));
      expect(content, contains('IconData'));
      expect(content, contains("fontFamily: 'Pixel Art Icons'"));
      expect(content, contains("fontPackage: 'pixelarticons'"));
    });

    test('pixel.dart icons follow naming conventions', () {
      final file = File('lib/pixel.dart');
      if (!file.existsSync()) {
        markTestSkipped('pixel.dart not generated');
        return;
      }

      final content = file.readAsStringSync();

      // Dart keywords and numeric-prefixed names should have 'k' prefix
      expect(content, isNot(contains('static const IconData switch')));
      expect(content, isNot(contains('static const IconData 4k')));

      // Should use camelCase (no hyphens in identifiers)
      final iconPattern = RegExp(r'static const IconData (\w+)');
      final matches = iconPattern.allMatches(content);
      expect(matches.length, greaterThan(0),
          reason: 'Should have at least one icon defined');

      for (final match in matches) {
        final name = match.group(1)!;
        expect(name, isNot(contains('-')),
            reason: 'Icon name "$name" should not contain hyphens');
      }
    });

    test('SVG source files exist in release folder', () {
      final dir = Directory('release/svg');
      expect(dir.existsSync(), isTrue,
          reason: 'SVG source files must be downloaded before running tests');

      final svgs =
          dir.listSync().where((f) => f.path.endsWith('.svg')).toList();
      expect(svgs.length, greaterThan(0));
    });
  });
}
