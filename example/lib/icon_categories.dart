/// Categories are matched in order; unfamiliar upstream names remain visible.
const iconCategories = <String, String>{
  'Brands': r'^(android|apple|bluesky|deno|discord|docker|facebook|figma|github|gitlab|gmail|google|instagram|linkedin|linux|mastodon|netlify|npm|pnpm|pixelarticons|react|slack|telegram|tiktok|twitter|vercel|whatsapp|youtube)$|^x$',
  'Arrows & navigation': r'^(aarrow|tarrow|arrow|chevron|corner|scroll|direction|compass|gps|move|collapse|expand|externallink|forward|login|logout|redo|undo)',
  'Text & layout': r'^(align|text|letter|heading|layout|grid|float|section|aspectratio|proportion|ratio|radius|frame|crop|flip|flatten|bulletlist|listbox|quotetext|ampersand|atsign|hash|languages)',
  'Files & organization': r'^(file|folder|archive|attachment|article|book|clipboard|copy|note|sticky|save|inbox|package|box$|open$|presentation)',
  'Communication & people': r'^(avatar|user|human|contact|membercard|mail|message|comment|phone|send|share|rss|megaphone|angry|annoyed|frown|laugh|meh|smile|thumbs)',
  'Media & sound': r'^(album|airplay|audio|badge|camera|clapper|gallery|headphone|image|mic|music|video|volume|play|pause|stop|repeat|shuffle|radio|drum|keyboardmusic|projector|pictureinpicture|subscriptions|webcam)',
  'Technology & code': r'^(ai|algorithm|app|battery|binary|braces|brackets|bug|cellular|circuit|cloudserver|code|computer|cpu|database|debug|dock|git|gpu|keyboard|laptop|memorystick|modem|monitor|mouse|pccase|plug|printer|qrcode|robot|script|server|signal|smartphone|tablet|terminal|tv|usb|vibrate|wifi)',
  'Money & shopping': r'^(analytics|banknote|barcode|briefcase|calculator|card|chart|coins|creditcard|diamondgem|dollar|euro|gift|handbag|invoice|money|percent|pound|receipt|rubel|scanbarcode|shopping|store|trending|wallet)',
  'Places & travel': r'^(anchor|backpack|bed|building|bus|car$|castle|door|earth|estate|factory|kfactory|globe|helicopter|home|hotel|klibrary|map|parking|roadsign|ship|smarthome|sofa|suitcase|tent|truck|university|utilitypole|wall|warehouse|windowframe)',
  'Nature & everyday': r'^(alien|balloon|bottle|cake|chess|cigarette|cloud|coffee|crown|dog|feather|fire|fish|gamepad|heart|joystick|leaf|lightbulb|moon|mug|party|potion|recycle|shirt|skull|snail|snake|snowflake|sparkle|star|sun|sword|tea$|teach|testtube|thermometer|tournament|tree|trex|trophy|waves|wind|zap|goal)',
  'Time & calendars': r'^(alarmclock|calendar|clock|datetime|hourglass|watch)',
  'Design & tools': r'^(brush|colors|cursor|cut|eraser|eye|hand$|icon|invert|lasso|magic|pencil|pensquare|pipette|pointer|scale|scissors|shapes|spline|spotlight|spray|sticker|tangent|target|tool|wand)',
  'Interface & controls': r'.*',
};

final _categoryPatterns = {
  for (final category in iconCategories.entries)
    category.key: RegExp(category.value),
};

String categoryForIcon(String name) {
  final base = name.replaceFirst(RegExp(r'(sharp|solid|glyph)$'), '');
  return _categoryPatterns.entries
      .firstWhere((category) => category.value.hasMatch(base))
      .key;
}
