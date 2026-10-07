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
    expect(File('fonts/pixelarticons.otf').lengthSync(), greaterThan(1000));
  });

  testWidgets('clock has a transparent interior and visible outline', (
    tester,
  ) async {
    final loader = FontLoader('packages/pixelarticons/Pixel Art Icons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('fonts/pixelarticons.otf').readAsBytesSync(),
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
}
