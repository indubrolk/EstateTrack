import '../records/record_ledger.dart';

abstract interface class SyncTransport {
  Future<Set<String>> upload(List<Map<String, Object?>> events);
}

class SyncEngine {
  SyncEngine(this.ledger, this.transport);
  final RecordLedger ledger;
  final SyncTransport transport;
  Future<void>? _running;

  Future<void> flush() =>
      _running ??= _flush().whenComplete(() => _running = null);

  Future<void> _flush() async {
    // Bound one background run. Any remaining entries stay durable for retry.
    for (var batch = 0; batch < 10; batch++) {
      final events = await ledger.pending();
      if (events.isEmpty) return;
      final ids = events.map((entry) => entry['event_id'] as String).toSet();
      try {
        final accepted = await transport
            .upload(events)
            .timeout(const Duration(seconds: 25));
        if (!ids.containsAll(accepted)) {
          throw StateError('Server acknowledged unknown records.');
        }
        await ledger.acknowledge(accepted);
        if (accepted.length != ids.length) {
          throw StateError(
            'Some records were not acknowledged. They remain queued.',
          );
        }
      } catch (error) {
        await ledger.recordFailure(ids, 'Upload failed; waiting to retry.');
        rethrow;
      }
    }
  }
}
