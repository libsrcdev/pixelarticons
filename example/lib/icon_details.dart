import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'code_block.dart';

final _vectors = rootBundle
    .loadString('assets/icon_vectors.json')
    .then(
      (source) =>
          (jsonDecode(source) as Map<String, dynamic>).cast<String, String>(),
    );

Future<Map<String, String>> loadIconVectors() => _vectors;

Future<void> showIconDetails(
  BuildContext context,
  MapEntry<String, IconData> icon,
) => showDialog<void>(
  context: context,
  builder: (context) => _IconDetails(icon: icon),
);

class _IconDetails extends StatelessWidget {
  const _IconDetails({required this.icon});
  final MapEntry<String, IconData> icon;

  Future<void> _copy(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label copied')));
  }

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    'Pixel.${icon.key}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close icon details',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList.list(
                    children: [
                      Center(
                        child: Icon(
                          icon.value,
                          size: 96,
                          semanticLabel: icon.key,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => _copy(context, icon.key, 'Name'),
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copy name'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Flutter',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      CodeBlock(
                        'Icon(Pixel.${icon.key}, size: 32)',
                        language: 'dart',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'SVG vector',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      FutureBuilder<Map<String, String>>(
                        future: _vectors,
                        builder: (context, snapshot) {
                          final svg = snapshot.data?[icon.key];
                          if (snapshot.hasError ||
                              (snapshot.hasData && svg == null)) {
                            return const Text('Unable to load this SVG.');
                          }
                          if (svg == null) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Center(
                                child: SvgPicture.string(
                                  svg,
                                  width: 96,
                                  height: 96,
                                  theme: SvgTheme(
                                    currentColor: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                  semanticsLabel: '${icon.key} SVG',
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () => _copy(context, svg, 'SVG'),
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text('Copy SVG'),
                              ),
                              CodeBlock(svg, language: 'svg'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
