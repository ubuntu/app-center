// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_deb_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localDebModelHash() => r'a5436611cd350a341c76ff157dee2ce53d29d7f1';

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

abstract class _$LocalDebModel
    extends BuildlessAutoDisposeAsyncNotifier<LocalDebData> {
  late final String path;

  FutureOr<LocalDebData> build({
    required String path,
  });
}

/// See also [LocalDebModel].
@ProviderFor(LocalDebModel)
const localDebModelProvider = LocalDebModelFamily();

/// See also [LocalDebModel].
class LocalDebModelFamily extends Family<AsyncValue<LocalDebData>> {
  /// See also [LocalDebModel].
  const LocalDebModelFamily();

  /// See also [LocalDebModel].
  LocalDebModelProvider call({
    required String path,
  }) {
    return LocalDebModelProvider(
      path: path,
    );
  }

  @override
  LocalDebModelProvider getProviderOverride(
    covariant LocalDebModelProvider provider,
  ) {
    return call(
      path: provider.path,
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
  String? get name => r'localDebModelProvider';
}

/// See also [LocalDebModel].
class LocalDebModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<LocalDebModel, LocalDebData> {
  /// See also [LocalDebModel].
  LocalDebModelProvider({
    required String path,
  }) : this._internal(
          () => LocalDebModel()..path = path,
          from: localDebModelProvider,
          name: r'localDebModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$localDebModelHash,
          dependencies: LocalDebModelFamily._dependencies,
          allTransitiveDependencies:
              LocalDebModelFamily._allTransitiveDependencies,
          path: path,
        );

  LocalDebModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
  }) : super.internal();

  final String path;

  @override
  FutureOr<LocalDebData> runNotifierBuild(
    covariant LocalDebModel notifier,
  ) {
    return notifier.build(
      path: path,
    );
  }

  @override
  Override overrideWith(LocalDebModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: LocalDebModelProvider._internal(
        () => create()..path = path,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        path: path,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<LocalDebModel, LocalDebData>
      createElement() {
    return _LocalDebModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalDebModelProvider && other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LocalDebModelRef on AutoDisposeAsyncNotifierProviderRef<LocalDebData> {
  /// The parameter `path` of this provider.
  String get path;
}

class _LocalDebModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<LocalDebModel, LocalDebData>
    with LocalDebModelRef {
  _LocalDebModelProviderElement(super.provider);

  @override
  String get path => (origin as LocalDebModelProvider).path;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
