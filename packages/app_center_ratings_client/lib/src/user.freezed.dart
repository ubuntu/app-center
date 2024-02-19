// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Vote {
  String get snapId => throw _privateConstructorUsedError;
  int get snapRevision => throw _privateConstructorUsedError;
  bool get voteUp => throw _privateConstructorUsedError;
  DateTime get dateTime => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $VoteCopyWith<Vote> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoteCopyWith<$Res> {
  factory $VoteCopyWith(Vote value, $Res Function(Vote) then) =
      _$VoteCopyWithImpl<$Res, Vote>;
  @useResult
  $Res call({String snapId, int snapRevision, bool voteUp, DateTime dateTime});
}

/// @nodoc
class _$VoteCopyWithImpl<$Res, $Val extends Vote>
    implements $VoteCopyWith<$Res> {
  _$VoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? snapId = null,
    Object? snapRevision = null,
    Object? voteUp = null,
    Object? dateTime = null,
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
      voteUp: null == voteUp
          ? _value.voteUp
          : voteUp // ignore: cast_nullable_to_non_nullable
              as bool,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoteImplCopyWith<$Res> implements $VoteCopyWith<$Res> {
  factory _$$VoteImplCopyWith(
          _$VoteImpl value, $Res Function(_$VoteImpl) then) =
      __$$VoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String snapId, int snapRevision, bool voteUp, DateTime dateTime});
}

/// @nodoc
class __$$VoteImplCopyWithImpl<$Res>
    extends _$VoteCopyWithImpl<$Res, _$VoteImpl>
    implements _$$VoteImplCopyWith<$Res> {
  __$$VoteImplCopyWithImpl(_$VoteImpl _value, $Res Function(_$VoteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? snapId = null,
    Object? snapRevision = null,
    Object? voteUp = null,
    Object? dateTime = null,
  }) {
    return _then(_$VoteImpl(
      snapId: null == snapId
          ? _value.snapId
          : snapId // ignore: cast_nullable_to_non_nullable
              as String,
      snapRevision: null == snapRevision
          ? _value.snapRevision
          : snapRevision // ignore: cast_nullable_to_non_nullable
              as int,
      voteUp: null == voteUp
          ? _value.voteUp
          : voteUp // ignore: cast_nullable_to_non_nullable
              as bool,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$VoteImpl implements _Vote {
  const _$VoteImpl(
      {required this.snapId,
      required this.snapRevision,
      required this.voteUp,
      required this.dateTime});

  @override
  final String snapId;
  @override
  final int snapRevision;
  @override
  final bool voteUp;
  @override
  final DateTime dateTime;

  @override
  String toString() {
    return 'Vote(snapId: $snapId, snapRevision: $snapRevision, voteUp: $voteUp, dateTime: $dateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoteImpl &&
            (identical(other.snapId, snapId) || other.snapId == snapId) &&
            (identical(other.snapRevision, snapRevision) ||
                other.snapRevision == snapRevision) &&
            (identical(other.voteUp, voteUp) || other.voteUp == voteUp) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, snapId, snapRevision, voteUp, dateTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VoteImplCopyWith<_$VoteImpl> get copyWith =>
      __$$VoteImplCopyWithImpl<_$VoteImpl>(this, _$identity);
}

abstract class _Vote implements Vote {
  const factory _Vote(
      {required final String snapId,
      required final int snapRevision,
      required final bool voteUp,
      required final DateTime dateTime}) = _$VoteImpl;

  @override
  String get snapId;
  @override
  int get snapRevision;
  @override
  bool get voteUp;
  @override
  DateTime get dateTime;
  @override
  @JsonKey(ignore: true)
  _$$VoteImplCopyWith<_$VoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
