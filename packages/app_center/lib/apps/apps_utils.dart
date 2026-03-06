import 'package:app_center/l10n.dart';
import 'package:appstream/appstream.dart';
import 'package:snapd/snapd.dart';

enum AppConfinement {
  unknown,
  strict,
  development,
  classic,
  unrestricted;

  factory AppConfinement.fromSnap(SnapConfinement confinement) =>
      switch (confinement) {
        SnapConfinement.unknown => AppConfinement.unknown,
        SnapConfinement.strict => AppConfinement.strict,
        SnapConfinement.devmode => AppConfinement.development,
        SnapConfinement.classic => AppConfinement.classic,
      };

  factory AppConfinement.fromDeb() => AppConfinement.unrestricted;
}

/// Common metadata found between package types.
abstract class AppMetadata {
  String? get publisher;
  AppConfinement? get confinement;
  String? get license;
  String? get version;
  DateTime? get published;
  int? get downloadSize;
  Map<AppstreamUrlType, String>? get links;
}

extension SnapConfinementL10n on AppConfinement {
  String localize(AppLocalizations l10n) => switch (this) {
        AppConfinement.classic => l10n.snapConfinementClassic,
        AppConfinement.development => l10n.snapConfinementDevmode,
        AppConfinement.strict => l10n.snapConfinementStrict,
        _ => name,
      };
}
