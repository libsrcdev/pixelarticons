import paper from 'paper';
import ClipperLib from 'clipper-lib';
import { DOMParser, XMLSerializer } from '@xmldom/xmldom';

const scale = 1e6;
paper.setup(new paper.Size(24, 24));

function union(paths, fillRule) {
  const clipper = new ClipperLib.Clipper();
  clipper.AddPaths(paths, ClipperLib.PolyType.ptSubject, true);
  const result = [];
  if (!clipper.Execute(ClipperLib.ClipType.ctUnion, result, fillRule, fillRule)) {
    throw new Error('SVG polygon union failed');
  }
  return result;
}

export function flattenSvg(source, name = 'SVG') {
  const svg = new DOMParser().parseFromString(source, 'image/svg+xml');
  const root = svg.documentElement;
  const elements = Array.from(root.getElementsByTagName('*'));
  if (root.hasAttribute('transform') ||
      elements.some(element => element.tagName !== 'path' || element.hasAttribute('transform'))) {
    throw new Error(`Expected untransformed SVG paths: ${name}`);
  }
  if (!elements.length) throw new Error(`No SVG paths: ${name}`);
  const areas = [];
  try {
    for (const node of elements) {
      const data = node.getAttribute('d');
      if (!data) throw new Error(`Missing path data: ${name}`);
      // Paper.js parses SVG commands; Clipper resolves filled polygon areas.
      const element = new paper.CompoundPath(data);
      const contours = element.children.map(contour => {
        if (contour.segments.some(segment =>
          !segment.handleIn.isZero() || !segment.handleOut.isZero())) {
          throw new Error(`Curved SVG paths are not supported: ${name}`);
        }
        return contour.segments.map(({ point }) => ({
          X: Math.round(point.x * scale), Y: Math.round(point.y * scale),
        }));
      });
      const rule = node.getAttribute('fill-rule') || root.getAttribute('fill-rule') || 'nonzero';
      if (!['nonzero', 'evenodd'].includes(rule)) throw new Error(`Unsupported fill rule: ${rule}`);
      // Resolve each element independently: oppositely wound separate elements
      // paint over one another, while subpaths within an element can make holes.
      areas.push(...union(contours, rule === 'evenodd'
        ? ClipperLib.PolyFillType.pftEvenOdd : ClipperLib.PolyFillType.pftNonZero));
    }
    const filled = union(areas, ClipperLib.PolyFillType.pftNonZero);
    for (const node of elements) node.parentNode.removeChild(node);
    const merged = svg.createElementNS('http://www.w3.org/2000/svg', 'path');
    merged.setAttribute('d', filled.map(contour =>
      contour.map((point, index) => `${index ? 'L' : 'M'}${point.X / scale} ${point.Y / scale}`).join('') + 'Z'
    ).join(''));
    merged.setAttribute('fill-rule', 'nonzero');
    root.appendChild(merged);
    return new XMLSerializer().serializeToString(svg);
  } finally {
    paper.project.clear();
  }
}
