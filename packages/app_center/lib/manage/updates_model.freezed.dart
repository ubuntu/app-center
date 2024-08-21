// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'updates_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SnapListState {
  Iterable<Snap> get snaps => throw _privateConstructorUsedError;
  bool get hasInternet => throw _privateConstructorUsedError;

  /// Create a copy of SnapListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnapListStateCopyWith<SnapListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnapListStateCopyWith<$Res> {
  factory $SnapListStateCopyWith(
          SnapListState value, $Res Function(SnapListState) then) =
      _$SnapListStateCopyWithImpl<$Res, SnapListState>;
  @useResult
  $Res call({Iterable<Snap> snaps, bool hasInternet});
}

/// @nodoc
class _$SnapListStateCopyWithImpl<$Res, $Val extends SnapListState>
    implements $SnapListStateCopyWith<$Res> {
  _$SnapListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnapListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? snaps = null,
    Object? hasInternet = null,
  }) {
    return _then(_value.copyWith(
      snaps: null == snaps
          ? _value.snaps
          : snaps // ignore: cast_nullable_to_non_nullable
              as Iterable<Snap>,
      hasInternet: null == hasInternet
          ? _value.hasInternet
          : hasInternet // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$snapListStateImplCopyWith<$Res>
    implements $SnapListStateCopyWith<$Res> {
  factory _$$snapListStateImplCopyWith(
          _$snapListStateImpl value, $Res Function(_$snapListStateImpl) then) =
      __$$snapListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Iterable<Snap> snaps, bool hasInternet});
}

/// @nodoc
class __$$snapListStateImplCopyWithImpl<$Res>
    extends _$SnapListStateCopyWithImpl<$Res, _$snapListStateImpl>
    implements _$$snapListStateImplCopyWith<$Res> {
  __$$snapListStateImplCopyWithImpl(
      _$snapListStateImpl _value, $Res Function(_$snapListStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnapListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? snaps = null,
    Object? hasInternet = null,
  }) {
    return _then(_$snapListStateImpl(
      snaps: null == snaps
          ? _value.snaps
          : snaps // ignore: cast_nullable_to_non_nullable
              as Iterable<Snap>,
      hasInternet: null == hasInternet
          ? _value.hasInternet
          : hasInternet // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$snapListStateImpl extends _snapListState {
  _$snapListStateImpl({this.snaps = const [], this.hasInternet = true})
      : super._();

  @override
  @JsonKey()
  final Iterable<Snap> snaps;
  @override
  @JsonKey()
  final bool hasInternet;

  @override
  String toString() {
    return 'SnapListState(snaps: $snaps, hasInternet: $hasInternet)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$snapListStateImpl &&
            const DeepCollectionEquality().equals(other.snaps, snaps) &&
            (identical(other.hasInternet, hasInternet) ||
                other.hasInternet == hasInternet));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(snaps), hasInternet);

  /// Create a copy of SnapListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$snapListStateImplCopyWith<_$snapListStateImpl> get copyWith =>
      __$$snapListStateImplCopyWithImpl<_$snapListStateImpl>(this, _$identity);
}

abstract class _snapListState extends SnapListState {
  factory _snapListState({final Iterable<Snap> snaps, final bool hasInternet}) =
      _$snapListStateImpl;
  _snapListState._() : super._();

  @override
  Iterable<Snap> get snaps;
  @override
  bool get hasInternet;

  /// Create a copy of SnapListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$snapListStateImplCopyWith<_$snapListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
