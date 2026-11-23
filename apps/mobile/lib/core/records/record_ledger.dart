import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Immutable records and their mutable delivery state are deliberately stored
/// separately. A sync acknowledgement must never rewrite the original record.
class RecordLedger {
  RecordLedger(this.database);

  final Database database;

  static Future<void> createSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE record_events (
        sequence INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id TEXT NOT NULL UNIQUE,
        stream_id TEXT NOT NULL,
        previous_event_id TEXT UNIQUE REFERENCES record_events(event_id),
        kind TEXT NOT NULL,
        created_at TEXT NOT NULL,
        payload TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX record_events_stream ON record_events(stream_id, sequence)',
    );
    await db.execute('''
      CREATE TABLE record_outbox (
        event_id TEXT PRIMARY KEY REFERENCES record_events(event_id),
        acknowledged_at TEXT,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT
      )
    ''');
    for (final operation in ['UPDATE', 'DELETE']) {
      await db.execute('''
        CREATE TRIGGER record_events_no_${operation.toLowerCase()}
        BEFORE $operation ON record_events
        BEGIN SELECT RAISE(ABORT, 'Records are append-only'); END
      ''');
    }
  }

  /// The supplied parent is checked inside the same transaction as the write.
  /// A stale form cannot silently replace a correction made elsewhere.
  Future<Map<String, Object?>> append({
    required String streamId,
    required String kind,
    required String? expectedPreviousId,
    required Map<String, Object?> payload,
  }) => database.transaction((txn) async {
    final current = await txn.query(
      'record_events',
      where: 'stream_id = ?',
      whereArgs: [streamId],
      orderBy: 'sequence DESC',
      limit: 1,
    );
    final actualPrevious = current.isEmpty ? null : current.first['event_id'];
    if (actualPrevious != expectedPreviousId) {
      throw StateError(
        'This record has changed. Reload it before saving a correction.',
      );
    }
    final event = <String, Object?>{
      'event_id': const Uuid().v4(),
      'stream_id': streamId,
      'previous_event_id': expectedPreviousId,
      'kind': kind,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'payload': jsonEncode(payload),
    };
    await txn.insert('record_events', event);
    await txn.insert('record_outbox', {'event_id': event['event_id']});
    return event;
  });

  Future<List<Map<String, Object?>>> history(String streamId) => database.query(
    'record_events',
    where: 'stream_id = ?',
    whereArgs: [streamId],
    orderBy: 'sequence DESC',
  );

  Future<List<Map<String, Object?>>> pending({int limit = 100}) =>
      database.rawQuery(
        '''
    SELECT e.* FROM record_events e JOIN record_outbox o ON o.event_id = e.event_id
    WHERE o.acknowledged_at IS NULL ORDER BY e.sequence LIMIT ?
  ''',
        [limit],
      );

  Future<int> pendingCount() async =>
      Sqflite.firstIntValue(
        await database.rawQuery(
          'SELECT COUNT(*) FROM record_outbox WHERE acknowledged_at IS NULL',
        ),
      ) ??
      0;

  Future<void> acknowledge(Iterable<String> ids) =>
      database.transaction((txn) async {
        for (final id in ids) {
          await txn.update(
            'record_outbox',
            {
              'acknowledged_at': DateTime.now().toUtc().toIso8601String(),
              'last_error': null,
            },
            where: 'event_id = ? AND acknowledged_at IS NULL',
            whereArgs: [id],
          );
        }
      });

  Future<void> recordFailure(Iterable<String> ids, String message) =>
      database.transaction((txn) async {
        for (final id in ids) {
          await txn.rawUpdate(
            'UPDATE record_outbox SET attempts = attempts + 1, last_error = ? WHERE event_id = ? AND acknowledged_at IS NULL',
            [message, id],
          );
        }
      });
}
