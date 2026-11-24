import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../database/app_database.dart';
import '../records/record_ledger.dart';
import 'http_transport.dart';
import 'sync_engine.dart';

const _endpoint = String.fromEnvironment('ESTATE_SYNC_URL');
const _token = String.fromEnvironment('ESTATE_SYNC_TOKEN');
const _backgroundTask = 'com.estatetrack.recordSync';

@pragma('vm:entry-point')
void recordSyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (_endpoint.isEmpty || _token.isEmpty) return true;
    try {
      final ledger = RecordLedger(await AppDatabase.instance.database);
      await SyncEngine(ledger, HttpSyncTransport(_endpoint, _token)).flush();
      return true;
    } catch (_) {
      return false;
    }
  });
}

class SyncService extends ChangeNotifier with WidgetsBindingObserver {
  SyncService._();
  static final instance = SyncService._();
  Timer? _timer;
  bool _started = false;
  bool _busy = false;
  int pending = 0;
  String message = 'Saved on this device';
  bool get configured => _endpoint.isNotEmpty && _token.isNotEmpty;
  bool get mobile =>
      !kIsWeb &&
      [
        TargetPlatform.android,
        TargetPlatform.iOS,
      ].contains(defaultTargetPlatform);
  bool _backgroundReady = false;

  Future<void> start() async {
    if (_started || kIsWeb) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    if (configured && mobile) {
      try {
        await Workmanager().initialize(recordSyncDispatcher);
        await Workmanager().registerPeriodicTask(
          _backgroundTask,
          _backgroundTask,
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
        );
        _backgroundReady = true;
      } catch (_) {
        // Foreground retries continue if this device cannot schedule background work.
        _backgroundReady = false;
      }
    }
    if (!_started) return;
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(sync()),
    );
    await sync();
  }

  Future<void> saved() async {
    // The database has committed before scheduling or making any network call.
    if (_backgroundReady && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await Workmanager().registerOneOffTask(
          'estate-record-upload',
          _backgroundTask,
          constraints: Constraints(networkType: NetworkType.connected),
        );
      } catch (_) {
        /* The durable queue and periodic retry remain intact. */
      }
    }
    await sync();
  }

  Future<void> sync() async {
    if (_busy || kIsWeb) return;
    _busy = true;
    var localRecordsAvailable = false;
    try {
      final ledger = RecordLedger(await AppDatabase.instance.database);
      pending = await ledger.pendingCount();
      localRecordsAvailable = true;
      if (!configured) {
        message = '$pending queued · Sync server not configured';
      } else {
        message = pending == 0
            ? 'All records synced'
            : 'Syncing $pending records…';
        notifyListeners();
        await SyncEngine(ledger, HttpSyncTransport(_endpoint, _token)).flush();
        pending = await ledger.pendingCount();
        message = pending == 0
            ? 'All records synced'
            : '$pending records queued';
        if (mobile && !_backgroundReady) {
          message += ' · Background sync unavailable';
        }
      }
    } catch (_) {
      message = localRecordsAvailable
          ? '$pending queued · Saved locally, retrying automatically'
          : 'Local records could not be read. Please retry.';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(sync());
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  void stop() {
    _started = false;
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
  }
}
