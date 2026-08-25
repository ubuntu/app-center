import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';

part 'drivers_data.freezed.dart';

/// The support branch of a driver package, derived from its `support` field.
/// `legacy` and `unknown` are not user-selectable.
enum DriverBranch {
  production,
  lts,
  newFeature,
  legacy,
  unknown;

  /// Parses the `support` field returned by the `com.ubuntu.Drivers` service.
  factory DriverBranch.fromSupport(String support) => switch (support) {
    'PB' => DriverBranch.production,
    'LTSB' => DriverBranch.lts,
    'NFB' => DriverBranch.newFeature,
    'Legacy' => DriverBranch.legacy,
    _ => DriverBranch.unknown,
  };

  /// Whether this branch is offered as a choice in the "Switch branch" dialog.
  bool get isSelectable => switch (this) {
    DriverBranch.production ||
    DriverBranch.lts ||
    DriverBranch.newFeature => true,
    DriverBranch.legacy || DriverBranch.unknown => false,
  };

  /// Relative stability, highest is most stable. Only meaningful for
  /// [isSelectable] branches; used to warn when switching to a less stable
  /// branch than the currently-installed one.
  int get stabilityRank => switch (this) {
    DriverBranch.lts => 2,
    DriverBranch.production => 1,
    DriverBranch.newFeature => 0,
    DriverBranch.legacy || DriverBranch.unknown => -1,
  };
}

/// The general category of hardware a [DriverDeviceInfo] represents, derived
/// from its `modalias`. Icon/label mapping is left to the UI layer.
enum DriverDeviceClass {
  graphics,
  network,
  camera,
  usb,
  storage,
  audio,
  other;

  /// Derives a [DriverDeviceClass] from a `modalias` string. Falls back to
  /// [other] for unrecognized or empty input rather than throwing.
  factory DriverDeviceClass.fromModalias(String modalias) {
    try {
      if (modalias.startsWith('pci:')) {
        final match = RegExp('bc([0-9A-Fa-f]{2})').firstMatch(modalias);
        final code = match != null
            ? int.parse(match.group(1)!, radix: 16)
            : null;
        return _pciBaseClasses[code] ?? DriverDeviceClass.other;
      }
      if (modalias.startsWith('usb:')) {
        final match = RegExp('ic([0-9A-Fa-f]{2})').firstMatch(modalias);
        final code = match != null
            ? int.parse(match.group(1)!, radix: 16)
            : null;
        return _usbInterfaceClasses[code] ?? DriverDeviceClass.other;
      }
    } on FormatException {
      // Fall through to `other` below.
    }
    return DriverDeviceClass.other;
  }

  /// PCI base class codes (`bc` field of a `pci:` modalias).
  static const _pciBaseClasses = {
    0x01: DriverDeviceClass.storage,
    0x02: DriverDeviceClass.network,
    0x03: DriverDeviceClass.graphics,
    0x04: DriverDeviceClass.audio,
    0x0c: DriverDeviceClass.usb,
  };

  /// USB interface class codes (`ic` field of a `usb:` modalias).
  static const _usbInterfaceClasses = {
    0x01: DriverDeviceClass.audio,
    0x03: DriverDeviceClass.other,
    0x0e: DriverDeviceClass.camera,
    0xe0: DriverDeviceClass.network,
  };
}

/// Which section of the drivers page a [DriverDeviceInfo] belongs to.
enum DriverSection { updateAvailable, installed, available }

/// A single installable branch for a [DriverDeviceInfo]: a driver candidate
/// reported by `com.ubuntu.Drivers` combined with its PackageKit state.
@freezed
class DriverBranchOption with _$DriverBranchOption {
  const factory DriverBranchOption({
    required DriverBranch branch,
    required String packageName,
    required bool recommended,
    PackageKitPackageId? packageId,
    @Default(false) bool isInstalled,
    @Default(false) bool hasUpdate,
  }) = _DriverBranchOption;

  const DriverBranchOption._();

  String? get version => packageId?.version;
}

/// A hardware device detected by `com.ubuntu.Drivers`, enriched with
/// PackageKit install state for each candidate driver package.
@freezed
class DriverDeviceInfo with _$DriverDeviceInfo {
  const factory DriverDeviceInfo({
    required String sysPath,
    required String vendor,
    required String model,
    required DriverDeviceClass deviceClass,
    required List<DriverBranchOption> options,
  }) = _DriverDeviceInfo;

  const DriverDeviceInfo._();

  /// The currently-installed option, if any.
  DriverBranchOption? get installedOption =>
      options.firstWhereOrNull((o) => o.isInstalled);

  /// Options selectable in a "Switch branch" dialog: one representative
  /// per selectable [DriverBranch], since multiple packages may satisfy the
  /// same branch (e.g. an open-source variant alongside the proprietary
  /// one). The dialog presents branches, not packages, so we pick a single
  /// package to act "for" the user in that case - see
  /// [_pickBranchRepresentative].
  List<DriverBranchOption> get branchOptions {
    final selectable = options.where((o) => o.branch.isSelectable);
    final byBranch = groupBy(selectable, (o) => o.branch);
    return byBranch.values.map(_pickBranchRepresentative).toList();
  }

  /// Chooses which package represents a branch when more than one option
  /// shares it: the installed one takes priority (so the dialog reflects
  /// what's actually on the system), then the recommended one, otherwise
  /// the first candidate reported for that branch.
  static DriverBranchOption _pickBranchRepresentative(
    List<DriverBranchOption> optionsForBranch,
  ) =>
      optionsForBranch.firstWhereOrNull((o) => o.isInstalled) ??
      optionsForBranch.firstWhereOrNull((o) => o.recommended) ??
      optionsForBranch.first;

  /// Whether install/switch should go through a branch-choice dialog rather
  /// than a single button.
  bool get hasBranchChoice => branchOptions.length > 1;

  DriverSection get section {
    if (options.any((o) => o.isInstalled && o.hasUpdate)) {
      return DriverSection.updateAvailable;
    }
    if (installedOption != null) {
      return DriverSection.installed;
    }
    return DriverSection.available;
  }
}

/// The full set of devices with installable drivers, as fetched and enriched
/// by the drivers list provider.
@freezed
class DriverList with _$DriverList {
  const factory DriverList({
    required Map<String, DriverDeviceInfo> byPath,
    required List<String> sysPaths,
  }) = _DriverList;
}
