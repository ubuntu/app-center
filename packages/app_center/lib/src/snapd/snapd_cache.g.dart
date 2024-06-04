// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapd_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storeSnapHash() => r'5581a6b36de1739aacc416ea7f6f31edd370664e';

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

abstract class _$StoreSnap extends BuildlessAsyncNotifier<Snap?> {
  late final String snapName;

  FutureOr<Snap?> build(
    String snapName,
  );
}

/// See also [StoreSnap].
@ProviderFor(StoreSnap)
const storeSnapProvider = StoreSnapFamily();

/// See also [StoreSnap].
class StoreSnapFamily extends Family<AsyncValue<Snap?>> {
  /// See also [StoreSnap].
  const StoreSnapFamily();

  /// See also [StoreSnap].
  StoreSnapProvider call(
    String snapName,
  ) {
    return StoreSnapProvider(
      snapName,
    );
  }

  @override
  StoreSnapProvider getProviderOverride(
    covariant StoreSnapProvider provider,
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
  String? get name => r'storeSnapProvider';
}

/// See also [StoreSnap].
class StoreSnapProvider extends AsyncNotifierProviderImpl<StoreSnap, Snap?> {
  /// See also [StoreSnap].
  StoreSnapProvider(
    String snapName,
  ) : this._internal(
          () => StoreSnap()..snapName = snapName,
          from: storeSnapProvider,
          name: r'storeSnapProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$storeSnapHash,
          dependencies: StoreSnapFamily._dependencies,
          allTransitiveDependencies: StoreSnapFamily._allTransitiveDependencies,
          snapName: snapName,
        );

  StoreSnapProvider._internal(
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
  FutureOr<Snap?> runNotifierBuild(
    covariant StoreSnap notifier,
  ) {
    return notifier.build(
      snapName,
    );
  }

  @override
  Override overrideWith(StoreSnap Function() create) {
    return ProviderOverride(
      origin: this,
      override: StoreSnapProvider._internal(
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
  AsyncNotifierProviderElement<StoreSnap, Snap?> createElement() {
    return _StoreSnapProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreSnapProvider && other.snapName == snapName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, snapName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StoreSnapRef on AsyncNotifierProviderRef<Snap?> {
  /// The parameter `snapName` of this provider.
  String get snapName;
}

class _StoreSnapProviderElement
    extends AsyncNotifierProviderElement<StoreSnap, Snap?> with StoreSnapRef {
  _StoreSnapProviderElement(super.provider);

  @override
  String get snapName => (origin as StoreSnapProvider).snapName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
