import 'package:example/icon_categories.dart';
import 'package:example/documentation.dart';
import 'package:example/icon_details.dart';
import 'package:example/main.dart';
import 'package:example/icon_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelarticons/pixelarticons.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    final loader = FontLoader('Share Tech')
      ..addFont(rootBundle.load('assets/fonts/share-tech-regular.ttf'));
    await loader.load();
    await (FontLoader('JetBrains Mono')
          ..addFont(rootBundle.load('assets/fonts/JetBrainsMono-Regular.ttf')))
        .load();
  });
  tearDown(
    () => TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .clearAccessibilityFeaturesTestValue(),
  );
  testWidgets(
    'header links and credits open once per click, including repeats',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      final opened = <String>[];
      var fail = false;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        if (call.method == 'launch') {
          if (fail) throw PlatformException(code: 'launch_failed');
          opened.add((call.arguments as Map)['url'] as String);
          return true;
        }
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      await tester.pumpWidget(const PixelArtIconsExample(initialLocation: '/'));
      final links = {
        'libsrc.dev': 'https://libsrc.dev',
        'pub.dev': 'https://pub.dev/packages/pixelarticons',
        'Source code': 'https://github.com/libsrcdev/pixelarticons',
        'Report an issue': 'https://github.com/libsrcdev/pixelarticons/issues',
        'Original icon set': 'https://github.com/halfmage/pixelarticons',
        'pixelarticons@libsrc.dev': 'mailto:pixelarticons@libsrc.dev',
        'halfmage': 'https://github.com/halfmage',
        'alexcastro.dev': 'https://alexcastro.dev',
      };
      for (var repetition = 0; repetition < 3; repetition++) {
        for (final link in links.entries) {
          await tester.tap(find.text(link.key));
          await tester.pump();
          expect(opened.last, link.value);
        }
      }
      expect(opened, [...links.values, ...links.values, ...links.values]);
      ScaffoldMessenger.of(tester.element(find.text('pub.dev')))
          .clearSnackBars();
      await tester.pumpAndSettle();
      fail = true;
      await tester.tap(find.text('pub.dev'));
      await tester.pumpAndSettle();
      expect(find.text('Could not open the link.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'getting started opens directly and browser route changes select the page',
    (tester) async {
      await tester.runAsync(loadDocumentation);
      await tester.pumpWidget(
        const PixelArtIconsExample(initialLocation: '/getting-started'),
      );
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('flutter pub add pixelarticons'), findsOneWidget);
      final importSnippet = tester.widget<SelectableText>(
        find.ancestor(
          of: find.text("import 'package:pixelarticons/pixelarticons.dart';"),
          matching: find.byType(SelectableText),
        ),
      );
      expect(
        importSnippet.textSpan!.children!.whereType<TextSpan>().any(
          (span) => span.style?.color != null,
        ),
        isTrue,
      );
      final router = GoRouter.of(tester.element(find.text('Getting started')));
      expect(
        router.routeInformationProvider.value.uri.path,
        '/getting-started',
      );
      await tester.tap(find.text('Icon gallery'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(find.byType(TextField), findsOneWidget);
      await tester.binding.handlePushRoute('/getting-started');
      await tester.pumpAndSettle();
      expect(find.text('flutter pub add pixelarticons'), findsOneWidget);
    },
  );
  testWidgets(
    'docs are readable on mobile and gallery filters survive navigation',
    (tester) async {
      await tester.runAsync(loadDocumentation);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const PixelArtIconsExample(initialLocation: '/'));
      await tester.enterText(find.byType(TextField), 'clock');
      await tester.tap(find.text('Getting started'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('flutter pub add pixelarticons'), findsOneWidget);
      expect(
        find.text("import 'package:pixelarticons/pixelarticons.dart';"),
        findsOneWidget,
      );
      await tester.drag(
        find.byKey(const PageStorageKey('documentation')),
        const Offset(0, -1600),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Icon gallery'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(Tooltip, 'clock'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('icon details show code and copy the name and original SVG', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final vectors = (await tester.runAsync(loadIconVectors))!;
    expect(vectors.keys.toSet(), Pixel.allIcons.keys.toSet());
    await tester.pumpWidget(const PixelArtIconsExample(initialLocation: '/'));
    await tester.enterText(find.byType(TextField), 'clock');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(SelectableText, 'clock'), findsOneWidget);
    final clockIcon = find.byWidgetPredicate(
      (widget) => widget is Icon && widget.icon == Pixel.clock,
    );
    await tester.ensureVisible(clockIcon);
    await tester.tap(clockIcon);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(find.text('Pixel.clock'), findsOneWidget);
    expect(find.text('Icon(Pixel.clock, size: 32)'), findsOneWidget);
    await tester.tap(find.text('Copy name'));
    await tester.pumpAndSettle();
    expect(copied, 'clock');
    await tester.ensureVisible(find.text('Copy SVG'));
    await tester.tap(find.text('Copy SVG'));
    await tester.pumpAndSettle();
    expect(copied, vectors['clock']);
    expect(copied, contains('<svg'));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Close icon details'));
    await tester.pumpAndSettle();
    expect(find.text('Pixel.clock'), findsNothing);
  });
  test('every icon has a category and variants stay together', () {
    for (final name in Pixel.allIcons.keys) {
      expect(iconCategories.keys, contains(categoryForIcon(name)));
    }
    expect(categoryForIcon('androidsolid'), 'Brands');
    expect(categoryForIcon('arrowdownboxsharp'), 'Arrows & navigation');
    expect(categoryForIcon('cloudserver'), 'Technology & code');
    expect(categoryForIcon('clock'), 'Time & calendars');
    expect(categoryForIcon('futureunknownicon'), 'Interface & controls');
  });

  testWidgets('search shows matching sections and an empty state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const PixelArtIconsExample(initialLocation: '/'));
    expect(
      find.text('${Pixel.allIcons.length} of ${Pixel.allIcons.length} icons'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'clock');
    await tester.pumpAndSettle();
    expect(find.text('Time & calendars'), findsWidgets);
    expect(find.widgetWithText(Tooltip, 'clock'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no-such-icon');
    await tester.pumpAndSettle();
    expect(find.text('No icons found'), findsOneWidget);
    expect(find.text('0 of ${Pixel.allIcons.length} icons'), findsOneWidget);
  });
  test('style classification follows icon suffixes', () {
    expect(styleForIcon('arrowup'), IconStyle.regular);
    expect(styleForIcon('arrowupsharp'), IconStyle.sharp);
    expect(styleForIcon('androidsolid'), IconStyle.solid);
    expect(styleForIcon('refreshglyph'), IconStyle.glyph);
  });

  testWidgets('style, category and name filters combine and reset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const PixelArtIconsExample(initialLocation: '/'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Brands'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Solid'));
    await tester.enterText(find.byType(TextField), 'android');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(Tooltip, 'androidsolid'), findsOneWidget);
    expect(find.widgetWithText(Tooltip, 'android'), findsNothing);
    expect(find.text('1 of ${Pixel.allIcons.length} icons'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Default'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(Tooltip, 'android'), findsOneWidget);
    expect(find.widgetWithText(Tooltip, 'androidsolid'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Sharp'));
    await tester.pumpAndSettle();
    expect(find.text('No icons found'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'All styles'));
    await tester.pumpAndSettle();
    expect(find.text('2 of ${Pixel.allIcons.length} icons'), findsOneWidget);
  });
}
