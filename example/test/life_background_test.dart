import 'package:example/life_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final reducedMotion in [false, true]) {
    testWidgets(
      'Life ${reducedMotion ? 'stays still for reduced motion' : 'evolves and stops when removed'}',
      (tester) async {
        tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: reducedMotion);
        addTearDown(
          tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        await tester.pumpWidget(
          const MaterialApp(
            home: SizedBox(width: 960, height: 288, child: LifeBackground()),
          ),
        );
        final paint = find.descendant(
          of: find.byType(LifeBackground),
          matching: find.byType(CustomPaint),
        );
        final before = tester.widget<CustomPaint>(paint).painter;
        await tester.pump(const Duration(milliseconds: 700));
        final after = tester.widget<CustomPaint>(paint).painter;
        expect(identical(before, after), reducedMotion);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
