import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/records/work_record.dart';
import 'package:mobile/core/records/work_repository.dart';
import 'package:mobile/core/sync/sync_engine.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const rule = WorkRule(
  task: 'Plucking',
  unit: 'kg',
  normMilli: 20000,
  halfDayCutoffMilli: 10000,
  extraRateMinor: 255,
  incentiveThresholdMilli: 24000,
);
WorkFacts facts(int quantity, {bool attended = true}) => WorkFacts(
  workerId: 1,
  date: '2026-11-18',
  attended: attended,
  task: attended ? 'Plucking' : '',
  unit: attended ? 'kg' : '',
  quantityMilli: quantity,
);

class ReceiptTransport implements SyncTransport {
  bool loseResponse = true;
  final received = <String>{};
  @override
  Future<Set<String>> upload(List<Map<String, Object?>> events) async {
    final ids = events.map((e) => e['event_id'] as String).toSet();
    received.addAll(ids);
    if (loseResponse) {
      loseResponse = false;
      throw const SocketException('Response lost after server committed');
    }
    return ids;
  }
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('quantity and money use exact fixed precision', () {
    expect(parseFixed('23.125'), 23125);
    expect(parseFixed('2.55', places: 2), 255);
    for (final input in ['NaN', '-1', '1.0001', 'Infinity', '']) {
      expect(parseFixed(input), isNull);
    }
    expect(formatFixed(20125), '20.125');
    expect(formatFixed(20000), '20');
  });

  test('rule boundaries, absence, pending rules and incentive eligibility', () {
    expect(calculateWork(facts(9999), rule).status, 'review');
    expect(calculateWork(facts(10000), rule).status, 'half_day');
    expect(calculateWork(facts(19999), rule).status, 'half_day');
    expect(calculateWork(facts(20000), rule).status, 'present');
    expect(calculateWork(facts(23125), rule).extraPayMinor, 797);
    expect(calculateWork(facts(23999), rule).incentiveEligible, isFalse);
    expect(calculateWork(facts(24000), rule).incentiveEligible, isTrue);
    expect(calculateWork(facts(0, attended: false), rule).status, 'absent');
    expect(calculateWork(facts(20000), null).status, 'pending_rules');
    expect(() => calculateWork(facts(-1), rule), throwsArgumentError);
    expect(
      () => calculateWork(facts(1000, attended: false), rule),
      throwsArgumentError,
    );
    expect(
      () => const WorkRule(
        task: 'x',
        unit: 'kg',
        normMilli: 10,
        halfDayCutoffMilli: 11,
        extraRateMinor: 0,
        incentiveThresholdMilli: 0,
      ).validate(),
      throwsArgumentError,
    );
  });

