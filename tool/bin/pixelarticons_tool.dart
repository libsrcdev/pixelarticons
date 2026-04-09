import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'package:pixelarticons_tool/src/cli.dart';
import 'package:pixelarticons_tool/src/constants.dart';
import 'package:pixelarticons_tool/src/github_api.dart';
import 'package:pixelarticons_tool/src/svg_processor.dart';
import 'package:pixelarticons_tool/src/pubspec_updater.dart';
import 'package:pixelarticons_tool/src/version_manager.dart';
import 'package:pixelarticons_tool/src/changelog_updater.dart';

void writeGithubOutput(String key, String value) {
  final outputFile = Platform.environment['GITHUB_OUTPUT'];
  if (outputFile != null) {
    File(outputFile).writeAsStringSync(
      '$key=$value\n',
      mode: FileMode.append,
    );
  }
}

Future<void> main(List<String> arguments) async {
  final parser = buildParser();
  final args = parser.parse(arguments);

  if (args['help'] as bool) {
    print('pixelarticons_tool - Sync, download, and publish pixelarticons');
    print('');
    print('Usage: dart run tool/bin/pixelarticons_tool.dart [flags]');
    print('');
    print(parser.usage);
    return;
  }

  final dryRun = args['dry-run'] as bool;
  final noCache = args['no-cache'] as bool;
  final projectRoot = args['project-root'] as String;

  final client = http.Client();
  try {
    // 1. Fetch latest commit info
    print('Fetching latest commit from $upstreamOwner/$upstreamRepo...');
    final commitData = await fetchLatestCommit(client);
    final latestSha = commitData['sha'] as String;
    final shortSha = latestSha.substring(0, 12);
    final commit = commitData['commit'] as Map<String, dynamic>;
    final commitMessage = commit['message'] as String;
    final committer = commit['committer'] as Map<String, dynamic>;
    final commitDate = committer['date'] as String;

    print('Latest commit: $shortSha');

    // 2. Compare with stored hash
    final pubspec = PubspecUpdater(projectRoot: projectRoot);
    final currentHash = pubspec.getKeyOrNull<String>(pubspecCommitKey);
    final hasUpdate = currentHash == null || !latestSha.startsWith(currentHash);

    if (!hasUpdate && !noCache) {
      print('Up to date (commit: $shortSha)');
      writeGithubOutput('update_available', 'false');
      return;
    }

    if (hasUpdate) {
      print('Update available: $currentHash -> $shortSha');
    } else {
      print('Forcing re-download (--no-cache)');
    }

    // 3. Dry run: report and exit
    if (dryRun) {
      writeGithubOutput('update_available', 'true');
      print('Dry run complete. No changes made.');
      return;
    }

    // 4. Download and extract SVGs
    print('Downloading zipball...');
    final zipBytes = await downloadZipball(client);
    print(
        'Downloaded ${(zipBytes.length / 1024 / 1024).toStringAsFixed(1)} MB');

    final outputDir = p.join(projectRoot, releaseSvgDir);
    final svgCount =
        await extractAndProcessSvgs(zipBytes, outputDir: outputDir);
    print('Extracted $svgCount SVGs to $outputDir');

    // 5. Update pubspec.yaml
    final currentVersion = pubspec.getKey<String>(pubspecVersionKey);
    final nextVersion = bumpMinorVersion(currentVersion);

    pubspec.setKey(pubspecVersionKey, nextVersion);
    pubspec.setKey(pubspecCommitKey, shortSha);

    // Remove old key if present
    if (pubspec.getKeyOrNull<String>('pixelarticons_version') != null) {
      pubspec.removeKey('pixelarticons_version');
    }

    print('Updated version: $currentVersion -> $nextVersion');
    print('Updated commit: $shortSha');

    // 6. Update changelog
    updateChangelog(
      packageVersion: nextVersion,
      commitHash: latestSha,
      commitMessage: commitMessage,
      commitDate: commitDate,
      projectRoot: projectRoot,
    );
    print('Updated CHANGELOG.md');

    // 7. Write CI outputs
    writeGithubOutput('update_available', 'true');
    writeGithubOutput('new_version', nextVersion);

    print('Done!');
  } finally {
    client.close();
  }
}
