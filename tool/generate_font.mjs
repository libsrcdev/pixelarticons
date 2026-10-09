import fs from 'node:fs/promises';
import path from 'node:path';
import { flattenSvg } from './flatten_svg.mjs';
import svgtofont from 'svgtofont';

const [src, dist, manifest] = process.argv.slice(2);
if (!src || !dist || !manifest) {
  throw new Error('Usage: node generate_font.mjs <svg-directory> <output-directory> <codepoints.json>');
}
const codepoints = JSON.parse(await fs.readFile(manifest, 'utf8'));
// Only temporary generation copies are flattened; downloaded sources stay intact.
for (const filename of await fs.readdir(src)) {
  if (!filename.endsWith('.svg')) continue;
  const file = path.join(src, filename);
  await fs.writeFile(file, flattenSvg(await fs.readFile(file, 'utf8'), filename));
}
await svgtofont({
  src,
  dist,
  fontName: 'Pixel Art Icons',
  css: false,
  log: false,
  excludeFormat: ['eot', 'woff', 'woff2', 'svg', 'symbol.svg'],
  getIconUnicode(name, unicode, next) {
    if (!Number.isInteger(codepoints[name])) throw new Error(`Missing codepoint: ${name}`);
    return [String.fromCodePoint(codepoints[name]), next];
  },
  svgicons2svgfont: {
    fontHeight: 2400,
    normalize: false,
    fixedWidth: true,
    descent: 0,
  },
  svg2ttf: { ts: 0 },
});
