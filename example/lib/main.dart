import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/link.dart';
import 'package:pixelarticons/pixelarticons.dart';

import 'icon_categories.dart';
import 'icon_styles.dart';
import 'documentation.dart';
import 'icon_details.dart';
import 'life_background.dart';
import 'external_link.dart';

void main() => runApp(const PixelArtIconsExample());

class PixelArtIconsExample extends StatefulWidget {
  const PixelArtIconsExample({super.key, this.initialLocation});
  final String? initialLocation;
  @override
  State<PixelArtIconsExample> createState() => _PixelArtIconsExampleState();
}

class _PixelArtIconsExampleState extends State<PixelArtIconsExample> {
  late final _router = GoRouter(
    initialLocation: widget.initialLocation,
    routes: [
      for (var index = 0; index < 2; index++)
        GoRoute(
          path: index == 0 ? '/' : '/getting-started',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: const ValueKey('demo'),
            child: _DemoPage(selectedIndex: index),
          ),
        ),
    ],
  );
  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Share Tech',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF385A33))
          .copyWith(
            primary: const Color(0xFF385A33),
            onSurface: const Color(0xFF202820),
            onSurfaceVariant: const Color(0xFF62695E),
            surface: const Color(0xFFF5F4EE),
            surfaceContainer: const Color(0xFFEAF0DD),
            outlineVariant: const Color(0xFFD8DBCF),
            secondaryContainer: const Color(0xFFDFEBBD),
          ),
      scaffoldBackgroundColor: const Color(0xFFF5F4EE),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: Color(0xFFD8DBCF)),
        selectedColor: const Color(0xFFDFEBBD),
        showCheckmark: false,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF385A33),
        unselectedLabelColor: Color(0xFF62695E),
        dividerColor: Color(0xFFD8DBCF),
      ),
    ),
    title: 'Pixel Art Icons — Flutter demo & docs',
    routerConfig: _router,
  );
}

class _DemoPage extends StatefulWidget {
  const _DemoPage({required this.selectedIndex});
  final int selectedIndex;
  @override
  State<_DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<_DemoPage>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.selectedIndex,
  );
  @override
  void didUpdateWidget(_DemoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tabs.index != widget.selectedIndex) _tabs.index = widget.selectedIndex;
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxWidth < 760 || constraints.maxHeight < 700;
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: compact ? 20 : 48,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFD8DBCF)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _ProjectLink(
                            'libsrc.dev',
                            'https://libsrc.dev',
                            fontSize: 23,
                          ),
                          const Flexible(
                            child: Text(
                              'FLUTTER / ICONS',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 0.7,
                                color: Color(0xFF62695E),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        const Positioned.fill(child: LifeBackground()),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            compact ? 20 : 48,
                            compact ? 16 : 32,
                            compact ? 20 : 48,
                            compact ? 16 : 28,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pixelarticons for Flutter',
                                style: TextStyle(
                                  fontSize: compact ? 30 : 56,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'A Flutter package that bundles the free Pixelarticons '
                                'icon set as an icon font. Use it with Flutter’s Icon widget.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF62695E),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Wrap(
                                spacing: 24,
                                runSpacing: 4,
                                children: [
                                  _ProjectLink(
                                    'pub.dev',
                                    'https://pub.dev/packages/pixelarticons',
                                  ),
                                  _ProjectLink(
                                    'Source code',
                                    'https://github.com/libsrcdev/pixelarticons',
                                  ),
                                  _ProjectLink(
                                    'Report an issue',
                                    'https://github.com/libsrcdev/pixelarticons/issues',
                                  ),
                                  _ProjectLink(
                                    'Original icon set',
                                    'https://github.com/halfmage/pixelarticons',
                                  ),
                                  _ProjectLink(
                                    'pixelarticons@libsrc.dev',
                                    'mailto:pixelarticons@libsrc.dev',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Wrap(
                                spacing: 24,
                                runSpacing: 4,
                                children: [
                                  _Credit(
                                    'Icon set by',
                                    'halfmage',
                                    'https://github.com/halfmage',
                                  ),
                                  _Credit(
                                    'Flutter library created by',
                                    'alexcastro.dev',
                                    'https://alexcastro.dev',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _NavigationHeader(
                      Theme.of(context).colorScheme.surface,
                      _tabs,
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabs,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [IconGallery(), DocumentationPage()],
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

class IconGallery extends StatefulWidget {
  const IconGallery({super.key});

  @override
  State<IconGallery> createState() => _IconGalleryState();
}

class _IconGalleryState extends State<IconGallery>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String _query = '';
  String? _category;
  IconStyle? _style;
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

  void _updateFilters(VoidCallback update) {
    setState(update);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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

    return CustomScrollView(
      key: const PageStorageKey('gallery'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search $count icons by name',
                prefixIcon: const Icon(Pixel.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onChanged: (value) => _updateFilters(() {
                _query = value.trim().toLowerCase();
              }),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
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
        ),
        SliverToBoxAdapter(
          child: SizedBox(
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
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text('$count of ${Pixel.allIcons.length} icons'),
            ),
          ),
        ),
        if (groups.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No icons found')),
          ),
        for (final group in groups.entries) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      group.key,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${group.value.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
      borderRadius: BorderRadius.circular(5),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Tooltip(
      message: 'Pixel.${icon.key}',
      child: InkWell(
        onTap: () => showIconDetails(context, icon),
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon.value, size: 32, semanticLabel: icon.key),
              const SizedBox(height: 12),
              SelectableText(
                icon.key,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NavigationHeader extends SliverPersistentHeaderDelegate {
  _NavigationHeader(this.color, this.controller);
  final Color color;
  final TabController controller;
  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(
    color: color,
    child: TabBar(
      controller: controller,
      onTap: (index) => context.go(index == 0 ? '/' : '/getting-started'),
      tabs: [
        for (final entry in {
          '/': 'Icon gallery',
          '/getting-started': 'Getting started',
        }.entries)
          Tab(
            child: Link(
              uri: Uri.parse(entry.key),
              builder: (context, followLink) => TextButton(
                onPressed: kIsWeb ? followLink : () => context.go(entry.key),
                child: Text(entry.value),
              ),
            ),
          ),
      ],
    ),
  );
  @override
  bool shouldRebuild(_NavigationHeader oldDelegate) =>
      oldDelegate.color != color || oldDelegate.controller != controller;
}

class _ProjectLink extends StatelessWidget {
  const _ProjectLink(this.label, this.url, {this.fontSize = 14});
  final String label;
  final String url;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    child: TextButton(
      onPressed: () => openExternalLink(context, Uri.parse(url)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        minimumSize: const Size(0, 40),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: fontSize,
          decoration: TextDecoration.underline,
        ),
      ),
      child: Text(label),
    ),
  );
}

class _Credit extends StatelessWidget {
  const _Credit(this.label, this.name, this.url);
  final String label;
  final String name;
  final String url;

  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 4,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      _ProjectLink(name, url),
    ],
  );
}
