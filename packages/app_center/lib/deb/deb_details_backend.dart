import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/current_desktops_provider.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'deb_details_backend.g.dart';

/// Live PackageKit mutations, including those started elsewhere in the app.
@riverpod
Stream<List<PackageKitMutation>> packageKitMutations(Ref ref) async* {
  final packageKit = getService<PackageKitService>();
  yield packageKit.activeMutations;
  await for (final _ in packageKit.mutationEvents) {
    yield packageKit.activeMutations;
  }
}

@riverpod
Future<ImageRef?> debIcon(Ref ref, String componentId) async {
  final component = await ref.watch(
    debModelProvider(componentId).selectAsync((data) => data.component),
  );
  final icon = await component.iconAsync;
  if (icon == null) return null;
  final uri = Uri.tryParse(icon);
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https')
      ? ImageRef.network(icon)
      : ImageRef.file(icon);
}

/// Details of exactly [packageId]; `getDetails` keys results by name only.
@riverpod
Future<PackageKitDetailsEvent?> debPackageDetails(
  Ref ref,
  PackageKitPackageId packageId,
) async {
  final details = await getService<PackageKitService>().getDetails([
    packageId,
  ]);
  final match = details[packageId.name];
  return match?.packageId == packageId ? match : null;
}

@riverpod
AsyncValue<PackageSourceSnapshot> debSourceSnapshot(
  Ref ref,
  String componentId,
) {
  final model = ref.watch(debModelProvider(componentId));
  final mutations =
      ref.watch(packageKitMutationsProvider).valueOrNull ?? const [];
  final icon = ref.watch(debIconProvider(componentId));
  final updateId = model.valueOrNull?.updatePackageId;
  final updateDetails = updateId == null
      ? null
      : ref.watch(debPackageDetailsProvider(updateId));
  final desktops = ref.watch(currentDesktopsProvider);

  return mapAsyncValue(
    model,
    (data) => debSnapshotFromData(
      data,
      mutations: mutations,
      icon: _fieldFromAsync(icon),
      updateSize: updateDetails == null
          ? FieldState<ByteSize>.unavailable()
          : _fieldFromAsync(updateDetails.whenData(_downloadSize)),
      currentDesktops: desktops,
    ),
  );
}

FieldState<T> _fieldFromAsync<T>(AsyncValue<T?> value) {
  if (value.hasValue) return FieldState.fromNullable(value.valueOrNull);
  return value.hasError ? FieldState<T>.failed() : FieldState<T>.loading();
}

// PackageKit's size for a package that is not installed is its download size.
ByteSize? _downloadSize(PackageKitDetailsEvent? details) {
  final size = details?.size;
  return size == null || size <= 0
      ? null
      : ByteSize(bytes: size, kind: SizeKind.download);
}

