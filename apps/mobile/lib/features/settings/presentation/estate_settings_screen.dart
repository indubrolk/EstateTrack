import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/records/record_providers.dart';
import '../../../core/records/work_record.dart';
import '../../../core/records/work_repository.dart';
import '../../../core/sync/sync_service.dart';

class EstateSettingsScreen extends ConsumerWidget {
  const EstateSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(rulesProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      appBar: AppBar(
        title: const Text('Estate Settings'),
        backgroundColor: const Color(0xFFF7F9FF),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EDFF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task rules',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Set a rule for each task and unit. Changes create a new rule version and apply to new entries and corrections. Old records retain the rules originally used.',
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• At or above norm: full day\n• At or above half-day cut-off, below norm: half day\n• Below cut-off: needs review\n• Extra amount: quantity above norm × extra rate\n• At or above incentive threshold: eligible (no incentive payment amount is configured)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: SyncService.instance,
                builder: (context, _) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined),
                    title: const Text('Local storage & sync'),
                    subtitle: Text(
                      kIsWeb
                          ? 'Read-only browser preview'
                          : SyncService.instance.message,
                    ),
                    trailing: IconButton(
                      tooltip: 'Retry sync',
                      onPressed: kIsWeb
                          ? null
                          : () => SyncService.instance.sync(),
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: kIsWeb ? null : () => _edit(context, null),
                icon: const Icon(Icons.add),
                label: const Text('Add task rule'),
              ),
              const SizedBox(height: 16),
              rules.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => TextButton(
                  onPressed: () => ref.invalidate(rulesProvider),
                  child: const Text('Could not load rules. Try again.'),
                ),
                data: (versions) => versions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No task rules configured. Supervisors can save facts now; results wait for rules.',
                        ),
                      )
                    : Column(
                        children: [
                          for (final event in versions)
                            Builder(
                              builder: (context) {
                                final rule = WorkRule.fromJson(
                                  WorkRepository.payload(event)['rule']
                                      as Map<String, dynamic>,
                                );
                                return Card(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${rule.task} · ${rule.unit}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'Edit task rule',
                                              onPressed: () =>
                                                  _edit(context, event),
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Norm: ${formatFixed(rule.normMilli)} · Half-day cut-off: ${formatFixed(rule.halfDayCutoffMilli)}',
                                        ),
                                        Text(
                                          'Extra rate: ${formatFixed(rule.extraRateMinor, places: 2)} per ${rule.unit}',
                                        ),
                                        Text(
                                          'Incentive threshold: ${formatFixed(rule.incentiveThresholdMilli)} ${rule.unit}',
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Saved ${DateTime.parse(event['created_at'] as String).toLocal()}',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recording as ${ref.watch(supervisorProvider)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _edit(BuildContext context, Map<String, Object?>? event) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (context) => _RuleForm(event: event),
    );
  }
}

class _RuleForm extends ConsumerStatefulWidget {
  const _RuleForm({this.event});
  final Map<String, Object?>? event;
  @override
  ConsumerState<_RuleForm> createState() => _RuleFormState();
}

class _RuleFormState extends ConsumerState<_RuleForm> {
  final _form = GlobalKey<FormState>();
  final _fields = List.generate(6, (_) => TextEditingController());
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      final rule = WorkRule.fromJson(
        WorkRepository.payload(widget.event!)['rule'] as Map<String, dynamic>,
      );
      final values = [
        rule.task,
        rule.unit,
        formatFixed(rule.normMilli),
        formatFixed(rule.halfDayCutoffMilli),
        formatFixed(rule.extraRateMinor, places: 2),
        formatFixed(rule.incentiveThresholdMilli),
      ];
      for (var i = 0; i < values.length; i++) {
        _fields[i].text = values[i];
      }
    }
  }

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final rule = WorkRule(
        task: _fields[0].text,
        unit: _fields[1].text,
        normMilli: parseFixed(_fields[2].text)!,
        halfDayCutoffMilli: parseFixed(_fields[3].text)!,
        extraRateMinor: parseFixed(_fields[4].text, places: 2)!,
        incentiveThresholdMilli: parseFixed(_fields[5].text)!,
      );
      await ref
          .read(workRepositoryProvider)
          .saveRule(
            rule,
            operatorId: ref.read(supervisorProvider),
            previousId: widget.event?['event_id'] as String?,
          );
      ref.invalidate(rulesProvider);
      unawaited(SyncService.instance.saved());
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Task name',
      'Unit (kg, baskets, metres…)',
      'Full-day norm',
      'Half-day cut-off',
      'Extra rate per unit (estate currency)',
      'Incentive threshold',
    ];
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
                  widget.event == null ? 'Add task rule' : 'New rule version',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'All values are required. Quantities support 3 decimal places; the extra rate supports 2. The incentive threshold records eligibility only.',
                ),
                for (var i = 0; i < labels.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextFormField(
                      controller: _fields[i],
                      enabled: !_saving && !(widget.event != null && i < 2),
                      decoration: InputDecoration(
                        labelText: labels[i],
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: i < 2
                          ? TextInputType.text
                          : const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field is required';
                        }
                        if (i >= 2 &&
                            parseFixed(value, places: i == 4 ? 2 : 3) == null) {
                          return 'Enter a valid non-negative number';
                        }
                        return null;
                      },
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Saving…' : 'Save rule version'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
