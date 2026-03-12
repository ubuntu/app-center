import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:appstream/appstream.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';

part 'manage_app_data.freezed.dart';

/// Unified representation of an installed app (snap or deb) for the manage page.
sealed class ManageAppData {
  String get id;
  String get name;
  String? get iconUrl;
  bool get hasUpdate;
  bool get isLaunchable;
  DateTime? get installDate;
  int? get installedSize;
}

@freezed
class ManageSnapData with _$ManageSnapData implements ManageAppData {
  factory ManageSnapData({
    required Snap snap,
    @Default(false) bool hasUpdate,
    String? updateVersion,
  }) = _ManageSnapData;

  ManageSnapData._();

  @override
  String get id => snap.name;

  @override
  String get name => snap.titleOrName;

  @override
  String? get iconUrl => snap.iconUrl;

  @override
  bool get isLaunchable => snap.apps.isNotEmpty;

  @override
  DateTime? get installDate => snap.installDate;

  @override
  int? get installedSize => snap.installedSize;

  String get channel => snap.channel;
  String get version => snap.version;
}

@freezed
class ManageDebData with _$ManageDebData implements ManageAppData {
  factory ManageDebData({
    required AppstreamComponent component,
    required PackageKitPackageEvent packageInfo,
    @Default(false) bool hasUpdate,
    String? updateVersion,
    PackageKitPackageId? updatePackageId,
    int? size,
  }) = _ManageDebData;

  ManageDebData._();

  @override
  String get id => component.id;

  @override
  String get name => component.getLocalizedName();

  @override
  String? get iconUrl => component.icon;

  @override
  bool get isLaunchable => component.launchables
      .whereType<AppstreamLaunchableDesktopId>()
      .isNotEmpty;

  @override
  DateTime? get installDate =>
      null; // No clean way of getting this from info currently

  @override
  int? get installedSize => size;

  String get version => packageInfo.packageId.version;
}
