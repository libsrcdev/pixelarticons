import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class PubspecUpdater {
  final String projectRoot;

  PubspecUpdater({this.projectRoot = '.'});

  File get pubspecFile => File(p.join(projectRoot, 'pubspec.yaml'));

  String readContent() => pubspecFile.readAsStringSync();

  void writeContent(String content) => pubspecFile.writeAsStringSync(content);

  Map<String, dynamic> readData() {
    final contents = loadYaml(readContent()) as YamlMap;
    return Map<String, dynamic>.from(contents);
  }

  T getKey<T>(String key) => readData()[key] as T;

  T? getKeyOrNull<T>(String key) => readData()[key] as T?;

  void setKey(String key, String value) {
    final content = readContent();
    final lines = content.split('\n');
    final emptySpace = RegExp(r'\s');

    var found = false;
    final mapped = lines.map((line) {
      if (line.isEmpty || line.startsWith(emptySpace)) return line;

      const separator = ':';
      final parts = line.split(separator);
      final k = parts.take(1).join().trim();
      final v = parts.skip(1).join(separator).trim();

      if (v.isEmpty) return line;

      if (k == key) {
        found = true;
        return '$key: $value';
      }
      return '$k: $v';
    }).toList();

    // If key wasn't found, add it after the last top-level key: value line
    // (not after section headers like "environment:" or "dependencies:")
    if (!found) {
      var insertIndex = 0;
      for (var i = 0; i < mapped.length; i++) {
        final line = mapped[i];
        if (line.isEmpty || line.startsWith(emptySpace)) continue;
        final parts = line.split(':');
        final v = parts.skip(1).join(':').trim();
        // Only count lines that have a value (not section headers)
        if (v.isNotEmpty) {
          insertIndex = i + 1;
        }
      }
      mapped.insert(insertIndex, '$key: $value');
    }

    writeContent(mapped.join('\n'));
  }

  void removeKey(String key) {
    final content = readContent();
    final lines = content.split('\n');
    final emptySpace = RegExp(r'\s');

    final filtered = lines.where((line) {
      if (line.isEmpty || line.startsWith(emptySpace)) return true;
      final k = line.split(':').take(1).join().trim();
      return k != key;
    }).toList();

    writeContent(filtered.join('\n'));
  }
}
