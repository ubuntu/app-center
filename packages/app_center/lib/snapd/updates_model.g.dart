// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updates_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasUpdateHash() => r'2e6726976ec1efb4c3b8cecf2e82a74f3a3630f4';

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

/// See also [hasUpdate].
@ProviderFor(hasUpdate)
const hasUpdateProvider = HasUpdateFamily();

/// See also [hasUpdate].
class HasUpdateFamily extends Family<bool> {
  /// See also [hasUpdate].
  const HasUpdateFamily();

  /// See also [hasUpdate].
  HasUpdateProvider call(
    String snapName,
  ) {
    return HasUpdateProvider(
      snapName,
    );
  }

  @override
  HasUpdateProvider getProviderOverride(
    covariant HasUpdateProvider provider,
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
  String? get name => r'hasUpdateProvider';
}

/// See also [hasUpdate].
class HasUpdateProvider extends Provider<bool> {
  /// See also [hasUpdate].
  HasUpdateProvider(
    String snapName,
  ) : this._internal(
          (ref) => hasUpdate(
            ref as HasUpdateRef,
            snapName,
          ),
          from: hasUpdateProvider,
          name: r'hasUpdateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hasUpdateHash,
          dependencies: HasUpdateFamily._dependencies,
          allTransitiveDependencies: HasUpdateFamily._allTransitiveDependencies,
          snapName: snapName,
        );

  HasUpdateProvider._internal(
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
  Override overrideWith(
    bool Function(HasUpdateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HasUpdateProvider._internal(
        (ref) => create(ref as HasUpdateRef),
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
  ProviderElement<bool> createElement() {
    return _HasUpdateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasUpdateProvider && other.snapName == snapName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, snapName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin HasUpdateRef on ProviderRef<bool> {
  /// The parameter `snapName` of this provider.
  String get snapName;
}

class _HasUpdateProviderElement extends ProviderElement<bool>
    with HasUpdateRef {
  _HasUpdateProviderElement(super.provider);

  @override
  String get snapName => (origin as HasUpdateProvider).snapName;
}

String _$updatesModelHash() => r'e0e2fd3b821444f5d18dd12cfa5524171d41f33b';

/// See also [UpdatesModel].
@ProviderFor(UpdatesModel)
final updatesModelProvider =
    AsyncNotifierProvider<UpdatesModel, Iterable<Snap>>.internal(
  UpdatesModel.new,
  name: r'updatesModelProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$updatesModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UpdatesModel = AsyncNotifier<Iterable<Snap>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
