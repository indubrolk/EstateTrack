
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';

// Temporary in-memory attendance storage for Chrome development.
final Map<int, String> mockAttendance = {};

final attendanceProvider =
    FutureProvider<List<Map<String, Object?>>>((ref) async {
  if (kIsWeb) {
    // Mock workers for browser development.
    return [
      {
        'id': 1,
        'name': 'Worker 001',
        'division': 'A',
        'status': mockAttendance[1],
      },
      {
        'id': 2,
        'name': 'Worker 002',
        'division': 'A',
        'status': mockAttendance[2],
      },
      {
        'id': 3,
        'name': 'Worker 003',
        'division': 'A',
        'status': mockAttendance[3],
      },
    ];
  }

  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  return AppDatabase.instance.getAttendance(today);
});

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  Future<void> markAttendance(
    WidgetRef ref,
    BuildContext context,
    int workerId,
    String status,
  ) async {
    if (kIsWeb) {
      // Browser development mode: store data in memory.
      mockAttendance[workerId] = status;
      ref.invalidate(attendanceProvider);
      return;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      await AppDatabase.instance.saveAttendance(
        workerId: workerId,
        date: today,
        status: status,
      );

      ref.invalidate(attendanceProvider);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save attendance'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendance = ref.watch(attendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Attendance'),
        backgroundColor: const Color(0xFF1B5E42),
        foregroundColor: Colors.white,
      ),
      body: attendance.when(
        data: (workers) {
          final present = workers.where(
            (worker) => worker['status'] == 'present',
          ).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${workers.length}',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const Text('Workers'),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '$present',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const Text('Present'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    final worker = workers[index];
                    final workerId = worker['id'] as int;
                    final status = worker['status'] as String?;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                for (final entry in {
                                  'present': 'Present',
                                  'absent': 'Absent',
                                  'half_day': 'Half-day',
                                }.entries)
                                  ChoiceChip(
                                    label: Text(entry.value),
                                    selected: status == entry.key,
                                    onSelected: (_) {
                                      markAttendance(
                                        ref,
                                        context,
                                        workerId,
                                        entry.key,
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
