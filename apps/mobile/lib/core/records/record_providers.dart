import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'work_record.dart';
import 'work_repository.dart';

final workRepositoryProvider = Provider(
  (ref) => WorkRepository(AppDatabase.instance),
);
final supervisorProvider = Provider<String>((ref) => 'local-supervisor');
final rulesProvider = FutureProvider((ref) async {
  if (kIsWeb) return <Map<String, Object?>>[];
  return ref.watch(workRepositoryProvider).rules();
});
final attendanceProvider = FutureProvider<List<Map<String, Object?>>>((
  ref,
) async {
  if (kIsWeb) {
    // Read-only browser preview. Durable recording is supported on the phone.
    return List.generate(
      3,
      (index) => {
        'id': index + 1,
        'name': 'Worker 00${index + 1}',
        'division': 'A',
        'status': null,
      },
    );
  }
  return ref.watch(workRepositoryProvider).roster(dateKey(DateTime.now()));
});

final datedAttendanceProvider =
    FutureProvider.family<List<Map<String, Object?>>, String>((
      ref,
      date,
    ) async {
      if (kIsWeb) return ref.watch(attendanceProvider.future);
      return ref.watch(workRepositoryProvider).roster(date);
    });
