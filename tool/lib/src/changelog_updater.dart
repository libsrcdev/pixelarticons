import 'dart:io';

import 'package:path/path.dart' as p;

void updateChangelog({
  required String packageVersion,
  required String commitHash,
  required String commitMessage,
  required String commitDate,
  String projectRoot = '.',
}) {
  final file = File(p.join(projectRoot, 'CHANGELOG.md'));

  final shortHash = commitHash.substring(0, 12);
  final existing = file.existsSync() ? file.readAsStringSync() : '';

  final entry = '''
## v$packageVersion

<sub>_Automatic sync with halfmage/pixelarticons at commit `$shortHash` ($commitDate)._</sub>

> $commitMessage

<sub>This CHANGELOG.md was automatically generated.</sub>
''';

  file.writeAsStringSync('$entry\n$existing');
}