@visibleForTesting
PackageSourceSnapshot debSnapshotFromData(
  DebData data, {
  List<PackageKitMutation> mutations = const [],
  FieldState<ImageRef> icon = const FieldState<ImageRef>.unavailable(),
  FieldState<ByteSize> updateSize = const FieldState<ByteSize>.unavailable(),
  List<String> currentDesktops = const [],
}) {
  final component = data.component;
  final packageId = data.packageInfo?.packageId;
  final installed = data.isInstalled;

  PackageRelease? release(
    PackageKitPackageId? id, {
    FieldState<ByteSize> size = const FieldState<ByteSize>.unavailable(),
  }) => id == null
      ? null
      : PackageRelease(
          candidateId: id.toString(),
          version: id.version,
          size: size,
          releaseDate: FieldState.fromNullable(
            component.releases
                .firstWhereOrNull((r) => r.version == id.version)
                ?.date,
          ),
          confinement: AppConfinement.unrestricted,
        );

  final installedRelease = installed ? release(packageId) : null;
  final installCandidate = installed
      ? null
      : release(
          packageId,
          size: FieldState.fromNullable(_downloadSize(data.details)),
        );
  final updateCandidate = installed
      ? release(data.updatePackageId, size: updateSize)
      : null;

  final packageName = packageId?.name ?? component.package;
  final mutation = packageName == null
      ? null
      : mutations.firstWhereOrNull(
          (m) => !m.isTerminal && m.affects(packageName),
        );
  final ownTransaction = data.activeTransactionId;
  final ownMutation = mutations.firstWhereOrNull(
    (m) => m.transactionId == ownTransaction,
  );
  final kind = ownTransaction != null
      ? _ownOperationKind(data.activeTransactionKind, installed: installed)
      : mutation == null
      ? null
      : _mutationKind(mutation.kind);
  final percentage = (ownMutation ?? mutation)?.percentage;

  String? nonEmpty(String value) => value.isEmpty ? null : value;

  return PackageSourceSnapshot(
    key: SourceKey(format: PackageFormat.deb, id: data.id),
    installState: data.packageInfo == null
        ? InstallState.unknown
        : installed
        ? InstallState.installed
        : InstallState.notInstalled,
    appName: FieldState.fromNullable(nonEmpty(component.getLocalizedName())),
    icon: icon,
    summary: FieldState.fromNullable(
      nonEmpty(component.getLocalizedSummary()),
    ),
    description: FieldState.fromNullable(
      nonEmpty(component.getLocalizedDescription()) == null
          ? null
          : RichContent(
              text: component.getLocalizedDescription(),
              type: RichContentType.html,
            ),
    ),
    screenshots: FieldState.value(component.screenshotUrls),
    publisher: FieldState.fromNullable(
      nonEmpty(component.getLocalizedDeveloperName()) == null
          ? null
          : Publisher(name: component.getLocalizedDeveloperName()),
    ),
    categories: FieldState.value(appCategoriesFromFreedesktop(component)),
    confinement: const FieldState.value(AppConfinement.unrestricted),
    license: FieldState.fromNullable(component.projectLicense),
    links: FieldState.value(data.links ?? const {}),
    ageRating: FieldState.fromNullable(_ageRating(component)),
    languages: component.languages.isEmpty
        ? FieldState<List<String>>.unavailable()
        : FieldState.value(component.languages.map((l) => l.locale).toList()),
    installed: installedRelease,
    installCandidate: installCandidate,
    updateCandidate: updateCandidate,
    capabilities: PackageCapabilities(
      removeBlocked: component.isCompulsoryFor(currentDesktops)
          ? DisabledReason.protectedPackage
          : null,
    ),
    targets: [
      if (packageId != null)
        PackageTarget(
          id: packageId.name,
          label: packageId.name,
          isInstalled: installed,
          candidate: installedRelease ?? installCandidate,
        ),
    ],
    activeOperation: kind == null
        ? null
        : ObservedOperation(
            kind: kind,
            targetId: packageId?.name,
            progress: percentage == null ? null : percentage / 100,
            cancellable: ownTransaction != null,
          ),
  );
}

OperationKind _ownOperationKind(
  DebTransactionKind? kind, {
  required bool installed,
}) => switch (kind) {
  DebTransactionKind.install => OperationKind.install,
  DebTransactionKind.update => OperationKind.update,
  DebTransactionKind.remove => OperationKind.remove,
  null => installed ? OperationKind.update : OperationKind.install,
};

OperationKind _mutationKind(PackageKitMutationKind kind) => switch (kind) {
  PackageKitMutationKind.install ||
  PackageKitMutationKind.installLocal => OperationKind.install,
  PackageKitMutationKind.update => OperationKind.update,
  PackageKitMutationKind.remove => OperationKind.remove,
};

ContentRatingLevel? _ageRating(AppstreamComponent component) {
  final levels = component.contentRatings.values.expand((r) => r.values);
  if (component.contentRatings.isEmpty) return null;
  return ContentRatingLevel.values[levels.map((l) => l.index).maxOrNull ?? 0];
}

