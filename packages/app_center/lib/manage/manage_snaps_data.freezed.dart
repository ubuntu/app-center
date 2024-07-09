// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manage_snaps_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ManageSnapsData {
  List<Snap> get installedSnaps => throw _privateConstructorUsedError;
  List<String> get refreshableSnapNames => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ManageSnapsDataCopyWith<ManageSnapsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ManageSnapsDataCopyWith<$Res> {
  factory $ManageSnapsDataCopyWith(
          ManageSnapsData value, $Res Function(ManageSnapsData) then) =
      _$ManageSnapsDataCopyWithImpl<$Res, ManageSnapsData>;
  @useResult
  $Res call({List<Snap> installedSnaps, List<String> refreshableSnapNames});
}

/// @nodoc
class _$ManageSnapsDataCopyWithImpl<$Res, $Val extends ManageSnapsData>
    implements $ManageSnapsDataCopyWith<$Res> {
  _$ManageSnapsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? installedSnaps = null,
    Object? refreshableSnapNames = null,
  }) {
    return _then(_value.copyWith(
      installedSnaps: null == installedSnaps
          ? _value.installedSnaps
          : installedSnaps // ignore: cast_nullable_to_non_nullable
              as List<Snap>,
      refreshableSnapNames: null == refreshableSnapNames
          ? _value.refreshableSnapNames
          : refreshableSnapNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ManageSnapsDataImplCopyWith<$Res>
    implements $ManageSnapsDataCopyWith<$Res> {
  factory _$$ManageSnapsDataImplCopyWith(_$ManageSnapsDataImpl value,
          $Res Function(_$ManageSnapsDataImpl) then) =
      __$$ManageSnapsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Snap> installedSnaps, List<String> refreshableSnapNames});
}

/// @nodoc
class __$$ManageSnapsDataImplCopyWithImpl<$Res>
    extends _$ManageSnapsDataCopyWithImpl<$Res, _$ManageSnapsDataImpl>
    implements _$$ManageSnapsDataImplCopyWith<$Res> {
  __$$ManageSnapsDataImplCopyWithImpl(
      _$ManageSnapsDataImpl _value, $Res Function(_$ManageSnapsDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? installedSnaps = null,
    Object? refreshableSnapNames = null,
  }) {
    return _then(_$ManageSnapsDataImpl(
      installedSnaps: null == installedSnaps
          ? _value._installedSnaps
          : installedSnaps // ignore: cast_nullable_to_non_nullable
              as List<Snap>,
      refreshableSnapNames: null == refreshableSnapNames
          ? _value._refreshableSnapNames
          : refreshableSnapNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$ManageSnapsDataImpl extends _ManageSnapsData
    with DiagnosticableTreeMixin {
  _$ManageSnapsDataImpl(
      {required final List<Snap> installedSnaps,
      required final List<String> refreshableSnapNames})
      : _installedSnaps = installedSnaps,
        _refreshableSnapNames = refreshableSnapNames,
        super._();

  final List<Snap> _installedSnaps;
  @override
  List<Snap> get installedSnaps {
    if (_installedSnaps is EqualUnmodifiableListView) return _installedSnaps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_installedSnaps);
  }

  final List<String> _refreshableSnapNames;
  @override
  List<String> get refreshableSnapNames {
    if (_refreshableSnapNames is EqualUnmodifiableListView)
      return _refreshableSnapNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_refreshableSnapNames);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ManageSnapsData(installedSnaps: $installedSnaps, refreshableSnapNames: $refreshableSnapNames)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ManageSnapsData'))
      ..add(DiagnosticsProperty('installedSnaps', installedSnaps))
      ..add(DiagnosticsProperty('refreshableSnapNames', refreshableSnapNames));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ManageSnapsDataImpl &&
            const DeepCollectionEquality()
                .equals(other._installedSnaps, _installedSnaps) &&
            const DeepCollectionEquality()
                .equals(other._refreshableSnapNames, _refreshableSnapNames));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_installedSnaps),
      const DeepCollectionEquality().hash(_refreshableSnapNames));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ManageSnapsDataImplCopyWith<_$ManageSnapsDataImpl> get copyWith =>
      __$$ManageSnapsDataImplCopyWithImpl<_$ManageSnapsDataImpl>(
          this, _$identity);
}

abstract class _ManageSnapsData extends ManageSnapsData {
  factory _ManageSnapsData(
          {required final List<Snap> installedSnaps,
          required final List<String> refreshableSnapNames}) =
      _$ManageSnapsDataImpl;
  _ManageSnapsData._() : super._();

  @override
  List<Snap> get installedSnaps;
  @override
  List<String> get refreshableSnapNames;
  @override
  @JsonKey(ignore: true)
  _$$ManageSnapsDataImplCopyWith<_$ManageSnapsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
