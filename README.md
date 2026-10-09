# Pixel Art Icons package for Flutter

<a href="https://pub.dev/packages/pixelarticons"><img src="https://img.shields.io/pub/v/pixelarticons.svg" /></a>

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

You can check the latest version on [pub.dev/pixelarticons](https://pub.dev/packages/pixelarticons).

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

- **Lower-case for all icons and no separators**, for example `arrow-down` is written as `Pixel.arrowdown`.
- Names starting with numbers and Dart keywords get a `k` prefix.

Icon full list https://pixelarticons.com/free/.

```dart
Icon(Pixel.android);
Icon(Pixel.clock);
Icon(Pixel.arrowdown);
```

---

## Develop locally

Use Dart 3.8+ and Flutter 3.32+ for the package. Development of the example
and locked release tool uses Flutter 3.47+ / Dart 3.13+. Android also requires
JDK 17.

The font and generated `Pixel` class are committed, so a fresh checkout works
without downloading upstream icons or running the generator:

```shell
flutter pub get
flutter analyze
flutter test
cd example
flutter run -d chrome
```

The example also supports Android (`flutter run` with an Android device).

Development shortcuts use `rps` from the package's dev dependencies:

```shell
dart run rps format
dart run rps analyze
dart run rps test
dart run rps example -d chrome
dart run rps build web
dart run rps tool analyze
dart run rps tool test
dart run rps sync --dry-run
```

## Sync and generate icons

Automation lives in `tool/`, a standalone Dart package. Run its commands from
that directory so Dart resolves the tool's own dependencies:

```shell
cd tool
npm ci
dart pub get
dart run bin/pixelarticons_tool.dart --project-root .. --dry-run
dart run bin/pixelarticons_tool.dart --project-root ..
```

A sync fetches the current upstream commit, downloads that exact revision,
extracts the free SVGs, and generates both `fonts/pixelarticons.ttf` and
`lib/pixel.dart`. Font conversion uses the npm package
[`svgtofont`](https://github.com/jaywcjlove/svgtofont). Node.js 22 or newer and
`npm ci` in `tool/` are required for generation. All icons retain their 24×24
grid and lowercase Dart names, including keyword and numeric prefixes.
Codepoints are assigned explicitly in sorted Dart-name order, starting at E000.
Paper.js parses SVG paths and Clipper unions their filled contours before
`svgtofont` conversion, preserving touching edges, overlapping shapes, and
intentional holes. Each element’s fill rule is resolved before combining it
with other elements. Only temporary generation copies are flattened. The current upstream sources contain
untransformed straight paths; unsupported elements or curves cause generation
to fail explicitly.


This breaking release uses only the current upstream icon set. Removed v1
icons and historical spelling aliases are no longer available. Update your
`Pixel` references to names in the current icon set.

Glyph codepoints may change on regeneration; always use `Pixel` constants
with the matching bundled font rather than storing numeric codepoints.

`--no-cache` rebuilds even when the upstream commit matches, without bumping the
version or adding a duplicate changelog entry. `--force-release` explicitly
bumps the version for a release without upstream changes. `--dry-run` does not
modify the project.

```shell
# From tool/
dart run bin/pixelarticons_tool.dart --project-root .. --no-cache
dart analyze
dart test
cd ..
dart format lib test tool/lib tool/bin tool/test example/lib
flutter analyze
flutter test
cd example
flutter build web
```

## Compare every SVG against the font

Download the exact SVG revision pinned in `pubspec.yaml`, then render every SVG
independently with `flutter_svg` and every bundled glyph with Flutter's `Icon`:

```shell
flutter pub get
dart run rps sources
dart run rps pixels
```

The comparison renders on a fixed 240×240 transparent canvas with white fills,
then checks the painted/empty state at the center of each cell in the original
24×24 grid (alpha ≥ 128 means painted). It fails if any of the 576 cells differs.
Sampling cell centers avoids antialiasing at grid edges while still detecting
missing fills, extra fills, holes, and shifts that change cell occupancy. This
checks pixel art cell occupancy, not exact outlines or subcell details. No
alignment correction or image resizing is applied after rendering. SVG names
and font names must match completely.

Results are saved in `build/icon-comparison/report.json`, including zero-based
coordinates and painted states for every mismatched cell. Open
`build/icon-comparison/index.html` for a searchable visual report. Grid images
show binary occupancy; red marks cells missing in the font and blue marks extra
cells. The report also retains exact raster differences as diagnostics; enable
“Show icons with raster differences too” to inspect them. Those differences do
not fail the grid comparison.

Sources are downloaded without changing the font, generated class, version, or
changelog. This explicit diagnostic is separate from the ordinary `flutter test`
suite so a fresh checkout needs no upstream download.
The manual **Compare SVGs and font grid** GitHub Actions workflow runs the same
check and uploads the report even when differences make the check fail.

## CI and publishing

To release manually, open **GitHub → Actions → Update icons and publish release →
Run workflow**. Select the release branch and click **Run workflow**. By default,
this checks upstream, downloads the current icons, regenerates the font and
class, bumps the version, updates the changelog, runs validation, and pushes the
commit and version tag together. The tag then starts **Publish package to
pub.dev** automatically. Follow that second workflow to confirm publication.

Manual runs always create a new version, even when upstream icons are unchanged.
Scheduled runs on the 1st and 15th only release when upstream changes are found.

One-time setup: add the repository secret `TAG_PAT` with permission to write
repository contents, and enable automated publishing on pub.dev for
`libsrcdev/pixelarticons` with tag pattern `v{{version}}`. The release token must
be authorized by any repository rules that restrict branch or tag pushes.

- `validate.yml` analyzes and tests the tool and package, checks formatting, and builds
  the web example on pushes and pull requests.
- `sync-upstream-icons.yml` checks upstream on the 1st and 15th of each month or on manual
  dispatch, generates and validates artifacts, then commits and tags a release.
  Set the repository's `TAG_PAT` secret to a token authorized to push commits
  and tags; this allows the tag push to trigger the release workflow.
- `publish-pubdev.yml` validates and publishes tagged releases using pub.dev OIDC
  automated publishing. Configure the trusted GitHub repository and tag pattern
  in the pub.dev package's automated publishing settings.

## Remote issues addressed

- [#5: solid clock](https://github.com/libsrcdev/pixelarticons/issues/5): the current
  path-based clock is bundled, with a raster test verifying its hollow interior
  and visible outline.
- [#6: new icons](https://github.com/libsrcdev/pixelarticons/issues/6): the generated
  package includes 1,036 current free upstream icons. Paid upstream icons are not distributed here.

## Contribute

Use the issues tab to discuss new features and bug reports.