  group('durable records', () {
    late Directory directory;
    late AppDatabase store;
    late WorkRepository repository;
    setUp(() async {
      directory = await Directory.systemTemp.createTemp('estate-ledger-');
      store = AppDatabase.forTesting('${directory.path}/records.db');
      repository = WorkRepository(store);
    });
    tearDown(() async {
      await store.close();
      await directory.delete(recursive: true);
    });

    test('corrections and overrides preserve history and reject missing reasons/stale parents', () async {
      await repository.saveRule(
        rule,
        operatorId: 'estate-admin',
        previousId: null,
      );
      await repository.saveFacts(
        facts(20000),
        operatorId: 'SUP-1',
        previousId: null,
      );
      final first = (await repository.latest(1, '2026-11-18'))!;
      final id = first['event_id'] as String;
      await expectLater(
        repository.overrideResult(
          workerId: 1,
          date: '2026-11-18',
          previousId: id,
          status: 'half_day',
          reason: ' ',
          operatorId: 'SUP-1',
        ),
        throwsArgumentError,
      );
      await repository.overrideResult(
        workerId: 1,
        date: '2026-11-18',
        previousId: id,
        status: 'half_day',
        reason: 'Approved early departure',
        operatorId: 'SUP-1',
      );
      final override = (await repository.latest(1, '2026-11-18'))!;
      final overridden = WorkRepository.payload(override);
      expect(overridden['status'], 'half_day');
      expect((overridden['calculated'] as Map)['status'], 'present');
      await expectLater(
        repository.saveFacts(
          facts(18000),
          operatorId: 'SUP-1',
          previousId: override['event_id'] as String,
        ),
        throwsArgumentError,
      );
      await expectLater(
        repository.saveFacts(
          facts(18000),
          operatorId: 'SUP-1',
          previousId: id,
          reason: 'Stale form',
        ),
        throwsStateError,
      );
      await repository.saveFacts(
        facts(18000),
        operatorId: 'SUP-1',
        previousId: override['event_id'] as String,
        reason: 'Correct scale reading',
      );
      final history = await (await repository.ledger).history(
        repository.stream(1, '2026-11-18'),
      );
      expect(history, hasLength(3));
      expect(history.last['payload'], first['payload']);
      final db = await store.database;
      await expectLater(
        db.update('record_events', {'kind': 'changed'}),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        db.delete('record_events'),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('rule changes do not rewrite old results; explicit correction recalculates', () async {
      await repository.saveRule(rule, operatorId: 'admin', previousId: null);
      final oldRule = (await repository.rules()).single;
      await repository.saveFacts(
        facts(20000),
        operatorId: 'SUP-1',
        previousId: null,
      );
      final original = (await repository.latest(1, '2026-11-18'))!;
      await repository.saveRule(
        const WorkRule(
          task: 'Plucking',
          unit: 'kg',
          normMilli: 25000,
          halfDayCutoffMilli: 12000,
          extraRateMinor: 300,
          incentiveThresholdMilli: 30000,
        ),
        operatorId: 'admin',
        previousId: oldRule['event_id'] as String,
      );
      expect(
        (await repository.latest(1, '2026-11-18'))!['payload'],
        original['payload'],
      );
      await repository.saveFacts(
        facts(20000),
        operatorId: 'SUP-1',
        previousId: original['event_id'] as String,
        reason: 'Apply newly approved rule version',
      );
      expect(
        (await repository.roster('2026-11-18')).first['status'],
        'half_day',
      );
      expect(
        (WorkRepository.payload(original)['rule_snapshot']
            as Map)['norm_milli'],
        20000,
      );
    });

    test('local commit survives restart; lost acknowledgement retries without loss', () async {
      await repository.saveFacts(
        facts(20000),
        operatorId: 'SUP-1',
        previousId: null,
      );
      await store.close();
      store = AppDatabase.forTesting('${directory.path}/records.db');
      repository = WorkRepository(store);
      final ledger = await repository.ledger;
      expect(await ledger.pendingCount(), 1);
      final transport = ReceiptTransport();
      final engine = SyncEngine(ledger, transport);
      await expectLater(engine.flush(), throwsA(isA<SocketException>()));
      expect(await ledger.pendingCount(), 1);
      await engine.flush();
      expect(await ledger.pendingCount(), 0);
      expect(transport.received, hasLength(1));
      expect(
        await ledger.history(repository.stream(1, '2026-11-18')),
        hasLength(1),
      );
    });

    test(
      'version one migration retains legacy records without inventing facts',
      () async {
        final path = '${directory.path}/records.db';
        final oldDb = await openDatabase(
          path,
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE workers (id INTEGER PRIMARY KEY, name TEXT, division TEXT)',
            );
            await db.execute(
              'CREATE TABLE attendance (id INTEGER PRIMARY KEY, worker_id INTEGER, date TEXT, status TEXT, synced INTEGER)',
            );
            await db.insert('workers', {
              'id': 1,
              'name': 'Existing worker',
              'division': 'B',
            });
            await db.insert('attendance', {
              'id': 7,
              'worker_id': 1,
              'date': '2026-11-18',
              'status': 'half_day',
              'synced': 1,
            });
          },
        );
        await oldDb.close();
        final roster = await repository.roster('2026-11-18');
        expect(roster.single['name'], 'Existing worker');
        expect(roster.single['status'], 'legacy');
        expect(
          (WorkRepository.payload(roster.single)['legacy'] as Map)['status'],
          'half_day',
        );
        final db = await store.database;
        expect((await db.query('attendance')).single['id'], 7);
        await expectLater(
          db.delete('attendance'),
          throwsA(isA<DatabaseException>()),
        );
      },
    );
  });
}
