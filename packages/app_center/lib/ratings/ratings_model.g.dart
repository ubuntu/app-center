// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ratings_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ratingsModelHash() => r'5648d0344240bc70bc3ea5e20a72cdcef9f6f8a0';

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

abstract class _$RatingsModel
    extends BuildlessAutoDisposeAsyncNotifier<RatingsData> {
  late final String snapName;

  FutureOr<RatingsData> build(
    String snapName,
  );
}

/// See also [RatingsModel].
@ProviderFor(RatingsModel)
const ratingsModelProvider = RatingsModelFamily();

/// See also [RatingsModel].
class RatingsModelFamily extends Family<AsyncValue<RatingsData>> {
  /// See also [RatingsModel].
  const RatingsModelFamily();

  /// See also [RatingsModel].
  RatingsModelProvider call(
    String snapName,
  ) {
    return RatingsModelProvider(
      snapName,
    );
  }

  @override
  RatingsModelProvider getProviderOverride(
    covariant RatingsModelProvider provider,
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
  String? get name => r'ratingsModelProvider';
}

/// See also [RatingsModel].
class RatingsModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<RatingsModel, RatingsData> {
  /// See also [RatingsModel].
  RatingsModelProvider(
    String snapName,
  ) : this._internal(
          () => RatingsModel()..snapName = snapName,
          from: ratingsModelProvider,
          name: r'ratingsModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ratingsModelHash,
          dependencies: RatingsModelFamily._dependencies,
          allTransitiveDependencies:
              RatingsModelFamily._allTransitiveDependencies,
          snapName: snapName,
        );

  RatingsModelProvider._internal(
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
  FutureOr<RatingsData> runNotifierBuild(
    covariant RatingsModel notifier,
  ) {
    return notifier.build(
      snapName,
    );
  }

  @override
  Override overrideWith(RatingsModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: RatingsModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<RatingsModel, RatingsData>
      createElement() {
    return _RatingsModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RatingsModelProvider && other.snapName == snapName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, snapName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RatingsModelRef on AutoDisposeAsyncNotifierProviderRef<RatingsData> {
  /// The parameter `snapName` of this provider.
  String get snapName;
}

class _RatingsModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<RatingsModel, RatingsData>
    with RatingsModelRef {
  _RatingsModelProviderElement(super.provider);

  @override
  String get snapName => (origin as RatingsModelProvider).snapName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
