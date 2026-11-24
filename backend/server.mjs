import { createServer } from 'node:http';
import { DatabaseSync } from 'node:sqlite';
import { timingSafeEqual } from 'node:crypto';
import { pathToFileURL } from 'node:url';

function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.keys(value).sort().map(key => [key, canonical(value[key])]));
  }
  return value;
}

export function openLedger(path) {
  const db = new DatabaseSync(path);
  db.exec(`PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;
    CREATE TABLE IF NOT EXISTS events (
      sequence INTEGER PRIMARY KEY AUTOINCREMENT,
      event_id TEXT NOT NULL UNIQUE,
      stream_id TEXT NOT NULL,
      previous_event_id TEXT REFERENCES events(event_id),
      body TEXT NOT NULL,
      received_at TEXT NOT NULL
    );
    CREATE INDEX IF NOT EXISTS events_stream ON events(stream_id);
    CREATE TRIGGER IF NOT EXISTS events_no_update BEFORE UPDATE ON events
      BEGIN SELECT RAISE(ABORT, 'Records are append-only'); END;
    CREATE TRIGGER IF NOT EXISTS events_no_delete BEFORE DELETE ON events
      BEGIN SELECT RAISE(ABORT, 'Records are append-only'); END;`);
  return db;
}

export function ingest(db, events) {
  if (!Array.isArray(events) || events.length > 100) throw new Error('Expected up to 100 events');
  const accepted = [];
  db.exec('BEGIN IMMEDIATE');
  try {
    for (const event of events) {
      if (!event || typeof event !== 'object' || typeof event.event_id !== 'string' ||
          !/^[\da-f-]{36}$/i.test(event.event_id) || typeof event.stream_id !== 'string' ||
          event.stream_id.length > 250 || !['facts', 'correction', 'override', 'rule', 'legacy_import'].includes(event.kind) ||
          !event.payload || typeof event.payload !== 'object' || !Number.isFinite(Date.parse(event.created_at))) {
        throw new Error('Invalid record envelope');
      }
      if (['correction', 'override'].includes(event.kind) &&
          (typeof event.payload.reason !== 'string' || !event.payload.reason.trim() || !event.previous_event_id)) {
        throw new Error('Corrections and overrides require a parent and reason');
      }
      const body = JSON.stringify(canonical(event));
      const existing = db.prepare('SELECT body FROM events WHERE event_id = ?').get(event.event_id);
      if (existing) {
        if (existing.body !== body) throw new Error('An event ID cannot be reused with different content');
        accepted.push(event.event_id);
        continue;
      }
      if (event.previous_event_id != null) {
        const parent = db.prepare('SELECT stream_id FROM events WHERE event_id = ?').get(event.previous_event_id);
        if (!parent || parent.stream_id !== event.stream_id) throw new Error('Parent is missing or belongs to a different record');
      }
      db.prepare('INSERT INTO events(event_id, stream_id, previous_event_id, body, received_at) VALUES (?, ?, ?, ?, ?)')
        .run(event.event_id, event.stream_id, event.previous_event_id ?? null, body, new Date().toISOString());
      accepted.push(event.event_id);
    }
    db.exec('COMMIT');
    return accepted;
  } catch (error) {
    db.exec('ROLLBACK');
    throw error;
  }
}

export function createSyncServer({ database, token }) {
  if (typeof token !== 'string' || token.length < 24) throw new Error('Set a random ESTATE_SYNC_TOKEN of at least 24 characters');
  const expected = Buffer.from(`Bearer ${token}`);
  return createServer(async (request, response) => {
    const reply = (code, value) => {
      response.writeHead(code, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
      response.end(JSON.stringify(value));
    };
    const supplied = Buffer.from(request.headers.authorization ?? '');
    if (supplied.length !== expected.length || !timingSafeEqual(supplied, expected)) {
      request.resume(); reply(401, { error: 'Unauthorized' }); return;
    }
    if (request.method !== 'POST' || request.url !== '/sync') {
      request.resume(); reply(404, { error: 'Not found' }); return;
    }
    try {
      let length = 0;
      const chunks = [];
      for await (const chunk of request) {
        length += chunk.length;
        if (length > 1024 * 1024) { reply(413, { error: 'Batch too large' }); return; }
        chunks.push(chunk);
      }
      const data = JSON.parse(Buffer.concat(chunks).toString('utf8'));
      // Acknowledgements are sent only after the SQLite transaction commits.
      reply(200, { accepted_ids: ingest(database, data.events) });
    } catch {
      reply(409, { error: 'Batch rejected; check record format, parent links, and immutable IDs' });
    }
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const database = openLedger(process.env.ESTATE_SYNC_DB ?? 'estate-sync.sqlite');
  const server = createSyncServer({ database, token: process.env.ESTATE_SYNC_TOKEN });
  const port = Number(process.env.PORT ?? 8787);
  server.requestTimeout = 30_000;
  server.listen(port, '127.0.0.1', () => console.log(`EstateTrack development sync: http://127.0.0.1:${port}/sync`));
}
