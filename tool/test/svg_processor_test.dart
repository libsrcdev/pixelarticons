import 'dart:io';

import 'package:archive/archive.dart';
import 'package:test/test.dart';

import 'package:pixelarticons_tool/src/svg_processor.dart';
import 'package:pixelarticons_tool/src/constants.dart';

void main() {
  group('processFilename', () {
    test('regular icon not prefixed', () {
      expect(processFilename('android.svg'), equals('android.svg'));
    });

    test('hyphenated icon not prefixed', () {
      expect(processFilename('card-plus.svg'), equals('card-plus.svg'));
    });

    test('numeric prefix gets k', () {
      expect(processFilename('4k.svg'), equals('k4k.svg'));
    });

    test('numeric only gets k', () {
      expect(processFilename('123.svg'), equals('k123.svg'));
    });

    test('keyword switch gets k', () {
      expect(processFilename('switch.svg'), equals('kswitch.svg'));
    });

    test('keyword class gets k', () {
      expect(processFilename('class.svg'), equals('kclass.svg'));
    });

    test('keyword import gets k', () {
      expect(processFilename('import.svg'), equals('kimport.svg'));
    });

    test('keyword return gets k', () {
      expect(processFilename('return.svg'), equals('kreturn.svg'));
    });

    test('keyword void gets k', () {
      expect(processFilename('void.svg'), equals('kvoid.svg'));
    });

    test('non-keyword similar name not prefixed', () {
      expect(processFilename('classes.svg'), equals('classes.svg'));
    });

    test('special char prefix gets k', () {
      expect(processFilename('-minus.svg'), equals('k-minus.svg'));
    });

    test('underscore prefix gets k', () {
      expect(processFilename('_hidden.svg'), equals('k_hidden.svg'));
    });

    test('uppercase start not prefixed', () {
      expect(processFilename('Arrow.svg'), equals('Arrow.svg'));
    });
  });

  group('dartKeywords', () {
    test('is not empty', () {
      expect(dartKeywords.isNotEmpty, isTrue);
    });

    test('contains common Dart keywords', () {
      for (final kw in [
        'class',
        'if',
        'else',
        'for',
        'while',
        'return',
        'switch',
        'import',
        'void',
        'null',
        'true',
        'false'
      ]) {
        expect(dartKeywords.contains(kw), isTrue, reason: 'Missing: $kw');
      }
    });
  });

  group('extractAndProcessSvgs', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('svg_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('extracts and renames SVGs from zip', () async {
      final archive = Archive();
      final svgContent = '<svg></svg>';
      final bytes = svgContent.codeUnits;

      archive.addFile(ArchiveFile(
        'halfmage-pixelarticons-abc123/svg/android.svg',
        bytes.length,
        bytes,
      ));
      archive.addFile(ArchiveFile(
        'halfmage-pixelarticons-abc123/svg/switch.svg',
        bytes.length,
        bytes,
      ));
      archive.addFile(ArchiveFile(
        'halfmage-pixelarticons-abc123/svg/4k.svg',
        bytes.length,
        bytes,
      ));
      archive.addFile(ArchiveFile(
        'halfmage-pixelarticons-abc123/README.md',
        bytes.length,
        bytes,
      ));

      final zipBytes = ZipEncoder().encode(archive)!;
      final outputDir = '${tempDir.path}/svg';
      final count = await extractAndProcessSvgs(zipBytes, outputDir: outputDir);

      expect(count, equals(3));

      final files = Directory(outputDir)
          .listSync()
          .map((f) => f.uri.pathSegments.last)
          .toSet();

      expect(files, contains('android.svg'));
      expect(files, contains('kswitch.svg'));
      expect(files, contains('k4k.svg'));
      expect(files, isNot(contains('README.md')));
    });

    test('throws if no SVGs found', () async {
      final archive = Archive();
      archive.addFile(ArchiveFile(
        'halfmage-pixelarticons-abc123/README.md',
        5,
        'hello'.codeUnits,
      ));

      final zipBytes = ZipEncoder().encode(archive)!;
      final outputDir = '${tempDir.path}/svg';

      expect(
        () => extractAndProcessSvgs(zipBytes, outputDir: outputDir),
        throwsException,
      );
    });
  });
}
