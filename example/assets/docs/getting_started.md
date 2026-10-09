# Pixel art icons for Flutter

Use Pixel icons anywhere you use Flutter’s `Icon` widget. Browse the gallery to find an icon and its Dart name.

## 1. Install

Run this command in your Flutter project:

```shell
flutter pub add pixelarticons
```

## 2. Import

```dart
import 'package:pixelarticons/pixelarticons.dart';
```

## 3. Use an icon

Set the size and color just like any other Flutter icon.

```dart
Icon(
  Pixel.clock,
  size: 32,
  color: Colors.green,
)
```

## Icon names

Names are lowercase with no separators: `arrow-down` becomes `Pixel.arrowdown`. Names starting with a number or matching a Dart keyword have a `k` prefix.

```dart
Icon(Pixel.arrowdown)
Icon(Pixel.kswitch)
```

## Buttons and accessibility

Give icon-only buttons a tooltip that describes their action. Use `semanticLabel` when a standalone icon communicates meaning.

```dart
IconButton(
  icon: const Icon(Pixel.search),
  tooltip: 'Search',
  onPressed: () {
    // Open search.
  },
)
```

```dart
const Icon(Pixel.clock, semanticLabel: 'Time')
```

## Find the right style

The gallery lets you filter by category and style: **Default**, **Sharp**, **Solid**, or **Glyph**. Each tile shows the exact name to use with `Pixel`. Hover or long-press a tile to see its full reference.

## Updating your project

This release follows the current upstream icon set. Older icons and historical spelling aliases may have been removed. Use the gallery to find the current names, and keep `Pixel` references rather than storing numeric font codepoints.

---

## Links and credits

- [Package on pub.dev](https://pub.dev/packages/pixelarticons)
- [API reference](https://pub.dev/documentation/pixelarticons/latest/)
- [Flutter library source](https://github.com/libsrcdev/pixelarticons)
- [Report a library issue](https://github.com/libsrcdev/pixelarticons/issues)
- [Original icon set](https://github.com/halfmage/pixelarticons)

Icon set by [halfmage](https://github.com/halfmage). Flutter library created by [alexcastro.dev](https://alexcastro.dev). A [libsrc.dev](https://libsrc.dev) project.

- Project contact: [pixelarticons@libsrc.dev](mailto:pixelarticons@libsrc.dev)
- Personal contact: [contact@alexcastro.dev](mailto:contact@alexcastro.dev)

The Flutter library is available under the [MIT license](https://github.com/libsrcdev/pixelarticons/blob/main/LICENSE).
