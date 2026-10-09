# Pixel Art Icons example

A simple demo and documentation page for the package. The Getting started tab
covers installation, imports, usage, naming, and accessibility with selectable,
copyable code examples. Documentation lives in `assets/docs/getting_started.md`
and is rendered as Markdown, with bundled JetBrains Mono and syntax highlighting
for fenced Dart, shell, XML/SVG, and YAML code blocks. Unlabelled or unsupported
blocks stay plain text. The Icon gallery tab shows every icon, grouped into
labeled categories. Combine category and style chips (Default, Sharp, Solid, or Glyph) with name
search to narrow the gallery. Each tile shows
its icon and selectable Dart name. Click a card to open its detail view with
Flutter code, an SVG preview and source, and buttons to copy the name or SVG.
Shareable hash routes open the gallery at `#/` and Getting started at
`#/getting-started`; refreshing or using browser back/forward keeps the selected
page. The hero has a sparse, subtle Game of Life animation that scrolls with
the content and pauses for reduced-motion preferences.

The page uses slivers for its header, gallery, documentation, and detail view.
SVGs are bundled in `assets/icon_vectors.json` and updated by the sync tool.

The design follows [libsrc.dev](https://libsrc.dev): Share Tech typography,
a cream and green palette, thin borders, and restrained corners. The font’s
SIL Open Font License is included in `assets/fonts/OFL.txt`.

From the repository root:

```shell
flutter pub get
rps example -d chrome
```

Or from this directory, run `flutter pub get` followed by `flutter run`.
For Android, use Flutter 3.47+ and JDK 17 with a connected Android device.

## Publish the website

The [Publish website to GitHub Pages](../.github/workflows/publish-website.yml)
workflow tests and builds this example, then deploys `build/web` to GitHub Pages.
It runs on pushes to `main`, or manually from **Actions → Publish website to
GitHub Pages → Run workflow** with `main` selected.

Before the first deployment, set **Settings → Pages → Build and deployment →
Source** to **GitHub Actions**. No additional deployment secret is needed.
The workflow reads the site's base path from Pages, supporting both the default
repository URL and a custom domain configured in Pages settings. Hash links such
as `#/getting-started` work without server redirects.

The deployed URL appears in the workflow's `github-pages` environment.
