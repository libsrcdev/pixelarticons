# Pixel Art Icons package for Flutter

<a href="https://pub.dartlang.org/packages/pixelarticons"><img src="https://img.shields.io/pub/v/pixelarticons.svg" /></a>

This package provides a set of pixel art icons as font for Flutter, it can be used in the same way we use `Icons` class.

- See all available icons at https://pixelarticons.com/free/.
- Get the Figma file at https://www.figma.com/community/file/952542622393317653.

Icon set created by [@halfmage](https://github.com/halfmage), if you like this free icon set you will also like the [premium ones](https://halfmage.gumroad.com/).

<details>
  <summary>Show preview</summary>

![Pixelarticons - Frame](https://user-images.githubusercontent.com/51419598/220436077-1a1bd414-5f5c-42c6-a283-d6bc16be5259.png#gh-dark-mode-only)
![Pixelarticons - Frame](https://user-images.githubusercontent.com/51419598/220445395-9118b275-6c62-4552-95fe-27730c656d0d.png#gh-light-mode-only)

</details>

## Install the package

You can check the latest version on [pub.dev/pixelarticons](https://pub.dartlang.org/packages/pixelarticons).

```yaml
dependencies:
  # ...
  pixelarticons: <latest-version>
  # ...
```

or run:

```shell
flutter pub add pixelarticons
```

## Import the package

Import wherever you want:

```dart
import 'package:pixelarticons/pixelarticons.dart';
```

## Use as `IconData`

`pixelarticons` package uses the `IconData` class, so the usage is pretty much the same of the `Icons` class but renamed to `Pixel`.

Be aware:

- **Lower-case for all icons and no separators**, for example `card-plus` is written as `Pixel.cardplus`.
- Icons that **starts with non-alpha characters**, like `4k`, `4k-box`, `4g` are prefixed with `k`.
- Icons that are Dart keywords, like `switch` are prefix with `k` as well.

So use `k4k`, `k4kbox`, `kswitch` instead.

Icon full list https://pixelarticons.com/free/.

```dart
/// 4k icon:
Icon(Pixel.k4k)

/// switch icon:
Icon(Pixel.kswitch)

/// align-left icon:
Icon(Pixel.alignleft);
```

---

## How it works

This library automatically syncs with the [pixelarticons](https://github.com/halfmage/pixelarticons) repository, generates a font, and publishes to pub.dev.

### Automation tool

All automation lives in [`tool/`](tool/), a standalone Dart CLI:

```shell
# Check for upstream changes (dry run)
dart run tool/bin/pixelarticons_tool.dart --dry-run

# Download and process SVGs
dart run tool/bin/pixelarticons_tool.dart

# Force re-download even if up to date
dart run tool/bin/pixelarticons_tool.dart --no-cache
```

The tool:

1. Fetches the latest commit hash from [`halfmage/pixelarticons`](https://github.com/halfmage/pixelarticons) master branch
2. Compares it with the `pixelarticons_commit` key in `pubspec.yaml`
3. If there's a new commit: downloads the repo zipball, extracts SVGs, applies Dart naming conventions (prefixing keywords and numeric names with `k`), and places them in `release/svg/`
4. Bumps the package version and updates `CHANGELOG.md`

### Font generation

After the tool runs, [fontify](https://pub.dev/packages/fontify) generates the icon font and Dart class from the SVGs:

```shell
dart pub global activate fontify
dart pub global run fontify
```

This reads from `release/svg/` and generates:

- `fonts/pixelarticons.otf` — the icon font
- `lib/pixel.dart` — the Dart class with `IconData` constants

The fontify configuration is in `pubspec.yaml` under the `fontify:` key.

### CI/CD

Two GitHub Actions workflows handle the automation:

- **[`publish.yml`](.github/workflows/publish.yml)** — runs on cron (1st and 15th of each month) or manual dispatch. Checks for upstream changes, downloads SVGs, generates the font, commits, and pushes a version tag.
- **[`release.yml`](.github/workflows/release.yml)** — triggered by the version tag push, publishes to pub.dev using [OIDC automated publishing](https://dart.dev/tools/pub/automated-publishing).

### Run locally

Required: [Dart SDK](https://dart.dev/get-dart) (>= 3.0.0) and [Flutter SDK](https://docs.flutter.dev/get-started/install).

```shell
# Install tool dependencies
cd tool && dart pub get && cd ..

# Run the tool
dart run tool/bin/pixelarticons_tool.dart --no-cache

# Generate font
dart pub global activate fontify
dart pub global run fontify

# Format
dart format .
```

### Run tests

```shell
cd tool && dart pub get && dart test
```

## Contribute

Use the issues tab to discuss new features and bug reports.
