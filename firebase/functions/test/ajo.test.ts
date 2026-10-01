import { test } from 'node:test';
import assert from 'node:assert/strict';

import { ajoReference, parseAjoReference } from '../src/ajo-ref.ts';

test('an Ajo reference round-trips', () => {
  const ref = ajoReference('abc123', 2, 4);
  assert.equal(ref, 'ajo:abc123:2:4');
  assert.deepEqual(parseAjoReference(ref), { circleId: 'abc123', round: 2, member: 4 });
});

test('other references are not Ajo ones', () => {
  for (const r of ['order-42', 'ajo:abc:x:1', 'ajo:abc:1', 'ajo::1:1', undefined, 7]) {
    assert.equal(parseAjoReference(r), null);
  }
});
