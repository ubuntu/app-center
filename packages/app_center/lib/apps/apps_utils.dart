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

enum AppLink {
  unknown,
  homepage,
  contact;

  factory AppLink.fromAppstream(AppstreamUrlType appstreamUrlType) =>
      switch (appstreamUrlType) {
        AppstreamUrlType.homepage => AppLink.homepage,
        AppstreamUrlType.contact => AppLink.contact,
        _ => AppLink.unknown,
      };
}

extension AppLinkL10n on AppLink {
  String localize(AppLocalizations l10n, AppMetadata data) {
    return switch (this) {
      AppLink.unknown => l10n.appUrlTypeUnknown,
      AppLink.homepage => l10n.appUrlTypeHomepage,
      AppLink.contact => l10n.appUrlTypeContact(data.publisher ?? ''),
    };
  }
}

/// Common metadata found between package types.
abstract class AppMetadata {
  String? get publisher;
  AppConfinement? get confinement;
  String? get license;
  String? get version;
  DateTime? get published;
  int? get downloadSize;
  Map<AppLink, String>? get links;
}

extension AppConfinementL10n on AppConfinement {
  String localize(AppLocalizations l10n) => switch (this) {
        AppConfinement.unrestricted => l10n.appConfinementUnrestricted,
        AppConfinement.classic => l10n.appConfinementClassic,
        AppConfinement.development => l10n.appConfinementDevelopment,
        AppConfinement.strict => l10n.appConfinementStrict,
        AppConfinement.unknown => l10n.appConfinementUnknown,
      };

  String? localizeTooltip(AppLocalizations l10n) => switch (this) {
        AppConfinement.unrestricted => l10n.appConfinementUnrestrictedTooltip,
        AppConfinement.classic => l10n.appConfinementClassicTooltip,
        AppConfinement.strict => l10n.appConfinementStrictTooltip,
        _ => null,
      };
}
