// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ratings_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RatingsData {
  String get snapId => throw _privateConstructorUsedError;
  int get snapRevision => throw _privateConstructorUsedError;
  Rating? get rating => throw _privateConstructorUsedError;
  VoteStatus? get voteStatus => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RatingsDataCopyWith<RatingsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RatingsDataCopyWith<$Res> {
  factory $RatingsDataCopyWith(
          RatingsData value, $Res Function(RatingsData) then) =
      _$RatingsDataCopyWithImpl<$Res, RatingsData>;
  @useResult
  $Res call(
      {String snapId,
      int snapRevision,
      Rating? rating,
      VoteStatus? voteStatus});
}

/// @nodoc
class _$RatingsDataCopyWithImpl<$Res, $Val extends RatingsData>
    implements $RatingsDataCopyWith<$Res> {
  _$RatingsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? snapId = null,
    Object? snapRevision = null,
    Object? rating = freezed,
    Object? voteStatus = freezed,
  }) {
    return _then(_value.copyWith(
      snapId: null == snapId
          ? _value.snapId
          : snapId // ignore: cast_nullable_to_non_nullable
              as String,
      snapRevision: null == snapRevision
          ? _value.snapRevision
          : snapRevision // ignore: cast_nullable_to_non_nullable
              as int,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as Rating?,
      voteStatus: freezed == voteStatus
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as VoteStatus?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RatingsDataImplCopyWith<$Res>
    implements $RatingsDataCopyWith<$Res> {
  factory _$$RatingsDataImplCopyWith(
          _$RatingsDataImpl value, $Res Function(_$RatingsDataImpl) then) =
      __$$RatingsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String snapId,
      int snapRevision,
      Rating? rating,
      VoteStatus? voteStatus});
}

/// @nodoc
class __$$RatingsDataImplCopyWithImpl<$Res>
    extends _$RatingsDataCopyWithImpl<$Res, _$RatingsDataImpl>
    implements _$$RatingsDataImplCopyWith<$Res> {
  __$$RatingsDataImplCopyWithImpl(
      _$RatingsDataImpl _value, $Res Function(_$RatingsDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? snapId = null,
    Object? snapRevision = null,
    Object? rating = freezed,
    Object? voteStatus = freezed,
  }) {
    return _then(_$RatingsDataImpl(
      snapId: null == snapId
          ? _value.snapId
          : snapId // ignore: cast_nullable_to_non_nullable
              as String,
      snapRevision: null == snapRevision
          ? _value.snapRevision
          : snapRevision // ignore: cast_nullable_to_non_nullable
              as int,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as Rating?,
      voteStatus: freezed == voteStatus
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as VoteStatus?,
    ));
  }
}

/// @nodoc

class _$RatingsDataImpl implements _RatingsData {
  const _$RatingsDataImpl(
      {required this.snapId,
      required this.snapRevision,
      required this.rating,
      required this.voteStatus});

  @override
  final String snapId;
  @override
  final int snapRevision;
  @override
  final Rating? rating;
  @override
  final VoteStatus? voteStatus;

  @override
  String toString() {
    return 'RatingsData(snapId: $snapId, snapRevision: $snapRevision, rating: $rating, voteStatus: $voteStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RatingsDataImpl &&
            (identical(other.snapId, snapId) || other.snapId == snapId) &&
            (identical(other.snapRevision, snapRevision) ||
                other.snapRevision == snapRevision) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.voteStatus, voteStatus) ||
                other.voteStatus == voteStatus));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, snapId, snapRevision, rating, voteStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RatingsDataImplCopyWith<_$RatingsDataImpl> get copyWith =>
      __$$RatingsDataImplCopyWithImpl<_$RatingsDataImpl>(this, _$identity);
}

abstract class _RatingsData implements RatingsData {
  const factory _RatingsData(
      {required final String snapId,
      required final int snapRevision,
      required final Rating? rating,
      required final VoteStatus? voteStatus}) = _$RatingsDataImpl;

  @override
  String get snapId;
  @override
  int get snapRevision;
  @override
  Rating? get rating;
  @override
  VoteStatus? get voteStatus;
  @override
  @JsonKey(ignore: true)
  _$$RatingsDataImplCopyWith<_$RatingsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
