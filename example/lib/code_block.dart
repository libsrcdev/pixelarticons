import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/bash.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/yaml.dart';

final _highlighter = Highlight()
  ..registerLanguages({'dart': dart, 'bash': bash, 'xml': xml, 'yaml': yaml});

const _tokenStyles = <String, TextStyle>{
  'keyword': TextStyle(color: Color(0xFF385A33)),
  'built_in': TextStyle(color: Color(0xFF385A33)),
  'type': TextStyle(color: Color(0xFF385A33)),
  'string': TextStyle(color: Color(0xFF8B3D48)),
  'number': TextStyle(color: Color(0xFF74521D)),
  'literal': TextStyle(color: Color(0xFF74521D)),
  'comment': TextStyle(color: Color(0xFF62695E), fontStyle: FontStyle.italic),
  'meta': TextStyle(color: Color(0xFF62695E)),
  'name': TextStyle(color: Color(0xFF385A33)),
  'attr': TextStyle(color: Color(0xFF375F79)),
  'attribute': TextStyle(color: Color(0xFF375F79)),
  'variable': TextStyle(color: Color(0xFF375F79)),
};

TextSpan _tokenSpan(Node node) => TextSpan(
  text: node.value,
  style: _tokenStyles[node.className],
  children: node.children?.map(_tokenSpan).toList(),
);

class CodeBlock extends StatelessWidget {
  const CodeBlock(this.code, {this.language, super.key});
  final String code;
  final String? language;

  TextSpan get _highlightedCode {
    final syntax = switch (language?.toLowerCase()) {
      'dart' => 'dart',
      'shell' || 'sh' || 'bash' => 'bash',
      'svg' || 'xml' || 'html' => 'xml',
      'yaml' || 'yml' => 'yaml',
      _ => null,
    };
    if (syntax == null) return TextSpan(text: code);
    final result = _highlighter.parse(code, language: syntax);
    return TextSpan(children: result.nodes?.map(_tokenSpan).toList());
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'Copy code',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Code copied')));
            },
          ),
        ),
        SelectableText.rich(
          _highlightedCode,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}
