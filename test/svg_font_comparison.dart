import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelarticons/pixelarticons.dart';

// Explicitly run via `dart run rps pixels`; regular tests need no download.
const _gridSize = 24;
const _cellSize = 10;
const _size = _gridSize * _cellSize;
const _outputPath = 'build/icon-comparison';

void main() {
  testWidgets('every SVG matches its Flutter font glyph on the pixel art grid', (
    tester,
  ) async {
    final sources = Directory('release/svg');
    expect(
      sources.existsSync(),
      isTrue,
      reason: 'Run dart run rps sources before the pixel comparison.',
    );
    final pinned = RegExp(
      r'^pixelarticons_commit: (.+)$',
      multiLine: true,
    ).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1)!;
    expect(
      File('release/source_commit.txt').readAsStringSync().trim(),
      pinned,
      reason: 'Source SVG revision must match the bundled font.',
    );
    final files =
        sources
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.svg'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    final mapped = <String, File>{};
    for (final file in files) {
      final stem = file.uri.pathSegments.last
          .replaceFirst(RegExp(r'\.svg$'), '')
          .replaceAll(RegExp('[^a-zA-Z0-9]'), '')
          .toLowerCase();
      final name = Pixel.allIcons.containsKey(stem) ? stem : 'k$stem';
      expect(
        mapped.containsKey(name),
        isFalse,
        reason: 'Duplicate source: $name',
      );
      mapped[name] = file;
    }
    expect(
      mapped.keys.toSet(),
      Pixel.allIcons.keys.toSet(),
      reason: 'Compare every SVG and every icon, without omissions.',
    );
    final output = Directory(_outputPath);
    if (output.existsSync()) output.deleteSync(recursive: true);
    output.createSync(recursive: true);
    final loader = FontLoader('packages/pixelarticons/Pixel Art Icons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('fonts/pixelarticons.ttf').readAsBytesSync(),
          ),
        ),
      );
    await tester.runAsync(loader.load);
    final results = <Map<String, Object>>[];
    final failures = <String>[];
    var index = 0;
    for (final entry in mapped.entries) {
      final source = entry.value.readAsStringSync();
      final svgImage = (await tester.runAsync(() async {
        final info = await vg.loadPicture(
          SvgStringLoader(
            source,
            theme: const SvgTheme(currentColor: Colors.white),
          ),
          null,
        );
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.scale(_size / info.size.width, _size / info.size.height);
        canvas.drawPicture(info.picture);
        final picture = recorder.endRecording();
        final image = await picture.toImage(_size, _size);
        picture.dispose();
        info.picture.dispose();
        return image;
      }))!;
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: Icon(
                Pixel.allIcons[entry.key],
                size: _size.toDouble(),
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final fontImage = (await tester.runAsync(
        () => boundary.toImage(pixelRatio: 1),
      ))!;
      final reference = (await tester.runAsync(
        () => svgImage.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;
      final actual = (await tester.runAsync(
        () => fontImage.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;
      expect(fontImage.width, _size);
      expect(fontImage.height, _size);
      final diff = Uint8List(_size * _size * 4);
      var different = 0;
      var shapeErrors = 0;
      var maxDelta = 0;
      for (var pixel = 0; pixel < _size * _size; pixel++) {
        // White on transparent: alpha is the complete visible pixel coverage.
        final a = reference.getUint8(pixel * 4 + 3);
        final b = actual.getUint8(pixel * 4 + 3);
        final delta = (a - b).abs();
        if (delta == 0) continue;
        different++;
        if (delta > maxDelta) maxDelta = delta;
        // Compare filled/empty silhouettes separately from antialias coverage.
        final edgeOnly = (a >= 128) == (b >= 128);
        if (!edgeOnly) shapeErrors++;
        diff[pixel * 4] = edgeOnly ? 255 : 240;
        diff[pixel * 4 + 1] = edgeOnly ? 180 : 0;
        diff[pixel * 4 + 3] = 255;
      }
      // Sample the center of each original SVG pixel, away from raster edges.
      // Coordinates remain fixed: a shifted or missing cell must fail.
      final svgGrid = Uint8List(_size * _size * 4);
      final fontGrid = Uint8List(_size * _size * 4);
      final gridDiff = Uint8List(_size * _size * 4);
      final mismatchedCells = <Map<String, Object>>[];
      for (var y = 0; y < _gridSize; y++) {
        for (var x = 0; x < _gridSize; x++) {
          final offset =
              ((y * _cellSize + _cellSize ~/ 2) * _size +
                      x * _cellSize +
                      _cellSize ~/ 2) *
                  4 +
              3;
          final svgPainted = reference.getUint8(offset) >= 128;
          final fontPainted = actual.getUint8(offset) >= 128;
          if (svgPainted) _paintCell(svgGrid, x, y, 255, 255, 255);
          if (fontPainted) _paintCell(fontGrid, x, y, 255, 255, 255);
          if (svgPainted != fontPainted) {
            mismatchedCells.add({
              'x': x,
              'y': y,
              'svgPainted': svgPainted,
              'fontPainted': fontPainted,
            });
            _paintCell(
              gridDiff,
              x,
              y,
              svgPainted ? 240 : 0,
              svgPainted ? 0 : 180,
              svgPainted ? 0 : 255,
            );
          }
        }
      }
      final failed = mismatchedCells.isNotEmpty;
      if (failed) failures.add(entry.key);
      results.add({
        'icon': entry.key,
        'gridMismatchCount': mismatchedCells.length,
        'mismatchedCells': mismatchedCells,
        'differentPixels': different,
        'shapeErrorPixels': shapeErrors,
        'maxAlphaDelta': maxDelta,
        'exactMatch': different == 0,
        'passed': !failed,
      });
      if (different > 0 || failed) {
        final dir = Directory('$_outputPath/${entry.key}')..createSync();
        await tester.runAsync(() async {
          for (final imageEntry in {
            'svg': svgImage,
            'font': fontImage,
          }.entries) {
            final png = (await imageEntry.value.toByteData(
              format: ui.ImageByteFormat.png,
            ))!;
            File(
              '${dir.path}/${imageEntry.key}.png',
            ).writeAsBytesSync(png.buffer.asUint8List());
          }
          for (final imageEntry in {
            'diff': diff,
            'svg-grid': svgGrid,
            'font-grid': fontGrid,
            'grid-diff': gridDiff,
          }.entries) {
            final image = await _imageFromPixels(imageEntry.value);
            final png = (await image.toByteData(
              format: ui.ImageByteFormat.png,
            ))!;
            File(
              '${dir.path}/${imageEntry.key}.png',
            ).writeAsBytesSync(png.buffer.asUint8List());
            image.dispose();
          }
        });
      }
      svgImage.dispose();
      fontImage.dispose();
      if (++index % 100 == 0) {
        debugPrint('Compared $index/${mapped.length} icons');
      }
    }
    File('$_outputPath/report.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'sourceCommit': pinned,
        'resolution': _size,
        'comparison': 'grid-cell-centers',
        'gridSize': _gridSize,
        'alphaThreshold': 128,
        'gridMatches': results.where((r) => r['passed'] == true).length,
        'total': results.length,
        'failed': failures.length,
        'exactMatches': results.where((r) => r['exactMatch'] == true).length,
        'results': results,
      }),
    );
    debugPrint(
      'Compared ${results.length} icons; ${failures.length} failures. Report: $_outputPath/report.json',
    );
    File('$_outputPath/index.html').writeAsStringSync(_reportHtml(results));
    expect(
      failures,
      isEmpty,
      reason:
          'SVG/font grid differences: ${failures.take(20).join(', ')}. See $_outputPath for PNGs and report.',
    );
  }, timeout: const Timeout(Duration(minutes: 10)));
}

