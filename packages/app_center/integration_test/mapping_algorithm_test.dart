import 'package:app_center/appstream/appstream_service.dart';
import 'package:app_center/mapping/mapping.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:app_center/snapd/snapd_service.dart';
import 'package:flutter/widgets.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final snapd = SnapdService();
  final appstream = AppstreamService();

  final packageKit = PackageKitService(client: PackageKitClient());

  try {
    await snapd.loadAuthorization();
    await appstream.init();

    final snapAdapter = SnapPackageAdapter(snapd: snapd);

    final debAdapter = DebPackageAdapter(
      appstream: appstream,
      packageKit: packageKit,
    );

    final mapping = PackageMappingService(adapters: [snapAdapter, debAdapter]);

    final snaps = await snapd.getSnaps();
    final uniqueSnaps =
        <String, Snap>{
            for (final snap in snaps) snap.name: snap,
          }.values.toList()
          ..sort((first, second) => first.name.compareTo(second.name));

    const resolver = PackageMappingResolver();
    final found = <String>[];
    final notFound = <String>[];
    final errors = <String>[];

    for (final snap in uniqueSnaps) {
      try {
        final storeSource = await snapAdapter.findByPackageName(snap.name);
        if (storeSource == null) {
          notFound.add('${snap.name.padRight(28)} not in store');
          continue;
        }
        // Store results lack desktop files, so use the installed snap's.
        final source = storeSource.copyWith(
          commonIds: {...storeSource.commonIds, ...snap.commonIds}.toList(),
          desktopId: snap.apps
              .map((app) => app.desktopFile)
              .whereType<String>()
              .firstOrNull,
        );

        final identity = await mapping.resolve(source);
        final deb = identity?.getSource(PackageFormat.deb);
        if (identity == null || deb == null) {
          notFound.add(snap.name);
          continue;
        }

        final tier = resolver.matchTier(source, deb)?.name ?? '?';
        found.add(
          '${snap.name.padRight(28)} -> ${deb.packageId.padRight(28)} '
          '${tier.padRight(12)} ${identity.appStreamId}',
        );
      } on Object catch (error) {
        errors.add('${snap.name.padRight(28)} $error');
      }
    }

    final lines = [
      '',
      '=== Snap -> Debian mapping (${uniqueSnaps.length} installed snaps) ===',
      '',
      'FOUND (${found.length})',
      '  ${'SNAP'.padRight(28)}    ${'DEB'.padRight(28)} ${'TIER'.padRight(12)} APPSTREAM ID',
      ...found.map((line) => '  $line'),
      '',
      'NOT FOUND (${notFound.length})',
      ...notFound.map((line) => '  $line'),
      if (errors.isNotEmpty) ...[
        '',
        'ERRORS (${errors.length})',
        ...errors.map((line) => '  $line'),
      ],
      '',
      'Summary: ${found.length}/${uniqueSnaps.length} snaps matched',
      '',
    ];
    lines.forEach(debugPrint);
  } finally {
    snapd.close();
    await packageKit.dispose();
  }
}
