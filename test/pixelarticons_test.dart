import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelarticons/pixelarticons.dart';

void main() {
  test('icons resolve the packaged font', () {
    for (final icon in [
      Pixel.android,
      Pixel.clock,
      Pixel.article,
      Pixel.arrowdown,
    ]) {
      expect(icon.fontFamily, 'Pixel Art Icons');
      expect(icon.fontPackage, 'pixelarticons');
    }
    expect(File('fonts/pixelarticons.ttf').lengthSync(), greaterThan(1000));
  });

  testWidgets('clock has a transparent interior and visible outline', (
    tester,
  ) async {
    final loader = FontLoader('packages/pixelarticons/Pixel Art Icons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('fonts/pixelarticons.ttf').readAsBytesSync(),
          ),
        ),
      );
    await tester.runAsync(loader.load);
    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: key,
            child: const Icon(Pixel.clock, size: 240, color: Colors.white),
          ),
        ),
      ),
    );
    await tester.pump();
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = (await tester.runAsync(boundary.toImage))!;
    final data = (await tester.runAsync(
      () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
    ))!;
    int alpha(int x, int y) => data.getUint8((y * image.width + x) * 4 + 3);
    expect(alpha(80, 80), 0, reason: 'The clock interior must stay hollow');
    expect(alpha(30, 100), greaterThan(0), reason: 'The outline must render');
    image.dispose();
  });
  testWidgets('arrow heads render as solid symmetric pixel steps', (
    tester,
  ) async {
    final loader = FontLoader('packages/pixelarticons/Pixel Art Icons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('fonts/pixelarticons.ttf').readAsBytesSync(),
          ),
        ),
      );
    await tester.runAsync(loader.load);
    for (final icon in [Pixel.arrowup, Pixel.arrowright, Pixel.arrowleft]) {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: Icon(icon, size: 240, color: Colors.white),
            ),
          ),
        ),
      );
      await tester.pump();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = (await tester.runAsync(boundary.toImage))!;
      final data = (await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;
      // Sample every SVG grid cell at its center, away from antialiased edges.
      for (var y = 0; y < 24; y++) {
        for (var x = 0; x < 24; x++) {
          var sourceX = x;
          var sourceY = y;
          if (icon == Pixel.arrowright) {
            sourceX = y;
            sourceY = 23 - x;
          } else if (icon == Pixel.arrowleft) {
            sourceX = y;
            sourceY = x;
          }
          final shaft =
              sourceX >= 11 && sourceX < 13 && sourceY >= 4 && sourceY < 20;
          final head =
              sourceY >= 6 &&
              sourceY < 12 &&
              sourceX >= 11 - 2 * ((sourceY - 4) ~/ 2) &&
              sourceX < 13 + 2 * ((sourceY - 4) ~/ 2);
          final alpha = data.getUint8(
            ((y * 10 + 5) * image.width + x * 10 + 5) * 4 + 3,
          );
          expect(
            alpha > 127,
            shaft || head,
            reason:
                'Arrow ${icon.codePoint}: SVG cell ($x, $y) must match its filled silhouette',
          );
        }
      }
      image.dispose();
    }
  });
}
