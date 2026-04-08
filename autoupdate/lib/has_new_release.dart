import 'dart:io';

import './tools/check_for_updates.dart';

const kHasNewReleaseActionKey = 'update_available';

Future<void> main() async {
  final bool hasUpdate = await hasUpdateAvailable();

  final githubOutput = Platform.environment['GITHUB_OUTPUT'];
  if (githubOutput != null) {
    File(githubOutput)
        .writeAsStringSync('$kHasNewReleaseActionKey=$hasUpdate\n',
            mode: FileMode.append);
  } else {
    // Fallback for local execution
    stdout.write('::set-output name=$kHasNewReleaseActionKey::$hasUpdate');
  }
}
