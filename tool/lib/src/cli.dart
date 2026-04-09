import 'package:args/args.dart';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'dry-run',
      help: 'Check for updates without making changes',
      defaultsTo: false,
    )
    ..addFlag(
      'no-cache',
      help: 'Force re-download even if commit hash matches',
      defaultsTo: false,
    )
    ..addOption(
      'project-root',
      help: 'Path to the pixelarticons project root',
      defaultsTo: '.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Print usage information',
      negatable: false,
    );
}
