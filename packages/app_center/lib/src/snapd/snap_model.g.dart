// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snap_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$snapPackageHash() => r'bf2d0dc1312bf5d5a0e12dc5d13691cd00fd6024';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SnapPackage extends BuildlessAsyncNotifier<SnapData> {
  late final String snapName;

  FutureOr<SnapData> build(
    String snapName,
  );
}

/// See also [SnapPackage].
@ProviderFor(SnapPackage)
const snapPackageProvider = SnapPackageFamily();

/// See also [SnapPackage].
class SnapPackageFamily extends Family<AsyncValue<SnapData>> {
  /// See also [SnapPackage].
  const SnapPackageFamily();

  /// See also [SnapPackage].
  SnapPackageProvider call(
    String snapName,
  ) {
    return SnapPackageProvider(
      snapName,
    );
  }

  @override
  SnapPackageProvider getProviderOverride(
    covariant SnapPackageProvider provider,
  ) {
    return call(
      provider.snapName,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'snapPackageProvider';
}

/// See also [SnapPackage].
class SnapPackageProvider
    extends AsyncNotifierProviderImpl<SnapPackage, SnapData> {
  /// See also [SnapPackage].
  SnapPackageProvider(
    String snapName,
  ) : this._internal(
          () => SnapPackage()..snapName = snapName,
          from: snapPackageProvider,
          name: r'snapPackageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$snapPackageHash,
          dependencies: SnapPackageFamily._dependencies,
          allTransitiveDependencies:
              SnapPackageFamily._allTransitiveDependencies,
          snapName: snapName,
        );

  SnapPackageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.snapName,
  }) : super.internal();

  final String snapName;

  @override
  FutureOr<SnapData> runNotifierBuild(
    covariant SnapPackage notifier,
  ) {
    return notifier.build(
      snapName,
    );
  }

  @override
  Override overrideWith(SnapPackage Function() create) {
    return ProviderOverride(
      origin: this,
      override: SnapPackageProvider._internal(
        () => create()..snapName = snapName,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        snapName: snapName,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<SnapPackage, SnapData> createElement() {
    return _SnapPackageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SnapPackageProvider && other.snapName == snapName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, snapName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SnapPackageRef on AsyncNotifierProviderRef<SnapData> {
  /// The parameter `snapName` of this provider.
  String get snapName;
}

class _SnapPackageProviderElement
    extends AsyncNotifierProviderElement<SnapPackage, SnapData>
    with SnapPackageRef {
  _SnapPackageProviderElement(super.provider);

  @override
  String get snapName => (origin as SnapPackageProvider).snapName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
