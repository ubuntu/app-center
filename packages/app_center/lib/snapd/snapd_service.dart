import 'dart:convert';
import 'dart:io';

import 'package:app_center/snapd/snapd_cache.dart';
import 'package:app_center/snapd/snapd_watcher.dart';
import 'package:snapd/snapd.dart';

class SnapdService extends SnapdClient with SnapdCache, SnapdWatcher {
  Future<void> waitChange(String changeId) =>
      watchChange(changeId).firstWhere((change) => change.ready);

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
      final address = InternetAddress('/var/run/snapd.socket', type: InternetAddressType.unix);
      return Socket.startConnect(address, 0);
    };

    try {
      final httpRequest = await httpClient.post('localhost', 0, '/v2/snaps/$encodedName');

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
