import 'package:flutter/material.dart';

import '../../../core/records/work_repository.dart';
import '../../../core/records/work_record.dart';

class RecordHistoryScreen extends StatelessWidget {
  const RecordHistoryScreen({
    super.key,
    required this.history,
    required this.name,
  });
  final Future<List<Map<String, Object?>>> history;
  final String name;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('$name · History')),
    body: FutureBuilder(
      future: history,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Unable to load history. Reopen to try again.'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = snapshot.data!;
        if (entries.isEmpty) {
          return const Center(child: Text('No records yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final data = WorkRepository.payload(entry);
            final facts = data['facts'] == null
                ? null
                : WorkFacts.fromJson(data['facts'] as Map<String, dynamic>);
            final calculated = data['calculated'] as Map<String, dynamic>?;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index == 0 ? 'Current · ' : ''}${entry['kind']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Recorded: ${DateTime.parse(entry['created_at'] as String).toLocal()}',
                    ),
                    Text('Supervisor: ${data['operator']}'),
                    if (facts != null) ...[
                      Text(
                        'Work date: ${facts.date} · ${facts.attended ? 'Came to work' : 'Did not attend'}',
                      ),
                      if (facts.attended)
                        Text(
                          '${facts.task}: ${formatFixed(facts.quantityMilli)} ${facts.unit}',
                        ),
                      Text(
                        'Calculated: ${resultLabel(calculated?['status'] as String?)}',
                      ),
                      Text('Final: ${resultLabel(data['status'] as String?)}'),
                      if (calculated != null)
                        Text(
                          'Extra amount: ${formatFixed(calculated['extra_pay_minor'] as int, places: 2)} · Incentive eligible: ${calculated['incentive_eligible'] == true ? 'Yes' : 'No'}',
                        ),
                    ] else
                      Text(
                        'Original attendance: ${(data['legacy'] as Map?)?['status'] ?? 'Unknown'} · Facts were not recorded by the old app.',
                      ),
                    if ((data['reason'] as String? ?? '').isNotEmpty)
                      Text('Reason: ${data['reason']}'),
                    if (data['rule_snapshot'] != null)
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text('Rules used for this entry'),
                        children: [
                          Builder(
                            builder: (context) {
                              final rule = WorkRule.fromJson(
                                data['rule_snapshot'] as Map<String, dynamic>,
                              );
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Norm: ${formatFixed(rule.normMilli)} ${rule.unit}\nHalf-day cut-off: ${formatFixed(rule.halfDayCutoffMilli)} ${rule.unit}\nExtra rate: ${formatFixed(rule.extraRateMinor, places: 2)} per ${rule.unit}\nIncentive threshold: ${formatFixed(rule.incentiveThresholdMilli)} ${rule.unit}',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    SelectableText(
                      'Entry: ${entry['event_id']}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
