import 'package:example/icon_categories.dart';
import 'package:example/main.dart';
import 'package:example/icon_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelarticons/pixelarticons.dart';

void main() {
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
    await tester.pumpWidget(const PixelArtIconsExample());
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
    await tester.pumpWidget(const PixelArtIconsExample());
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
