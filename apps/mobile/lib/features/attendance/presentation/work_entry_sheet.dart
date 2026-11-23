import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/records/record_providers.dart';
import '../../../core/records/work_record.dart';
import '../../../core/records/work_repository.dart';
import '../../../core/sync/sync_service.dart';

class WorkEntrySheet extends ConsumerStatefulWidget {
  const WorkEntrySheet({super.key, required this.worker, required this.date});
  final Map<String, Object?> worker;
  final String date;
  @override
  ConsumerState<WorkEntrySheet> createState() => _WorkEntrySheetState();
}

class _WorkEntrySheetState extends ConsumerState<WorkEntrySheet> {
  final _form = GlobalKey<FormState>();
  final _task = TextEditingController();
  final _unit = TextEditingController(text: 'kg');
  final _quantity = TextEditingController();
  final _reason = TextEditingController();
  bool _attended = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.worker['payload'] != null) {
      final data = WorkRepository.payload(widget.worker);
      if (data['facts'] != null) {
        final facts = WorkFacts.fromJson(data['facts'] as Map<String, dynamic>);
        _attended = facts.attended;
        _task.text = facts.task;
        _unit.text = facts.unit;
        _quantity.text = formatFixed(facts.quantityMilli);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in [_task, _unit, _quantity, _reason]) {
      controller.dispose();
    }
    super.dispose();
  }

  WorkFacts get _facts => WorkFacts(
    workerId: widget.worker['id'] as int,
    date: widget.date,
    attended: _attended,
    task: _attended ? _task.text.trim() : '',
    unit: _attended ? _unit.text.trim() : '',
    quantityMilli: _attended ? parseFixed(_quantity.text) ?? 0 : 0,
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(workRepositoryProvider)
          .saveFacts(
            _facts,
            operatorId: ref.read(supervisorProvider),
            previousId: widget.worker['event_id'] as String?,
            reason: _reason.text,
          );
      ref.invalidate(attendanceProvider);
      ref.invalidate(datedAttendanceProvider(widget.date));
      unawaited(SyncService.instance.saved());
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rules = ref.watch(rulesProvider);
    final versions = rules.asData?.value ?? [];
    final matched = versions.where((event) {
      final rule = WorkRule.fromJson(
        WorkRepository.payload(event)['rule'] as Map<String, dynamic>,
      );
      return rule.key == ruleKey(_task.text, _unit.text);
    }).firstOrNull;
    WorkOutcome? outcome;
    if (!_attended ||
        (_task.text.trim().isNotEmpty &&
            _unit.text.trim().isNotEmpty &&
            parseFixed(_quantity.text) != null)) {
      try {
        outcome = calculateWork(
          _facts,
          matched == null
              ? null
              : WorkRule.fromJson(
                  WorkRepository.payload(matched)['rule']
                      as Map<String, dynamic>,
                ),
        );
      } catch (_) {
        /* Invalid input is explained by the form validator. */
      }
    }
    final correction = widget.worker['event_id'] != null;
    return PopScope(
      canPop: !_saving,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correction ? 'Correct work facts' : 'Record work facts',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${widget.worker['name']} · ${widget.date}'),
                const SizedBox(height: 8),
                const Text(
                  'Record attendance, the task and the total quantity for the day. The estate rules determine the result.',
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Came to work'),
                  value: _attended,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _attended = value),
                ),
                if (_attended) ...[
                  if (versions.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final event in versions)
                          ActionChip(
                            label: Text(
                              '${(WorkRepository.payload(event)['rule'] as Map)['task']}',
                            ),
                            onPressed: _saving
                                ? null
                                : () {
                                    final rule = WorkRule.fromJson(
                                      WorkRepository.payload(event)['rule']
                                          as Map<String, dynamic>,
                                    );
                                    setState(() {
                                      _task.text = rule.task;
                                      _unit.text = rule.unit;
                                    });
                                  },
                          ),
                      ],
                    ),
                  if (rules.isLoading) const LinearProgressIndicator(),
                  if (rules.hasError)
                    const Text(
                      'Rules could not be loaded. Facts can still be saved for later calculation.',
                    ),
                  _field(_task, 'Task', requiredText: true),
                  _field(
                    _unit,
                    'Quantity unit (kg, baskets, metres…)',
                    requiredText: true,
                  ),
                  _field(_quantity, 'Total kilos / quantity', quantity: true),
                ],
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EDFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CALCULATED RESULT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        outcome == null
                            ? 'Enter the facts to see the result'
                            : resultLabel(outcome.status),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (outcome != null &&
                          ![
                            'pending_rules',
                            'absent',
                          ].contains(outcome.status)) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Extra quantity: ${formatFixed(outcome.extraQuantityMilli)} ${_unit.text}',
                        ),
                        Text(
                          'Extra amount: ${formatFixed(outcome.extraPayMinor, places: 2)}',
                        ),
                        Text(
                          outcome.incentiveEligible
                              ? 'Incentive threshold reached'
                              : 'Incentive threshold not reached',
                        ),
                      ],
                      if (outcome?.status == 'pending_rules')
                        const Text(
                          'Save the facts now. Add task rules in Settings, then recalculate with a new correction entry.',
                        ),
                    ],
                  ),
                ),
                if (correction) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'This adds a new entry using the current task rules. The previous entry and any override remain in history.',
                  ),
                  _field(_reason, 'Reason for correction', requiredText: true),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      _saving
                          ? 'Saving on device…'
                          : correction
                          ? 'Save correction'
                          : 'Save on device',
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

  Widget _field(
    TextEditingController controller,
    String label, {
    bool requiredText = false,
    bool quantity = false,
  }) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextFormField(
      controller: controller,
      enabled: !_saving,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: quantity
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      onChanged: (_) => setState(() {}),
      validator: (value) {
        if (requiredText && (value == null || value.trim().isEmpty)) {
          return 'This field is required';
        }
        if (quantity) {
          final number = parseFixed(value ?? '');
          if (number == null || number > 1000000000) {
            return 'Enter 0–1,000,000 with up to 3 decimal places';
          }
        }
        return null;
      },
    ),
  );
}