void _paintCell(Uint8List pixels, int x, int y, int r, int g, int b) {
  for (var dy = 0; dy < _cellSize; dy++) {
    for (var dx = 0; dx < _cellSize; dx++) {
      final offset = ((y * _cellSize + dy) * _size + x * _cellSize + dx) * 4;
      pixels[offset] = r;
      pixels[offset + 1] = g;
      pixels[offset + 2] = b;
      pixels[offset + 3] = 255;
    }
  }
}

Future<ui.Image> _imageFromPixels(Uint8List pixels) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
  final descriptor = ui.ImageDescriptor.raw(
    buffer,
    width: _size,
    height: _size,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final codec = await descriptor.instantiateCodec();
  final image = (await codec.getNextFrame()).image;
  codec.dispose();
  descriptor.dispose();
  buffer.dispose();
  return image;
}

String _reportHtml(List<Map<String, Object>> results) =>
    '''<!doctype html>
<html lang="en"><meta charset="utf-8"><title>SVG / font pixel comparison</title>
<style>
body{font:16px system-ui;margin:32px;background:#f6f6f6;color:#222}
input[type=text],#search{padding:12px;width:280px}article{background:white;padding:20px;margin:20px 0;border-radius:12px}
.images{display:flex;gap:20px;flex-wrap:wrap}figure{margin:0}img{background:#222;width:240px;height:240px;image-rendering:pixelated}figcaption{padding:8px 0}
</style><h1>SVG / font comparison</h1>
<p>24 × 24 grid. Each cell is painted when its center has alpha ≥ 128. Red grid cells: missing in font. Blue: extra in font. Raster differences are diagnostic only.</p>
<label><input type="checkbox" id="raster"> Show icons with raster differences too</label><br><input id="search" placeholder="Filter by icon name" aria-label="Filter icons"><p id="count"></p><main id="results"></main>
<script>
const icons = ${jsonEncode(results)};
const search = document.getElementById('search');
function render(){
 const matches=icons.filter(i=>(!i.passed || (document.getElementById('raster').checked && !i.exactMatch)) && i.icon.includes(search.value.trim().toLowerCase()));
 document.getElementById('count').textContent=icons.filter(i=>i.passed).length+' / '+icons.length+' icons match the grid; showing '+matches.length+' icons';
 document.getElementById('results').innerHTML=matches.map(i=>`<article><h2>\${i.icon}</h2><p>\${i.gridMismatchCount} mismatched grid cells; \${i.differentPixels} differing raster pixels; \${i.shapeErrorPixels} silhouette pixels; maximum alpha difference \${i.maxAlphaDelta}/255.</p><div class="images">\${['svg-grid','font-grid','grid-diff','svg','font','diff'].map(type=>`<figure><img loading="lazy" src="\${i.icon}/\${type}.png" alt="\${type} rendering of \${i.icon}"><figcaption>\${type}</figcaption></figure>`).join('')}</div></article>`).join('');
}
search.addEventListener('input',render);document.getElementById('raster').addEventListener('change',render);render();
</script></html>''';
