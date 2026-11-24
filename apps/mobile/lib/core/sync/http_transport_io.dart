import 'dart:convert';
import 'dart:io';

import 'sync_engine.dart';

class HttpSyncTransport implements SyncTransport {
  HttpSyncTransport(String endpoint, this.token)
    : endpoint = Uri.parse(endpoint) {
    if (this.endpoint.scheme != 'https' &&
        !(this.endpoint.scheme == 'http' &&
            [
              'localhost',
              '127.0.0.1',
              '10.0.2.2',
            ].contains(this.endpoint.host))) {
      throw ArgumentError(
        'Sync requires HTTPS, except for a local development server.',
      );
    }
    if (token.isEmpty) throw ArgumentError('Sync credentials are required.');
  }
  final Uri endpoint;
  final String token;

  @override
  Future<Set<String>> upload(List<Map<String, Object?>> events) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      return await _upload(client, events).timeout(const Duration(seconds: 20));
    } finally {
      client.close(force: true);
    }
  }

  Future<Set<String>> _upload(
    HttpClient client,
    List<Map<String, Object?>> events,
  ) async {
    final request = await client.postUrl(endpoint);
    request.followRedirects = false;
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    request.write(
      jsonEncode({
        'events': events
            .map(
              (event) => {
                'event_id': event['event_id'],
                'stream_id': event['stream_id'],
                'previous_event_id': event['previous_event_id'],
                'kind': event['kind'],
                'created_at': event['created_at'],
                'payload': jsonDecode(event['payload'] as String),
              },
            )
            .toList(),
      }),
    );
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('Sync server returned ${response.statusCode}.');
    }
    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
      if (bytes.length > 1024 * 1024) {
        throw const FormatException('Sync response too large.');
      }
    }
    final data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return (data['accepted_ids'] as List).cast<String>().toSet();
  }
}
