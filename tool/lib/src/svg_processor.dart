import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'constants.dart';

String processFilename(String filename) {
  final stem = p.basenameWithoutExtension(filename);
  if (!RegExp(r'^[a-zA-Z]').hasMatch(filename) || dartKeywords.contains(stem)) {
    return 'k$filename';
  }
  return filename;
}

Future<int> extractAndProcessSvgs(
  List<int> zipBytes, {
  String outputDir = releaseSvgDir,
}) async {
  final archive = ZipDecoder().decodeBytes(zipBytes);
  final outDir = Directory(outputDir);

  if (outDir.existsSync()) {
    outDir.deleteSync(recursive: true);
  }
  outDir.createSync(recursive: true);

  var count = 0;

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
      final processedName = processFilename(originalName);
      final outFile = File(p.join(outputDir, processedName));

      outFile.writeAsBytesSync(entry.content as List<int>);
      count++;
    }
  }

  if (count == 0) {
    throw Exception(
      'No SVG files found in zipball. '
      'Expected structure: */svg/*.svg',
    );
  }

  return count;
}
