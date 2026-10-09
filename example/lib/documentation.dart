import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import 'code_block.dart';
import 'external_link.dart';

String? _cachedDocumentation;
final _documentation = rootBundle
    .loadString('assets/docs/getting_started.md')
    .then((source) {
      _cachedDocumentation = source;
      return source;
    });
Future<String> loadDocumentation() => _cachedDocumentation == null
    ? _documentation
    : SynchronousFuture(_cachedDocumentation!);

class DocumentationPage extends StatefulWidget {
  const DocumentationPage({super.key});

  @override
  State<DocumentationPage> createState() => _DocumentationPageState();
}

class _DocumentationPageState extends State<DocumentationPage> {
  late final _source = loadDocumentation();

  @override
  Widget build(BuildContext context) => CustomScrollView(
    key: const PageStorageKey('documentation'),
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.all(24),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: FutureBuilder<String>(
                future: _source,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Unable to load documentation.');
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return MarkdownBody(
                    data: snapshot.data!,
                    selectable: true,
                    onTapLink: (text, href, title) {
                      if (href == null) return;
                      openExternalLink(context, Uri.parse(href));
                    },
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                          h1: Theme.of(context).textTheme.headlineMedium,
                          h2: Theme.of(context).textTheme.titleLarge,
                          h2Padding: const EdgeInsets.only(top: 24, bottom: 12),
                          p: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(height: 1.6),
                          blockSpacing: 16,
                          code: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 14,
                          ),
                        ),
                    builders: {'pre': _CodeBuilder()},
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _CodeBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.children?.whereType<md.Element>().firstOrNull;
    final language = code?.attributes['class']
        ?.split(' ')
        .where((name) => name.startsWith('language-'))
        .firstOrNull
        ?.substring('language-'.length);
    return CodeBlock(
      element.textContent.replaceFirst(RegExp(r'\n$'), ''),
      language: language,
    );
  }
}