const _freedesktopCategories = {
  'AudioVideo': AppCategory.musicAndAudio,
  'Audio': AppCategory.musicAndAudio,
  'Music': AppCategory.musicAndAudio,
  'Video': AppCategory.photoAndVideo,
  'Photography': AppCategory.photoAndVideo,
  'Graphics': AppCategory.artAndDesign,
  '2DGraphics': AppCategory.artAndDesign,
  '3DGraphics': AppCategory.artAndDesign,
  'VectorGraphics': AppCategory.artAndDesign,
  'RasterGraphics': AppCategory.artAndDesign,
  'Development': AppCategory.development,
  'IDE': AppCategory.development,
  'Education': AppCategory.education,
  'Game': AppCategory.games,
  'Emulator': AppCategory.gameEmulators,
  'Office': AppCategory.productivity,
  'Email': AppCategory.productivity,
  'Science': AppCategory.science,
  'Chat': AppCategory.social,
  'InstantMessaging': AppCategory.social,
  'IRCClient': AppCategory.social,
  'Settings': AppCategory.personalisation,
  'DesktopSettings': AppCategory.personalisation,
  'System': AppCategory.utilities,
  'Utility': AppCategory.utilities,
  'Security': AppCategory.security,
  'Finance': AppCategory.finance,
  'News': AppCategory.newsAndWeather,
  'Dictionary': AppCategory.booksAndReference,
  'Documentation': AppCategory.booksAndReference,
  'Literature': AppCategory.booksAndReference,
};

/// Maps freedesktop menu categories onto App Center's taxonomy.
List<AppCategory> appCategoriesFromFreedesktop(AppstreamComponent component) =>
    component.categories
        .map((category) => _freedesktopCategories[category])
        .whereType<AppCategory>()
        .toSet()
        .toList();

class DebDetailsBackend implements PackageDetailsBackend {
  const DebDetailsBackend();

  @override
  ProviderListenable<AsyncValue<PackageSourceSnapshot>> snapshot(
    SourceKey key,
  ) => debSourceSnapshotProvider(key.id);

  @override
  Future<void> reconcile(Ref ref, SourceKey key) async {
    ref.invalidate(debModelProvider(key.id));
    await ref.read(debModelProvider(key.id).future);
  }

  @override
  Future<OperationOutcome> execute(
    Ref ref,
    SourceKey key,
    PackageCommand command,
  ) async {
    final data = await ref.read(debModelProvider(key.id).future);
    final notifier = ref.read(debModelProvider(key.id).notifier);
    if (data.packageInfo == null) return OperationOutcome.failed;

    final PackageKitMutationOutcome outcome;
    switch (command.kind) {
      case OperationKind.install:
        if (data.isInstalled) return OperationOutcome.failed;
        outcome = await notifier.installDeb();
      case OperationKind.update:
        final updateId = data.updatePackageId;
        if (updateId == null || '$updateId' != command.candidateId) {
          return OperationOutcome.failed;
        }
        outcome = await notifier.updateDeb(updateId: updateId);
      case OperationKind.remove:
        if (!data.isInstalled ||
            data.isCompulsoryFor(ref.read(currentDesktopsProvider))) {
          return OperationOutcome.failed;
        }
        outcome = await notifier.removeDeb();
      case OperationKind.switchChannel:
        return OperationOutcome.failed;
    }
    return switch (outcome) {
      PackageKitMutationOutcome.success => OperationOutcome.success,
      PackageKitMutationOutcome.cancelled => OperationOutcome.cancelled,
      PackageKitMutationOutcome.failed => OperationOutcome.failed,
    };
  }

  @override
  Future<void> cancel(Ref ref, SourceKey key) =>
      ref.read(debModelProvider(key.id).notifier).cancelTransaction();

  @override
  Future<void> open(Ref ref, SourceKey key) async =>
      throw const PackageBackendException('Opening debs is not supported');
}