Future<void> showOverrideSheet(
  BuildContext context,
  WidgetRef ref,
  Map<String, Object?> worker,
  String date,
) async {
  final reason = TextEditingController();
  final form = GlobalKey<FormState>();
  String status = 'present';
  bool saving = false;
  String? error;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => PopScope(
        canPop: !saving,
        child: AlertDialog(
          title: const Text('Override calculated result'),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'The facts and calculated result are retained. Only the final day classification changes; extra quantity and incentive calculations stay unchanged.',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    isExpanded: true,
                    items: ['present', 'half_day', 'absent']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(resultLabel(value)),
                          ),
                        )
                        .toList(),
                    onChanged: saving
                        ? null
                        : (value) => setState(() => status = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reason,
                    enabled: !saving,
                    decoration: const InputDecoration(
                      labelText: 'Required reason',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Explain why you are overriding the result'
                        : null,
                  ),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      setState(() => saving = true);
                      try {
                        await ref
                            .read(workRepositoryProvider)
                            .overrideResult(
                              workerId: worker['id'] as int,
                              date: date,
                              previousId: worker['event_id'] as String,
                              status: status,
                              reason: reason.text,
                              operatorId: ref.read(supervisorProvider),
                            );
                        ref.invalidate(attendanceProvider);
                        ref.invalidate(datedAttendanceProvider(date));
                        unawaited(SyncService.instance.saved());
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } catch (failure) {
                        if (context.mounted) {
                          setState(() {
                            saving = false;
                            error = failure.toString();
                          });
                        }
                      }
                    },
              child: Text(saving ? 'Saving…' : 'Save override'),
            ),
          ],
        ),
      ),
    ),
  );
  // The route's exit animation can still reference its controller.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  reason.dispose();
}
