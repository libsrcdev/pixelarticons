import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import 'icon_categories.dart';
import 'icon_styles.dart';

void main() => runApp(const PixelArtIconsExample());

class PixelArtIconsExample extends StatelessWidget {
  const PixelArtIconsExample({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF53644B)),
      scaffoldBackgroundColor: const Color(0xFFF7F8F5),
    ),
    home: const IconGallery(),
  );
}

class IconGallery extends StatefulWidget {
  const IconGallery({super.key});

  @override
  State<IconGallery> createState() => _IconGalleryState();
}

class _IconGalleryState extends State<IconGallery> {
  String _query = '';
  String? _category;
  IconStyle? _style;
  final _scrollController = ScrollController();
  final _groups = <String, List<MapEntry<String, IconData>>>{
    for (final category in iconCategories.keys) category: [],
  };

  @override
  void initState() {
    super.initState();
    for (final icon in Pixel.allIcons.entries) {
      _groups[categoryForIcon(icon.key)]!.add(icon);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFilters(VoidCallback update) {
    setState(update);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<MapEntry<String, IconData>>>{
      for (final group in _groups.entries)
        if (_category == null || group.key == _category)
          group.key: group.value
              .where(
                (icon) =>
                    icon.key.contains(_query) &&
                    (_style == null || styleForIcon(icon.key) == _style),
              )
              .toList(),
    }..removeWhere((name, icons) => icons.isEmpty);
    final count = groups.values.fold(0, (total, icons) => total + icons.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Pixel Art Icons')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search $count icons by name',
                    prefixIcon: const Icon(Pixel.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _updateFilters(() {
                    _query = value.trim().toLowerCase();
                  }),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _categoryChip('All icons', null),
                    for (final category in _groups.entries)
                      if (category.value.isNotEmpty)
                        _categoryChip(category.key, category.key),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _styleChip('All styles', null),
                    for (final style in IconStyle.values)
                      _styleChip(style.label, style),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('$count of ${Pixel.allIcons.length} icons'),
              ),
              Expanded(
                child: groups.isEmpty
                    ? const Center(child: Text('No icons found'))
                    : CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          for (final group in groups.entries) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  20,
                                  20,
                                  12,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      group.key,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${group.value.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                              sliver: SliverGrid.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 150,
                                      mainAxisExtent: 116,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                itemCount: group.value.length,
                                itemBuilder: (context, index) =>
                                    _IconTile(icon: group.value[index]),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _styleChip(String label, IconStyle? style) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _style == style,
      onSelected: (_) => _updateFilters(() => _style = style),
    ),
  );

  Widget _categoryChip(String label, String? category) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _category == category,
      onSelected: (_) => _updateFilters(() => _category = category),
    ),
  );
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final MapEntry<String, IconData> icon;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Tooltip(
      message: 'Pixel.${icon.key}',
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon.value, size: 32, semanticLabel: icon.key),
            const SizedBox(height: 12),
            Text(
              icon.key,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}
