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

## Purpose of this library

The process of including svgs as icons in Flutter is really boring:

1. Convert svg to font, you can choose a [raw method](https://stackoverflow.com/questions/13278707/how-can-i-convert-svg-files-to-a-font) for instance.
2. Import the icon font in the Flutter assets.
3. Create a class mapping each font charcode to a named static field.
4. Then you are (probably) ready to use your svgs as icons.

This library automates this process for [pixel art icons](https://pixelarticons.com/).

## Contribute

Use the issues tab to discuss new features and bug reports.

## How it works

First we check [if there's a new update available](https://github.com/alexcmgit/pixelarticons/blob/main/autoupdate/lib/has_new_release.dart) from the [pixel art icons repository](https://github.com/halfmage/pixelarticons):

https://github.com/alexcmgit/pixelarticons/blob/96354a3b1e067484c743e016282c38ef6b03cf57/autoupdate/lib/has_new_release.dart#L8-L10

We use a [custom key in the `pubspec.yaml`](https://github.com/alexcmgit/pixelarticons/blob/96354a3b1e067484c743e016282c38ef6b03cf57/pubspec.yaml#L5) file to compare the current published version of pixel art icons with the latest repository pixel art icons version.

If there is no update available, ignore it:

https://github.com/alexcmgit/pixelarticons/blob/96354a3b1e067484c743e016282c38ef6b03cf57/.github/workflows/flow.yaml#L12-L31

Otherwise, update the `pubspec.yaml` with the latest pixel art icons repository version and push the new commit:

https://github.com/alexcmgit/pixelarticons/blob/cfc1919b7f23203ba40fb3ab69b859226e8ed9e0/.github/workflows/flow.yaml#L40-L53

Now that we are up-to-date with the latest repository version in theory (since we just updated the version info), lets actually download the pixel art icons svgs, generate the font and the Dart font class:

https://github.com/alexcmgit/pixelarticons/blob/cfc1919b7f23203ba40fb3ab69b859226e8ed9e0/.github/workflows/flow.yaml#L55-L65

Note that the fontify library knows how to find the files because we defined the configuration in the `pubspec.yaml`:

https://github.com/alexcmgit/pixelarticons/blob/96354a3b1e067484c743e016282c38ef6b03cf57/pubspec.yaml#L29-L43

Now, the package is ready to be published, so we do it right after:

https://github.com/alexcmgit/pixelarticons/blob/96354a3b1e067484c743e016282c38ef6b03cf57/.github/workflows/flow.yaml#L67-L84

Note that the pub credentials are generated after you publish the package for the first time, so the first release of your automated tool must be manual, then you copy the credentials generated in your local machine to the GitHub secrets. I did this several years ago, so I don't know if there is a new method to auth on pub.dev.

---

This flow is triggered by a cron that runs every 15 days or manually:

https://github.com/alexcmgit/pixelarticons/blob/96354a3b1e067484c743e016282c38ef6b03cf57/.github/workflows/flow.yaml#L1-L6

## Run locally

To run locally, follow the same steps as the [`flow.yaml` action](https://github.com/alexcmgit/pixelarticons/blob/main/.github/workflows/flow.yaml).

The working directory is the repository root.

Required environment:

```
Dart SDK version: 2.14.4 (stable)
Python 3.9.9
```

## Breaking Change Exception

This means that this tool can't find the latest release of the [pixelarticons](https://github.com/halfmage/pixelarticons) repository.

**But this can have several causes**, so the best way to fix that is to first figure out where the icons are located in the original repository and then update the `~/download/download.py` script to fix/cover the breaking changes **if they exists** (this error can also be caused by a simple python exception).

Please fill a issue to see what is going wrong and do not worry: all current releases and versions will be available.

