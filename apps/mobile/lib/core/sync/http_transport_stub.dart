import 'sync_engine.dart';

class HttpSyncTransport implements SyncTransport {
  HttpSyncTransport(String endpoint, String token);
  @override
  Future<Set<String>> upload(List<Map<String, Object?>> events) =>
      throw UnsupportedError('Use the phone app to sync records.');
}
