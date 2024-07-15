// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snap_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$snapModelHash() => r'f60bf571ef6e34fbe0db06a6c6d45130d459c5c5';

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

abstract class _$SnapModel extends BuildlessAsyncNotifier<SnapData> {
  late final String snapName;

  FutureOr<SnapData> build(
    String snapName,
  );
}

/// See also [SnapModel].
@ProviderFor(SnapModel)
const snapModelProvider = SnapModelFamily();

/// See also [SnapModel].
class SnapModelFamily extends Family<AsyncValue<SnapData>> {
  /// See also [SnapModel].
  const SnapModelFamily();

  /// See also [SnapModel].
  SnapModelProvider call(
    String snapName,
  ) {
    return SnapModelProvider(
      snapName,
    );
  }

  @override
  SnapModelProvider getProviderOverride(
    covariant SnapModelProvider provider,
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
  String? get name => r'snapModelProvider';
}

/// See also [SnapModel].
class SnapModelProvider extends AsyncNotifierProviderImpl<SnapModel, SnapData> {
  /// See also [SnapModel].
  SnapModelProvider(
    String snapName,
  ) : this._internal(
          () => SnapModel()..snapName = snapName,
          from: snapModelProvider,
          name: r'snapModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$snapModelHash,
          dependencies: SnapModelFamily._dependencies,
          allTransitiveDependencies: SnapModelFamily._allTransitiveDependencies,
          snapName: snapName,
        );

  SnapModelProvider._internal(
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
    covariant SnapModel notifier,
  ) {
    return notifier.build(
      snapName,
    );
  }

  @override
  Override overrideWith(SnapModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: SnapModelProvider._internal(
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
  AsyncNotifierProviderElement<SnapModel, SnapData> createElement() {
    return _SnapModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SnapModelProvider && other.snapName == snapName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, snapName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SnapModelRef on AsyncNotifierProviderRef<SnapData> {
  /// The parameter `snapName` of this provider.
  String get snapName;
}

class _SnapModelProviderElement
    extends AsyncNotifierProviderElement<SnapModel, SnapData>
    with SnapModelRef {
  _SnapModelProviderElement(super.provider);

  @override
  String get snapName => (origin as SnapModelProvider).snapName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
