import 'package:test/test.dart';

import 'package:pixelarticons_tool/src/cli.dart';

void main() {
  group('buildParser', () {
    final parser = buildParser();

    test('parses dry-run flag', () {
      final result = parser.parse(['--dry-run']);
      expect(result['dry-run'], isTrue);
    });

    test('parses no-cache flag', () {
      final result = parser.parse(['--no-cache']);
      expect(result['no-cache'], isTrue);
    });

    test('parses project-root option', () {
      final result = parser.parse(['--project-root', '/some/path']);
      expect(result['project-root'], equals('/some/path'));
    });

    test('defaults dry-run to false', () {
      final result = parser.parse([]);
      expect(result['dry-run'], isFalse);
    });

    test('defaults no-cache to false', () {
      final result = parser.parse([]);
      expect(result['no-cache'], isFalse);
    });

    test('defaults project-root to current dir', () {
      final result = parser.parse([]);
      expect(result['project-root'], equals('.'));
    });

    test('parses help flag', () {
      final result = parser.parse(['-h']);
      expect(result['help'], isTrue);
    });

    test('parses multiple flags together', () {
      final result = parser.parse([
        '--dry-run',
        '--no-cache',
        '--project-root',
        '/my/project',
      ]);
      expect(result['dry-run'], isTrue);
      expect(result['no-cache'], isTrue);
      expect(result['project-root'], equals('/my/project'));
    });
  });
}
