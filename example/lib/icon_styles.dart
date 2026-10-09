enum IconStyle {
  regular('Default'),
  sharp('Sharp'),
  solid('Solid'),
  glyph('Glyph');

  const IconStyle(this.label);

  final String label;
}

IconStyle styleForIcon(String name) {
  for (final style in [IconStyle.sharp, IconStyle.solid, IconStyle.glyph]) {
    if (name.endsWith(style.name)) return style;
  }
  return IconStyle.regular;
}
