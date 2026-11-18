import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';

// Temporary in-memory attendance storage for Chrome development.
final Map<int, String> mockAttendance = {};

final attendanceProvider = FutureProvider<List<Map<String, Object?>>>((
  ref,
) async {
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

  static const green = Color(0xFF12633B);
  static const dark = Color(0xFF142338);
  static const muted = Color(0xFF647067);
  static const background = Color(0xFFF7F9FF);
  static const mint = Color(0xFFCDEAD9);
  static const blue = Color(0xFFE5EDFF);
  static const red = Color(0xFFC62525);
  static const amber = Color(0xFF986000);

  static const statuses = {
    'present': ('Present', Icons.check_circle_outline, green, mint),
    'absent': ('Absent', Icons.person_off_outlined, red, Color(0xFFFFDDDA)),
    'half_day': (
      'Half-day',
      Icons.timelapse_outlined,
      amber,
      Color(0xFFFFDDB9),
    ),
  };

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
        const SnackBar(content: Text('Failed to save attendance')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendance = ref.watch(attendanceProvider);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: attendance.when(
                    data: (workers) => _content(context, ref, workers),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: green),
                    ),
                    error: (error, stack) => _message(
                      icon: Icons.cloud_off_outlined,
                      title: 'Unable to load attendance',
                      subtitle: 'Please try again to load your worker list.',
                      action: TextButton.icon(
                        onPressed: () => ref.invalidate(attendanceProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        children: [
          Icon(Icons.eco, color: green, size: 28),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'EstateTrack · Attendance',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
          ),
          SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: mint,
            child: Icon(Icons.how_to_reg_outlined, color: green),
          ),
        ],
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, Object?>> workers,
  ) {
    final marked = workers
        .where((worker) => statuses.containsKey(worker['status']))
        .length;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summary(context, workers.length, marked),
                const SizedBox(height: 16),
                _statistics(workers),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: mint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: green),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          kIsWeb
                              ? 'Browser preview · Changes last for this session only.'
                              : 'Changes save automatically on this device.',
                          style: const TextStyle(
                            color: green,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Worker Attendance',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose a status for each worker below.',
                  style: TextStyle(fontSize: 13, color: muted),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        if (workers.isEmpty)
          SliverToBoxAdapter(
            child: _message(
              icon: Icons.groups_outlined,
              title: 'No workers yet',
              subtitle: 'Workers will appear here when they are assigned.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.builder(
              itemCount: workers.length,
              itemBuilder: (context, index) =>
                  _workerCard(context, ref, workers[index]),
            ),
          ),
      ],
    );
  }

  Widget _summary(BuildContext context, int total, int marked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny_outlined, color: green, size: 19),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'DAILY MUSTER',
                  style: TextStyle(
                    color: green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Daily Attendance',
            style: TextStyle(
              color: dark,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            MaterialLocalizations.of(context).formatFullDate(DateTime.now()),
            style: const TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.fact_check_outlined,
                      color: green,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$marked of $total workers marked',
                        style: const TextStyle(
                          color: dark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: total == 0 ? 0 : marked / total,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: const Color(0xFFEBEEF3),
                  color: green,
                  semanticsLabel:
                      'Attendance completion: $marked of $total workers marked',
                ),
                const SizedBox(height: 8),
                Text(
                  total == 0
                      ? 'No workers to mark today'
                      : marked == total
                      ? 'All set. Today’s attendance is complete.'
                      : '${total - marked} remaining · Keep your daily records up to date',
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statistics(List<Map<String, Object?>> workers) {
    final cards = [
      _statCard(
        'TOTAL CREW',
        workers.length,
        Icons.groups_outlined,
        dark,
        blue,
      ),
      for (final entry in statuses.entries)
        _statCard(
          entry.value.$1.toUpperCase(),
          workers.where((worker) => worker['status'] == entry.key).length,
          entry.value.$2,
          entry.value.$3,
          entry.value.$4,
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }

  Widget _statCard(
    String label,
    int count,
    IconData icon,
    Color color,
    Color tint,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFEBEEF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: dark,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 14,
                backgroundColor: tint,
                child: Icon(icon, size: 17, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$count',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const TextSpan(
                    text: ' workers',
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _workerCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, Object?> worker,
  ) {
    final status = worker['status'] as String?;
    final selected = statuses[status];
    final details = Row(
      children: [
        Container(
          width: 47,
          height: 47,
          decoration: BoxDecoration(
            color: selected?.$4 ?? blue,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(Icons.person_outline, color: selected?.$3 ?? dark),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                worker['name'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Division ${worker['division']} · ${selected?.$1 ?? 'Not marked'}',
                style: const TextStyle(fontSize: 12, color: muted),
              ),
            ],
          ),
        ),
      ],
    );
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in statuses.entries)
          ChoiceChip(
            label: Text(entry.value.$1),
            avatar: Icon(
              entry.value.$2,
              size: 18,
              color: status == entry.key ? entry.value.$3 : muted,
            ),
            selected: status == entry.key,
            showCheckmark: false,
            selectedColor: entry.value.$4,
            backgroundColor: background,
            labelStyle: TextStyle(
              color: status == entry.key ? entry.value.$3 : muted,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            side: BorderSide(
              color: status == entry.key
                  ? entry.value.$3
                  : const Color(0xFFE1E6EE),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            onSelected: (_) =>
                markAttendance(ref, context, worker['id'] as int, entry.key),
          ),
      ],
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFEBEEF3)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 720 &&
              MediaQuery.textScalerOf(context).scale(13) <= 17) {
            return Row(
              children: [
                Expanded(child: details),
                const SizedBox(width: 20),
                actions,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [details, const SizedBox(height: 14), actions],
          );
        },
      ),
    );
  }

  Widget _message({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: blue,
              child: Icon(icon, color: green, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 13),
            ),
            if (action != null) ...[const SizedBox(height: 12), action],
          ],
        ),
      ),
    );
  }
}
