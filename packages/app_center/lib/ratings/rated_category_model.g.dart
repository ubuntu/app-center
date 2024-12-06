// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rated_category_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ratedCategoryModelHash() =>
    r'5fad0c098fbb1b6f11ea7904a51da353c3826e84';

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

abstract class _$RatedCategoryModel
    extends BuildlessAutoDisposeAsyncNotifier<List<Snap>> {
  late final List<SnapCategoryEnum> categories;
  late final int numberOfSnaps;

  FutureOr<List<Snap>> build(
    List<SnapCategoryEnum> categories,
    int numberOfSnaps,
  );
}

/// See also [RatedCategoryModel].
@ProviderFor(RatedCategoryModel)
const ratedCategoryModelProvider = RatedCategoryModelFamily();

/// See also [RatedCategoryModel].
class RatedCategoryModelFamily extends Family<AsyncValue<List<Snap>>> {
  /// See also [RatedCategoryModel].
  const RatedCategoryModelFamily();

  /// See also [RatedCategoryModel].
  RatedCategoryModelProvider call(
    List<SnapCategoryEnum> categories,
    int numberOfSnaps,
  ) {
    return RatedCategoryModelProvider(
      categories,
      numberOfSnaps,
    );
  }

  @override
  RatedCategoryModelProvider getProviderOverride(
    covariant RatedCategoryModelProvider provider,
  ) {
    return call(
      provider.categories,
      provider.numberOfSnaps,
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
  String? get name => r'ratedCategoryModelProvider';
}

/// See also [RatedCategoryModel].
class RatedCategoryModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    RatedCategoryModel, List<Snap>> {
  /// See also [RatedCategoryModel].
  RatedCategoryModelProvider(
    List<SnapCategoryEnum> categories,
    int numberOfSnaps,
  ) : this._internal(
          () => RatedCategoryModel()
            ..categories = categories
            ..numberOfSnaps = numberOfSnaps,
          from: ratedCategoryModelProvider,
          name: r'ratedCategoryModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ratedCategoryModelHash,
          dependencies: RatedCategoryModelFamily._dependencies,
          allTransitiveDependencies:
              RatedCategoryModelFamily._allTransitiveDependencies,
          categories: categories,
          numberOfSnaps: numberOfSnaps,
        );

  RatedCategoryModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categories,
    required this.numberOfSnaps,
  }) : super.internal();

  final List<SnapCategoryEnum> categories;
  final int numberOfSnaps;

  @override
  FutureOr<List<Snap>> runNotifierBuild(
    covariant RatedCategoryModel notifier,
  ) {
    return notifier.build(
      categories,
      numberOfSnaps,
    );
  }

  @override
  Override overrideWith(RatedCategoryModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: RatedCategoryModelProvider._internal(
        () => create()
          ..categories = categories
          ..numberOfSnaps = numberOfSnaps,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categories: categories,
        numberOfSnaps: numberOfSnaps,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<RatedCategoryModel, List<Snap>>
      createElement() {
    return _RatedCategoryModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RatedCategoryModelProvider &&
        other.categories == categories &&
        other.numberOfSnaps == numberOfSnaps;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categories.hashCode);
    hash = _SystemHash.combine(hash, numberOfSnaps.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RatedCategoryModelRef on AutoDisposeAsyncNotifierProviderRef<List<Snap>> {
  /// The parameter `categories` of this provider.
  List<SnapCategoryEnum> get categories;

  /// The parameter `numberOfSnaps` of this provider.
  int get numberOfSnaps;
}

class _RatedCategoryModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<RatedCategoryModel,
        List<Snap>> with RatedCategoryModelRef {
  _RatedCategoryModelProviderElement(super.provider);

  @override
  List<SnapCategoryEnum> get categories =>
      (origin as RatedCategoryModelProvider).categories;
  @override
  int get numberOfSnaps => (origin as RatedCategoryModelProvider).numberOfSnaps;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
