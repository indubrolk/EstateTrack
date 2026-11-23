import 'dart:convert';

String ruleKey(String task, String unit) =>
    jsonEncode([task.trim().toLowerCase(), unit.trim().toLowerCase()]);

/// Facts entered by a supervisor. Quantities use thousandths of the task unit
/// so saving, syncing and comparing values never depend on floating point math.
class WorkFacts {
  const WorkFacts({
    required this.workerId,
    required this.date,
    required this.attended,
    required this.task,
    required this.unit,
    required this.quantityMilli,
  });

  final int workerId;
  final String date;
  final bool attended;
  final String task;
  final String unit;
  final int quantityMilli;

  void validate() {
    validateTaskText(task, unit);
    final parsed = DateTime.tryParse(date);
    if (workerId <= 0 || parsed == null || date != dateKey(parsed)) {
      throw ArgumentError('A valid worker and work date are required.');
    }
    if (quantityMilli < 0 || quantityMilli > 1000000000) {
      throw ArgumentError('Quantity must be between 0 and 1,000,000.');
    }
    if (attended && (task.trim().isEmpty || unit.trim().isEmpty)) {
      throw ArgumentError('Choose a task and unit for a worker who attended.');
    }
    if (!attended &&
        (quantityMilli != 0 || task.isNotEmpty || unit.isNotEmpty)) {
      throw ArgumentError('An absent worker cannot have a task or quantity.');
    }
  }

  Map<String, Object?> toJson() => {
    'worker_id': workerId,
    'date': date,
    'attended': attended,
    'task': task.trim(),
    'unit': unit.trim(),
    'quantity_milli': quantityMilli,
  };

  factory WorkFacts.fromJson(Map<String, dynamic> json) => WorkFacts(
    workerId: json['worker_id'] as int,
    date: json['date'] as String,
    attended: json['attended'] as bool,
    task: json['task'] as String,
    unit: json['unit'] as String,
    quantityMilli: json['quantity_milli'] as int,
  );
}

String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Parse a non-negative decimal without silently rounding user input.
int? parseFixed(String input, {int places = 3}) {
  final text = input.trim();
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(text)) return null;
  final parts = text.split('.');
  final fraction = parts.length == 1 ? '' : parts[1];
  if (fraction.length > places) return null;
  return int.tryParse('${parts[0]}${fraction.padRight(places, '0')}');
}

String formatFixed(int value, {int places = 3}) {
  final digits = value.toString().padLeft(places + 1, '0');
  final whole = digits.substring(0, digits.length - places);
  final fraction = digits
      .substring(digits.length - places)
      .replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty ? whole : '$whole.$fraction';
}

/// A versioned estate policy. Saving a change creates another version; past
/// records retain their policy snapshot and are never recalculated in place.
class WorkRule {
  const WorkRule({
    required this.task,
    required this.unit,
    required this.normMilli,
    required this.halfDayCutoffMilli,
    required this.extraRateMinor,
    required this.incentiveThresholdMilli,
  });

  final String task;
  final String unit;
  final int normMilli;
  final int halfDayCutoffMilli;
  final int extraRateMinor;
  final int incentiveThresholdMilli;

  void validate() {
    validateTaskText(task, unit);
    if (task.trim().isEmpty || unit.trim().isEmpty) {
      throw ArgumentError('Task and unit are required.');
    }
    if (normMilli <= 0 ||
        halfDayCutoffMilli < 0 ||
        halfDayCutoffMilli > normMilli) {
      throw ArgumentError(
        'The norm must be positive and the half-day cut-off must be between zero and the norm.',
      );
    }
    if (extraRateMinor < 0 || incentiveThresholdMilli < 0) {
      throw ArgumentError('Rates and thresholds cannot be negative.');
    }
    if ([
      normMilli,
      halfDayCutoffMilli,
      extraRateMinor,
      incentiveThresholdMilli,
    ].any((value) => value > 1000000000)) {
      throw ArgumentError('Rule values are too large.');
    }
  }

  String get key => ruleKey(task, unit);

  Map<String, Object?> toJson() => {
    'task': task.trim(),
    'unit': unit.trim(),
    'norm_milli': normMilli,
    'half_day_cutoff_milli': halfDayCutoffMilli,
    'extra_rate_minor': extraRateMinor,
    'incentive_threshold_milli': incentiveThresholdMilli,
  };

  factory WorkRule.fromJson(Map<String, dynamic> json) => WorkRule(
    task: json['task'] as String,
    unit: json['unit'] as String,
    normMilli: json['norm_milli'] as int,
    halfDayCutoffMilli: json['half_day_cutoff_milli'] as int,
    extraRateMinor: json['extra_rate_minor'] as int,
    incentiveThresholdMilli: json['incentive_threshold_milli'] as int,
  );
}

class WorkOutcome {
  const WorkOutcome(
    this.status, {
    this.extraQuantityMilli = 0,
    this.extraPayMinor = 0,
    this.incentiveEligible = false,
  });

  final String status;
  final int extraQuantityMilli;
  final int extraPayMinor;
  final bool incentiveEligible;

  Map<String, Object?> toJson() => {
    'status': status,
    'extra_quantity_milli': extraQuantityMilli,
    'extra_pay_minor': extraPayMinor,
    'incentive_eligible': incentiveEligible,
  };
}

WorkOutcome calculateWork(WorkFacts facts, WorkRule? rule) {
  facts.validate();
  if (!facts.attended) return const WorkOutcome('absent');
  if (rule == null) return const WorkOutcome('pending_rules');
  rule.validate();
  if (facts.task.trim().toLowerCase() != rule.task.trim().toLowerCase() ||
      facts.unit.trim().toLowerCase() != rule.unit.trim().toLowerCase()) {
    throw ArgumentError('The rule must match the task and quantity unit.');
  }
  final quantity = facts.quantityMilli;
  final extra = quantity > rule.normMilli ? quantity - rule.normMilli : 0;
  return WorkOutcome(
    quantity >= rule.normMilli
        ? 'present'
        : quantity >= rule.halfDayCutoffMilli
        ? 'half_day'
        : 'review',
    extraQuantityMilli: extra,
    extraPayMinor: (extra * rule.extraRateMinor + 500) ~/ 1000,
    incentiveEligible: quantity >= rule.incentiveThresholdMilli,
  );
}

String resultLabel(String? status) => switch (status) {
  'present' => 'Full day',
  'half_day' => 'Half day',
  'absent' => 'Absent',
  'review' => 'Below cut-off · Needs review',
  'pending_rules' => 'Awaiting task rules',
  'legacy' => 'Legacy attendance · Record facts',
  _ => 'Not recorded',
};

void validateTaskText(String task, String unit) {
  if (task.length > 80 ||
      unit.length > 20 ||
      RegExp(r'[\x00-\x1f]').hasMatch('$task$unit')) {
    throw ArgumentError(
      'Use a task name up to 80 characters and a unit up to 20 characters, without line breaks.',
    );
  }
}
