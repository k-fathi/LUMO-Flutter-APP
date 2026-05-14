import 'dart:convert';
import 'dart:io';

class DebugLogger {
  static const String _sessionId = 'ae3196';
  static const String _logPath =
      '/home/karim/Documents/ECE-2026/GP/LUMO-Flutter-App/.cursor/debug-ae3196.log';
  static final Uri _endpoint = Uri.parse(
      'http://127.0.0.1:7761/ingest/3ca9c576-067f-4c7a-b78f-9cf2993838fc');

  static void log({
    required String runId,
    required String hypothesisId,
    required String location,
    required String message,
    Map<String, dynamic>? data,
  }) {
    final payload = <String, dynamic>{
      'sessionId': _sessionId,
      'runId': runId,
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': data ?? const <String, dynamic>{},
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Prefer file logging (fast). If it fails (permissions/sandbox), fallback to HTTP.
    try {
      File(_logPath).writeAsStringSync('${jsonEncode(payload)}\n',
          mode: FileMode.append, flush: true);
      return;
    } catch (_) {
      // ignore and fallback
    }

    try {
      final client = HttpClient();
      client.postUrl(_endpoint).then((req) {
        req.headers.contentType = ContentType.json;
        req.headers.set('X-Debug-Session-Id', _sessionId);
        req.write(jsonEncode(payload));
        return req.close();
      }).then((res) {
        res.drain();
      }).catchError((_) {});
    } catch (_) {
      // Never crash app due to debug logging.
    }
  }
}

