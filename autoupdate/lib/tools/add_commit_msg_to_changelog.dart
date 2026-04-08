import 'dart:io';

import 'package:pixelarticons_autoupdate/tools/generate_commit_msg.dart';
import 'package:pixelarticons_autoupdate/tools/package_version.dart';
import 'package:pixelarticons_autoupdate/tools/pixelarticons_version.dart';

File get changelogFile => File('./CHANGELOG.md');

Future<void> addCommitMsgToChangelog({
  String? packageVersion,
  String? commitMsg,
}) async {
  packageVersion ??= await resolveOfficialPackageVersion();
  commitMsg ??= await generateNewVersionCommitMsg();

  final String latestPixelarticonsReleaseBody =
      await getLatestPixelarticonsReleaseBody();

  final List<String> currentChangelog = changelogFile.readAsLinesSync();

  final List<String> releaseChangelog = '''
## v$packageVersion

<sub>_$commitMsg._</sub>

$latestPixelarticonsReleaseBody

<sub>This `CHANGELOG.md` was automatic generated from `libsrcdev/pixelarticons/autoupdate`.</sub>
'''
      .split('\n')
      .toList();

  final String newChangelog =
      [...releaseChangelog, ...currentChangelog].join('\n');

  changelogFile.writeAsStringSync(newChangelog);
}
