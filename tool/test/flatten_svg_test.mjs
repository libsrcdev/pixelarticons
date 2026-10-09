import assert from 'node:assert/strict';
import test from 'node:test';
import paper from 'paper';
import { DOMParser } from '@xmldom/xmldom';
import { flattenSvg } from '../flatten_svg.mjs';

function flattened(paths) {
  const result = flattenSvg(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">${paths}</svg>`);
  const svg = new DOMParser().parseFromString(result, 'image/svg+xml');
  const nodes = svg.getElementsByTagName('path');
  assert.equal(nodes.length, 1);
  const shape = new paper.CompoundPath(nodes[0].getAttribute('d'));
  shape.fillRule = 'nonzero';
  return shape;
}

test('touching subpaths retain their connecting cells', () => {
  const shape = flattened('<path d="M4 18h2v2H4zM6 18h2v2H6zM6 20h8v2H6z"/>');
  assert.ok(Math.abs(Math.abs(shape.area) - 24) < 1e-9);
  assert.equal(shape.contains(new paper.Point(4.5, 18.5)), true);
  assert.equal(shape.contains(new paper.Point(6.5, 18.5)), true);
});

test('overlapping subpaths become a filled union', () => {
  const shape = flattened('<path d="M0 0h4v4H0zM0 0h2v4H0zM0 0h4v2H0z"/>');
  assert.ok(Math.abs(Math.abs(shape.area) - 16) < 1e-9);
  assert.equal(shape.contains(new paper.Point(1, 1)), true);
});

test('separate elements paint independently despite opposite winding', () => {
  const shape = flattened('<path d="M0 0H2V2H0Z"/><path d="M1 0V2H3V0Z"/>');
  assert.ok(Math.abs(Math.abs(shape.area) - 6) < 1e-9);
});

test('nonzero and evenodd holes survive flattening', () => {
  for (const rule of ['nonzero', 'evenodd']) {
    const inner = rule === 'nonzero' ? 'M1 1V3H3V1Z' : 'M1 1H3V3H1Z';
    const shape = flattened(`<path fill-rule="${rule}" d="M0 0H4V4H0Z ${inner}"/>`);
    assert.ok(Math.abs(Math.abs(shape.area) - 12) < 1e-9);
    assert.equal(shape.contains(new paper.Point(2, 2)), false);
    assert.equal(shape.contains(new paper.Point(0.5, 0.5)), true);
  }
});
