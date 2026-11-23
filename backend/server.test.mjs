import test from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { openLedger, ingest, createSyncServer } from './server.mjs';

const event = (overrides = {}) => ({ event_id: randomUUID(), stream_id: 'work:1:2026-11-18', previous_event_id: null, kind: 'facts', created_at: new Date().toISOString(), payload: { facts: { attended: true } }, ...overrides });

test('durable receipts, idempotent retries, append-only corrections and conflicts', () => {
  const dir = mkdtempSync(join(tmpdir(), 'estate-sync-'));
  const path = join(dir, 'records.sqlite');
  let db = openLedger(path);
  try {
    const original = event();
    assert.deepEqual(ingest(db, [original]), [original.event_id]);
    db.close(); db = openLedger(path);
    assert.deepEqual(ingest(db, [original]), [original.event_id]);
    assert.equal(db.prepare('SELECT COUNT(*) AS n FROM events').get().n, 1);
    assert.throws(() => ingest(db, [{ ...original, payload: { changed: true } }]));
    const corrected = event({ previous_event_id: original.event_id, kind: 'correction', payload: { reason: 'Scale reading corrected' } });
    ingest(db, [corrected]);
    assert.equal(db.prepare('SELECT COUNT(*) AS n FROM events').get().n, 2);
    assert.throws(() => db.exec('DELETE FROM events'));
    assert.throws(() => db.exec("UPDATE events SET body = '{}'"));
    const branch = event({ previous_event_id: original.event_id, kind: 'override', payload: { reason: 'Second device correction' } });
    ingest(db, [branch]);
    assert.equal(db.prepare('SELECT COUNT(*) AS n FROM events WHERE previous_event_id = ?').get(original.event_id).n, 2);
    assert.throws(() => ingest(db, [event({ kind: 'override', previous_event_id: original.event_id, payload: { reason: ' ' } })]));
    assert.throws(() => ingest(db, [event(), event({ previous_event_id: randomUUID() })]));
    assert.equal(db.prepare('SELECT COUNT(*) AS n FROM events').get().n, 3);
  } finally { db.close(); rmSync(dir, { recursive: true }); }
});

test('HTTP authentication and acknowledgements', async () => {
  const db = openLedger(':memory:');
  const token = 'test-only-token-12345678901234567890';
  const server = createSyncServer({ database: db, token });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const url = `http://127.0.0.1:${server.address().port}/sync`;
  try {
    assert.equal((await fetch(url, { method: 'POST', body: '{}' })).status, 401);
    const record = event();
    const response = await fetch(url, { method: 'POST', headers: { Authorization: `Bearer ${token}` }, body: JSON.stringify({ events: [record] }) });
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), { accepted_ids: [record.event_id] });
  } finally { await new Promise(resolve => server.close(resolve)); db.close(); }
});
