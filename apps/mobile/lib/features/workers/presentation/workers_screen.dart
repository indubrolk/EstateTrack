import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../attendance/presentation/attendance_screen.dart';

const _green = Color(0xFF12633B);
const _dark = Color(0xFF142338);
const _muted = Color(0xFF647067);
const _background = Color(0xFFF7F9FF);
const _mint = Color(0xFFCDEAD9);
const _blue = Color(0xFFE5EDFF);

class WorkersScreen extends ConsumerStatefulWidget {
  const WorkersScreen({super.key, required this.onMarkAttendance});

  final VoidCallback onMarkAttendance;

  @override
  ConsumerState<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends ConsumerState<WorkersScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _division;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _division = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reuse the attendance roster so names, divisions and today's status agree.
    final workers = ref.watch(attendanceProvider);
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: _green, size: 28),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'EstateTrack · Workers',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: _dark,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: _mint,
                        child: Icon(Icons.groups_outlined, color: _green),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: workers.when(
                    data: _directory,
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: _green),
                    ),
                    error: (error, stack) => Center(
                      child: SingleChildScrollView(
                        child: _message(
                          Icons.cloud_off_outlined,
                          'Unable to load workers',
                          'Please try again to load your worker directory.',
                          action: TextButton.icon(
                            onPressed: () => ref.invalidate(attendanceProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try again'),
                          ),
                        ),
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

  Widget _directory(List<Map<String, Object?>> workers) {
    final divisions =
        workers.map((worker) => worker['division'] as String).toSet().toList()
          ..sort();
    final selectedDivision = divisions.contains(_division) ? _division : null;
    final query = _query.trim().toLowerCase();
    final filtered = workers.where((worker) {
      final matchesSearch =
          (worker['name'] as String).toLowerCase().contains(query) ||
          worker['id'].toString().contains(query);
      return matchesSearch &&
          (selectedDivision == null || worker['division'] == selectedDivision);
    }).toList();

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.badge_outlined, color: _green, size: 19),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'YOUR ESTATE TEAM',
                              style: TextStyle(
                                color: _green,
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
                        'Worker Directory',
                        style: TextStyle(
                          color: _dark,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Find your crew and view their daily attendance.',
                        style: TextStyle(color: _muted, fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _summaryBadge(
                            Icons.groups_outlined,
                            '${workers.length} workers',
                          ),
                          _summaryBadge(
                            Icons.location_on_outlined,
                            '${divisions.length} ${divisions.length == 1 ? 'division' : 'divisions'}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  style: const TextStyle(color: _dark, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name or worker ID',
                    hintStyle: const TextStyle(color: _muted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: _green),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close, size: 20),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE1E6EE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE1E6EE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _green, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _divisionChip('All divisions', null, selectedDivision),
                    for (final division in divisions)
                      _divisionChip(
                        'Division $division',
                        division,
                        selectedDivision,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Your Workers',
                        style: TextStyle(
                          color: _dark,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${filtered.length} of ${workers.length}',
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select a worker to view details.',
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        if (filtered.isEmpty)
          SliverToBoxAdapter(
            child: _message(
              workers.isEmpty ? Icons.groups_outlined : Icons.search_off,
              workers.isEmpty ? 'No workers yet' : 'No matching workers',
              workers.isEmpty
                  ? 'Workers will appear here when they are assigned.'
                  : 'Try another name, worker ID or division.',
              action: workers.isEmpty
                  ? null
                  : TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear filters'),
                    ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) => _workerCard(filtered[index]),
            ),
          ),
      ],
    );
  }

  Widget _summaryBadge(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19, color: _green),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: _dark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _divisionChip(String label, String? value, String? selected) =>
      ChoiceChip(
        label: Text(label),
        selected: value == selected,
        selectedColor: _mint,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: value == selected ? _green : _muted,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        side: BorderSide(
          color: value == selected ? _green : const Color(0xFFE1E6EE),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        onSelected: (_) => setState(() => _division = value),
      );

  Widget _workerCard(Map<String, Object?> worker) {
    final identity = Row(
      children: [
        Container(
          width: 47,
          height: 47,
          decoration: BoxDecoration(
            color: _mint,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.person_outline, color: _green),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                worker['name'] as String,
                style: const TextStyle(
                  color: _dark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ID ${worker['id']} · Division ${worker['division']}',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: _green, size: 22),
      ],
    );
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
        side: const BorderSide(color: Color(0xFFEBEEF3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _showWorker(worker),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final status = _statusBadge(worker['status'] as String?);
              if (constraints.maxWidth >= 600) {
                return Row(
                  children: [
                    Expanded(child: identity),
                    const SizedBox(width: 24),
                    status,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [identity, const SizedBox(height: 12), status],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String? status) {
    final (label, icon, color, tint) = switch (status) {
      'present' => ('Present today', Icons.check_circle_outline, _green, _mint),
      'absent' => (
        'Absent today',
        Icons.person_off_outlined,
        const Color(0xFFC62525),
        const Color(0xFFFFDDDA),
      ),
      'half_day' => (
        'Half-day today',
        Icons.timelapse_outlined,
        const Color(0xFF986000),
        const Color(0xFFFFDDB9),
      ),
      _ => (
        'Not marked today',
        Icons.schedule,
        _muted,
        const Color(0xFFF0F4FF),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWorker(Map<String, Object?> worker) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: _background,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Worker Details',
                      style: TextStyle(
                        color: _dark,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close details',
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 30,
                backgroundColor: _mint,
                child: Icon(Icons.person_outline, color: _green, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                worker['name'] as String,
                style: const TextStyle(
                  color: _dark,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Worker ID: ${worker['id']}',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              _summaryBadge(
                Icons.location_on_outlined,
                'Division ${worker['division']}',
              ),
              const SizedBox(height: 20),
              const Text(
                'TODAY’S ATTENDANCE',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              _statusBadge(worker['status'] as String?),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    widget.onMarkAttendance();
                  },
                  icon: const Icon(Icons.how_to_reg_outlined),
                  label: const Text('Open Attendance'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _message(
    IconData icon,
    String title,
    String subtitle, {
    Widget? action,
  }) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: _blue,
          child: Icon(icon, color: _green, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _dark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 13),
        ),
        if (action != null) ...[const SizedBox(height: 12), action],
      ],
    ),
  );
}
