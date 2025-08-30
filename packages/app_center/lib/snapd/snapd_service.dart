import 'dart:convert';
import 'dart:io';

import 'package:app_center/snapd/snapd_cache.dart';
import 'package:app_center/snapd/snapd_watcher.dart';
import 'package:snapd/snapd.dart';

class LocalRevisionInfo {
  const LocalRevisionInfo({
    required this.revision,
    required this.version,
    required this.active,
  });
  final int revision;
  final String version;
  final bool active;
}

class SnapdService extends SnapdClient with SnapdCache, SnapdWatcher {
  Future<void> waitChange(String changeId) =>
      watchChange(changeId).firstWhere((change) => change.ready);

  /// Returns true if there exists a non-active local revision that is older
  /// than the currently active revision. This matches snapd's notion of
  /// "previous" for the revert command.
  Future<bool> hasPreviousRevision(String name) async {
    final revisions = await getLocalRevisions(name);
    int? activeRev;
    for (final r in revisions) {
      if (r.active) {
        activeRev = r.revision;
        break;
      }
    }
    if (activeRev == null) return false;
    for (final r in revisions) {
      if (!r.active && r.revision < activeRev) {
        return true;
      }
    }
    return false;
  }

  /// Returns all locally installed revisions for [name].
  /// Uses snapd REST: GET /v2/snaps?select=all&name={name}.
  Future<List<LocalRevisionInfo>> getLocalRevisions(String name) async {
    final encodedName = Uri.encodeComponent(name);

    final httpClient = HttpClient();
    httpClient.connectionFactory = (uri, proxyHost, proxyPort) {
      final address = InternetAddress(
        '/var/run/snapd.socket',
        type: InternetAddressType.unix,
      );
      return Socket.startConnect(address, 0);
    };

    try {
      final httpRequest = await httpClient.get(
        'localhost',
        0,
        '/v2/snaps?select=all&snaps=$encodedName',
      );

      if (userAgent != null) {
        httpRequest.headers.set(HttpHeaders.userAgentHeader, userAgent!);
      }

      final response = await httpRequest.close();
      final body = await response.transform(utf8.decoder).join();
      final jsonResponse = json.decode(body) as Map<String, dynamic>;

      if (jsonResponse['type'] != 'sync') return const [];
      final result = jsonResponse['result'];
      if (result is! List) return const [];

      return result
          .whereType<Map<String, dynamic>>()
          .where((e) => e['name'] == name)
          .map((e) {
        final revVal = e['revision'];
        final revision = switch (revVal) {
          final int v => v,
          final num v => v.toInt(),
          final String s => int.tryParse(s) ?? 0,
          null => 0, // ignore: prefer_final_locals
          _ => 0,
        };
        final version = (e['version'] is String)
            ? e['version'] as String
            : '${e['version'] ?? ''}';
        final status = e['status'];
        final active = status == 'active'; // ignore: prefer_final_locals
        return LocalRevisionInfo(
          revision: revision,
          version: version,
          active: active,
        );
      }).toList();
    } finally {
      httpClient.close();
    }
  }

  /// Reverts the snap with the given [name] to its previous version.
  /// Returns the change ID for this operation, use [getChange] to get the
  /// status of this operation.
  ///
  /// This implementation manually calls the snapd API since the snapd.dart
  /// package doesn't yet support the revert action.
  Future<String> revert(String name) async {
    final request = <String, dynamic>{'action': 'revert'};
    final encodedName = Uri.encodeComponent(name);

    // Create a new HTTP client with Unix socket connection
    final httpClient = HttpClient();
    httpClient.connectionFactory = (uri, proxyHost, proxyPort) {
      final address = InternetAddress('/var/run/snapd.socket',
          type: InternetAddressType.unix);
      return Socket.startConnect(address, 0);
    };

    try {
      final httpRequest =
          await httpClient.post('localhost', 0, '/v2/snaps/$encodedName');

      // Set headers similar to SnapdClient
      if (userAgent != null) {
        httpRequest.headers.set(HttpHeaders.userAgentHeader, userAgent!);
      }
      if (allowInteraction) {
        httpRequest.headers.set('X-Allow-Interaction', 'true');
      }

      httpRequest.headers.contentType = ContentType('application', 'json');
      httpRequest.write(json.encode(request));
      await httpRequest.close();

      final response = await httpRequest.done;
      final body = await response.transform(utf8.decoder).join();
      final jsonResponse = json.decode(body);

      if (jsonResponse['type'] == 'async') {
        return jsonResponse['change'] as String;
      } else if (jsonResponse['type'] == 'error') {
        final result = jsonResponse['result'];
        throw SnapdException(
          kind: result['kind'] as String?,
          message: result['message'] as String? ?? '',
          status: jsonResponse['status'] as String,
          statusCode: jsonResponse['status-code'] as int,
        );
      } else {
        throw 'Unexpected response type: ${jsonResponse['type']}';
      }
    } finally {
      httpClient.close();
    }
  }
}
