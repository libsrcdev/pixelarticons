import 'dart:io';

import 'package:archive/archive.dart';
import 'package:test/test.dart';

import 'package:pixelarticons_tool/src/svg_processor.dart';

void main() {
  group('extractSvgs', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('svg_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('extracts upstream filenames without renaming', () async {
      final archive = Archive();
      final svgContent = '<svg></svg>';
      final bytes = svgContent.codeUnits;

      archive.addFile(
        ArchiveFile(
          'halfmage-pixelarticons-abc123/svg/android.svg',
          bytes.length,
          bytes,
        ),
      );
      archive.addFile(
        ArchiveFile(
          'halfmage-pixelarticons-abc123/svg/switch.svg',
          bytes.length,
          bytes,
        ),
      );
      archive.addFile(
        ArchiveFile(
          'halfmage-pixelarticons-abc123/svg/4k.svg',
          bytes.length,
          bytes,
        ),
      );
      archive.addFile(
        ArchiveFile(
          'halfmage-pixelarticons-abc123/README.md',
          bytes.length,
          bytes,
        ),
      );

      final zipBytes = ZipEncoder().encode(archive);
      final outputDir = '${tempDir.path}/svg';
      final count = await extractSvgs(zipBytes, outputDir: outputDir);

      expect(count, equals(3));

      final files = Directory(outputDir)
          .listSync()
          .map((f) => f.uri.pathSegments.last)
          .toSet();

      expect(files, contains('android.svg'));
      expect(files, contains('switch.svg'));
      expect(files, contains('4k.svg'));
      expect(files, isNot(contains('README.md')));
    });

    test('throws if no SVGs found', () async {
      final archive = Archive();
      archive.addFile(
        ArchiveFile(
          'halfmage-pixelarticons-abc123/README.md',
          5,
          'hello'.codeUnits,
        ),
      );

      final zipBytes = ZipEncoder().encode(archive);
      final outputDir = '${tempDir.path}/svg';
      Directory(outputDir).createSync();
      File('$outputDir/previous.svg').writeAsStringSync('<svg/>');

      await expectLater(
        () => extractSvgs(zipBytes, outputDir: outputDir),
        throwsException,
      );
      expect(File('$outputDir/previous.svg').existsSync(), isTrue);
    });
  });
}
