import 'package:dbus/dbus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mediaSupportInstallationFinishedProvider =
    Provider<Future<void> Function()>(
      (ref) => () async {
        final client = DBusClient.session();
        try {
          final object = DBusObject(
            DBusObjectPath('/io/snapcraft/Store/PackageKitInstaller/GStreamer'),
          );
          await client.registerObject(object);
          // The session installer completes all pending requests on this signal.
          await object.emitSignal(
            'io.snapcraft.Store.PackageKitInstaller',
            'InstallationFinished',
            [DBusArray.string([])],
          );
        } finally {
          await client.close();
        }
      },
    );
