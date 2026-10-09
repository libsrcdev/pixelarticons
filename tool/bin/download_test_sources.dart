import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pixelarticons_tool/src/github_api.dart';
import 'package:pixelarticons_tool/src/pubspec_updater.dart';
import 'package:pixelarticons_tool/src/svg_processor.dart';

/// Download the package's pinned SVG revision without regenerating artifacts.
Future<void> main() async {
  final commit = PubspecUpdater(projectRoot: '..')
      .getKey<String>('pixelarticons_commit');
  final client = http.Client();
  try {
    final bytes = await downloadZipball(client, commitSha: commit);
    final count = await extractSvgs(bytes, outputDir: '../release/svg');
    File('../release/source_commit.txt').writeAsStringSync('$commit\n');
    print('Downloaded $count source SVGs at $commit.');
  } finally {
    client.close();
  }
}
