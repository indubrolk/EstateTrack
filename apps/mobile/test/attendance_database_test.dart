import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/main.dart' as app;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  testWidgets('desktop startup supports loading and saving attendance', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    // Exercise the real startup setup, without installing a factory in the test.
    try {
      app.main();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp(
        'attendance_test_',
      );
      final previousPath = await getDatabasesPath();
      Database? database;
      try {
        await databaseFactory.setDatabasesPath(directory.path);
        database = await AppDatabase.instance.database;
        const date = '2026-11-18';

        final workers = await AppDatabase.instance.getAttendance(date);
        expect(workers, hasLength(3));
        expect(workers.every((worker) => worker['status'] == null), isTrue);

        for (final status in ['present', 'absent', 'half_day']) {
          await AppDatabase.instance.saveAttendance(
            workerId: 1,
            date: date,
            status: status,
          );
          final updated = await AppDatabase.instance.getAttendance(date);
          expect(updated, hasLength(3));
          expect(updated.first['status'], status);
        }

        final nextDay = await AppDatabase.instance.getAttendance('2026-11-19');
        expect(nextDay.every((worker) => worker['status'] == null), isTrue);
      } finally {
        await database?.close();
        await databaseFactory.setDatabasesPath(previousPath);
        await directory.delete(recursive: true);
      }
    });
    expect(tester.takeException(), isNull);
  });
}
