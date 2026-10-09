import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A sparse Life field painted inside the scrolling hero, behind its content.
class LifeBackground extends StatefulWidget {
  const LifeBackground({super.key});
  @override
  State<LifeBackground> createState() => _LifeBackgroundState();
}

class _LifeBackgroundState extends State<LifeBackground> {
  static const columns = 80;
  static const rows = 24;
  Set<int> _cells = _seed();
  Timer? _timer;
  var _generation = 0;

  static Set<int> _seed() => {
    for (final origin in [8, 30, 56, 70])
      for (final offset in [
        1,
        columns + 2,
        columns * 2,
        columns * 2 + 1,
        columns * 2 + 2,
      ])
        origin + columns * (origin % 9 + 2) + offset,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    if (!MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled) {
      _timer = Timer.periodic(
        const Duration(milliseconds: 700),
        (_) => _step(),
      );
    }
  }

  void _step() {
    final next = <int>{};
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        var neighbors = 0;
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            if (_cells.contains(
              ((y + dy + rows) % rows) * columns + (x + dx + columns) % columns,
            )) {
              neighbors++;
            }
          }
        }
        final cell = y * columns + x;
        if (neighbors == 3 || (neighbors == 2 && _cells.contains(cell))) {
          next.add(cell);
        }
      }
    }
    setState(() => _cells = ++_generation % 120 == 0 ? _seed() : next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: RepaintBoundary(child: CustomPaint(painter: _LifePainter(_cells))),
    ),
  );
}

class _LifePainter extends CustomPainter {
  const _LifePainter(this.cells);
  final Set<int> cells;
  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = math
        .min(
          size.width / _LifeBackgroundState.columns,
          size.height / _LifeBackgroundState.rows,
        )
        .clamp(2.0, 8.0);
    final paint = Paint()
      ..color = const Color(0xFF385A33).withValues(alpha: 0.055);
    for (final cell in cells) {
      final x =
          (cell % _LifeBackgroundState.columns) *
          size.width /
          _LifeBackgroundState.columns;
      final y =
          (cell ~/ _LifeBackgroundState.columns) *
          size.height /
          _LifeBackgroundState.rows;
      if (x < size.width && y < size.height) {
        canvas.drawRect(Rect.fromLTWH(x, y, cellSize - 1, cellSize - 1), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_LifePainter oldDelegate) => oldDelegate.cells != cells;
}
