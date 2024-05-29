// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_deb_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LocalDebData {
  String get path => throw _privateConstructorUsedError;
  PackageKitDetailsEvent? get details => throw _privateConstructorUsedError;
  int? get activeTransactionId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LocalDebDataCopyWith<LocalDebData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalDebDataCopyWith<$Res> {
  factory $LocalDebDataCopyWith(
          LocalDebData value, $Res Function(LocalDebData) then) =
      _$LocalDebDataCopyWithImpl<$Res, LocalDebData>;
  @useResult
  $Res call(
      {String path, PackageKitDetailsEvent? details, int? activeTransactionId});
}

/// @nodoc
class _$LocalDebDataCopyWithImpl<$Res, $Val extends LocalDebData>
    implements $LocalDebDataCopyWith<$Res> {
  _$LocalDebDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? details = freezed,
    Object? activeTransactionId = freezed,
  }) {
    return _then(_value.copyWith(
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as PackageKitDetailsEvent?,
      activeTransactionId: freezed == activeTransactionId
          ? _value.activeTransactionId
          : activeTransactionId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocalDebDataImplCopyWith<$Res>
    implements $LocalDebDataCopyWith<$Res> {
  factory _$$LocalDebDataImplCopyWith(
          _$LocalDebDataImpl value, $Res Function(_$LocalDebDataImpl) then) =
      __$$LocalDebDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String path, PackageKitDetailsEvent? details, int? activeTransactionId});
}

/// @nodoc
class __$$LocalDebDataImplCopyWithImpl<$Res>
    extends _$LocalDebDataCopyWithImpl<$Res, _$LocalDebDataImpl>
    implements _$$LocalDebDataImplCopyWith<$Res> {
  __$$LocalDebDataImplCopyWithImpl(
      _$LocalDebDataImpl _value, $Res Function(_$LocalDebDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? details = freezed,
    Object? activeTransactionId = freezed,
  }) {
    return _then(_$LocalDebDataImpl(
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as PackageKitDetailsEvent?,
      activeTransactionId: freezed == activeTransactionId
          ? _value.activeTransactionId
          : activeTransactionId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$LocalDebDataImpl implements _LocalDebData {
  _$LocalDebDataImpl(
      {required this.path, required this.details, this.activeTransactionId});

  @override
  final String path;
  @override
  final PackageKitDetailsEvent? details;
  @override
  final int? activeTransactionId;

  @override
  String toString() {
    return 'LocalDebData(path: $path, details: $details, activeTransactionId: $activeTransactionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalDebDataImpl &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.activeTransactionId, activeTransactionId) ||
                other.activeTransactionId == activeTransactionId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, path, details, activeTransactionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalDebDataImplCopyWith<_$LocalDebDataImpl> get copyWith =>
      __$$LocalDebDataImplCopyWithImpl<_$LocalDebDataImpl>(this, _$identity);
}

abstract class _LocalDebData implements LocalDebData {
  factory _LocalDebData(
      {required final String path,
      required final PackageKitDetailsEvent? details,
      final int? activeTransactionId}) = _$LocalDebDataImpl;

  @override
  String get path;
  @override
  PackageKitDetailsEvent? get details;
  @override
  int? get activeTransactionId;
  @override
  @JsonKey(ignore: true)
  _$$LocalDebDataImplCopyWith<_$LocalDebDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
