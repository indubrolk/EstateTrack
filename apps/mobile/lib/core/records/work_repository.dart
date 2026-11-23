import 'dart:convert';

import '../database/app_database.dart';
import 'record_ledger.dart';
import 'work_record.dart';

class WorkRepository {
  WorkRepository(this.store);
  final AppDatabase store;

  Future<RecordLedger> get ledger async => RecordLedger(await store.database);
  String stream(int workerId, String date) => 'work:$workerId:$date';

  static Map<String, dynamic> payload(Map<String, Object?> event) =>
      jsonDecode(event['payload'] as String) as Map<String, dynamic>;

  Future<List<Map<String, Object?>>> rules() async =>
      (await store.database).rawQuery('''
    SELECT e.* FROM record_events e
    WHERE kind = 'rule' AND sequence = (
      SELECT MAX(sequence) FROM record_events WHERE stream_id = e.stream_id
    ) ORDER BY stream_id
  ''');

  Future<void> saveRule(
    WorkRule rule, {
    required String operatorId,
    required String? previousId,
  }) async {
    rule.validate();
    _requireOperator(operatorId);
    await (await ledger).append(
      streamId: 'rule:${rule.key}',
      kind: 'rule',
      expectedPreviousId: previousId,
      payload: {
        'rule': rule.toJson(),
        'operator': operatorId.trim(),
        'policy': 'thresholds_v1',
      },
    );
  }

  Future<List<Map<String, Object?>>> roster(String date) async {
    final db = await store.database;
    final rows = await db.rawQuery(
      '''
      SELECT w.*, e.event_id, e.payload, e.kind, e.created_at, o.acknowledged_at
      FROM workers w LEFT JOIN record_events e
      ON e.sequence = (SELECT MAX(sequence) FROM record_events
        WHERE stream_id = 'work:' || w.id || ':' || ?)
      LEFT JOIN record_outbox o ON o.event_id = e.event_id ORDER BY w.name
    ''',
      [date],
    );
    return rows
        .map(
          (row) => {
            ...row,
            'status': row['payload'] == null ? null : payload(row)['status'],
          },
        )
        .toList();
  }

  Future<Map<String, Object?>?> latest(int workerId, String date) async {
    final entries = await (await ledger).history(stream(workerId, date));
    return entries.isEmpty ? null : entries.first;
  }

  Future<Map<String, Object?>?> ruleFor(WorkFacts facts) async {
    final key = 'rule:${ruleKey(facts.task, facts.unit)}';
    final rows = await (await ledger).history(key);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> saveFacts(
    WorkFacts facts, {
    required String operatorId,
    required String? previousId,
    String reason = '',
  }) async {
    facts.validate();
    _requireOperator(operatorId);
    if (previousId != null && reason.trim().isEmpty) {
      throw ArgumentError('A correction reason is required.');
    }
    if (reason.length > 1000) {
      throw ArgumentError('Keep the correction reason under 1,000 characters.');
    }
    final old = await latest(facts.workerId, facts.date);
    if (old?['event_id'] != previousId) {
      throw StateError('This record changed. Reload before saving.');
    }
    final selectedRule = facts.attended ? await ruleFor(facts) : null;
    final rule = selectedRule == null
        ? null
        : WorkRule.fromJson(
            payload(selectedRule)['rule'] as Map<String, dynamic>,
          );
    final outcome = calculateWork(facts, rule);
    final workers = await (await store.database).query(
      'workers',
      where: 'id = ?',
      whereArgs: [facts.workerId],
    );
    if (workers.isEmpty) throw ArgumentError('Worker does not exist.');
    await (await ledger).append(
      streamId: stream(facts.workerId, facts.date),
      kind: previousId == null ? 'facts' : 'correction',
      expectedPreviousId: previousId,
      payload: {
        'facts': facts.toJson(),
        'worker': workers.single,
        'rule_id': selectedRule?['event_id'],
        'rule_snapshot': rule?.toJson(),
        'policy': 'thresholds_v1',
        'calculated': outcome.toJson(),
        'status': outcome.status,
        'operator': operatorId.trim(),
        'reason': reason.trim(),
      },
    );
  }

  Future<void> overrideResult({
    required int workerId,
    required String date,
    required String previousId,
    required String status,
    required String reason,
    required String operatorId,
  }) async {
    _requireOperator(operatorId);
    if (reason.trim().isEmpty) {
      throw ArgumentError('An override reason is required.');
    }
    if (reason.length > 1000) {
      throw ArgumentError('Keep the override reason under 1,000 characters.');
    }
    if (!['present', 'half_day', 'absent'].contains(status)) {
      throw ArgumentError('Choose a full day, half day or absent result.');
    }
    final old = await latest(workerId, date);
    if (old == null || old['event_id'] != previousId) {
      throw StateError('This record changed. Reload before overriding.');
    }
    final data = payload(old);
    if (data['facts'] == null) {
      throw StateError('Record the work facts before overriding a result.');
    }
    await (await ledger).append(
      streamId: stream(workerId, date),
      kind: 'override',
      expectedPreviousId: previousId,
      payload: {
        ...data,
        'status': status,
        'reason': reason.trim(),
        'operator': operatorId.trim(),
      },
    );
  }

  void _requireOperator(String value) {
    if (value.trim().isEmpty || value.length > 80) {
      throw ArgumentError('Supervisor ID must contain 1–80 characters.');
    }
  }
}
