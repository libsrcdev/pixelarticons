import 'dart:io';

import './tools/generate_commit_msg.dart';

const kReleaseCommitMsgActionKey = 'new_release_commit_msg';

Future<void> main() async {
  final String msg = await generateNewVersionCommitMsg();

  final githubOutput = Platform.environment['GITHUB_OUTPUT'];
  if (githubOutput != null) {
    File(githubOutput).writeAsStringSync(
      '$kReleaseCommitMsgActionKey=$msg\n',
      mode: FileMode.append,
    );
  } else {
    stdout.write('::set-output name=$kReleaseCommitMsgActionKey::$msg');
  }
}
