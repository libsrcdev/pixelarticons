import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'constants.dart';

Future<int> extractSvgs(
  List<int> zipBytes, {
  String outputDir = releaseSvgDir,
}) async {
  final archive = ZipDecoder().decodeBytes(zipBytes);
  final outDir = Directory(outputDir);

  final files = <String, List<int>>{};

  for (final entry in archive) {
    if (entry.isFile && entry.name.endsWith('.svg')) {
      final parts = p.split(entry.name);

      // Zip structure: owner-repo-sha/svg/icon.svg
      // Find entries where the parent directory is 'svg'
      final svgDirIndex = parts.indexOf('svg');
      if (svgDirIndex == -1) continue;

      // Only process files directly inside svg/ (not deeper subdirs)
      if (svgDirIndex != parts.length - 2) continue;

      final originalName = parts.last;
      if (files.containsKey(originalName)) {
        throw FormatException('Duplicate SVG filename: $originalName');
      }
      files[originalName] = entry.content;
    }
  }

  if (files.isEmpty) {
    throw Exception(
      'No SVG files found in zipball. '
      'Expected structure: */svg/*.svg',
    );
  }

  // Validate the archive before replacing the previous source set.
  if (outDir.existsSync()) outDir.deleteSync(recursive: true);
  outDir.createSync(recursive: true);
  for (final file in files.entries) {
    File(p.join(outputDir, file.key)).writeAsBytesSync(file.value);
  }
  return files.length;
}
