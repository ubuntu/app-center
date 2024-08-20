// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'snap_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SnapData {
  String get name => throw _privateConstructorUsedError;
  Snap? get localSnap => throw _privateConstructorUsedError;
  Snap? get storeSnap => throw _privateConstructorUsedError;
  String? get selectedChannel => throw _privateConstructorUsedError;
  bool get hasUpdate => throw _privateConstructorUsedError;
  String? get activeChangeId => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, Snap? localSnap, Snap? storeSnap,
            String? selectedChannel, bool hasUpdate, String? activeChangeId)
        definition,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, Snap? localSnap, Snap? storeSnap,
            String? selectedChannel, bool hasUpdate, String? activeChangeId)?
        definition,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, Snap? localSnap, Snap? storeSnap,
            String? selectedChannel, bool hasUpdate, String? activeChangeId)?
        definition,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SnapData value) definition,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SnapData value)? definition,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SnapData value)? definition,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SnapDataCopyWith<SnapData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnapDataCopyWith<$Res> {
  factory $SnapDataCopyWith(SnapData value, $Res Function(SnapData) then) =
      _$SnapDataCopyWithImpl<$Res, SnapData>;
  @useResult
  $Res call(
      {String name,
      Snap? localSnap,
      Snap? storeSnap,
      String? selectedChannel,
      bool hasUpdate,
      String? activeChangeId});

  $SnapCopyWith<$Res>? get localSnap;
  $SnapCopyWith<$Res>? get storeSnap;
}

/// @nodoc
class _$SnapDataCopyWithImpl<$Res, $Val extends SnapData>
    implements $SnapDataCopyWith<$Res> {
  _$SnapDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? localSnap = freezed,
    Object? storeSnap = freezed,
    Object? selectedChannel = freezed,
    Object? hasUpdate = null,
    Object? activeChangeId = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      localSnap: freezed == localSnap
          ? _value.localSnap
          : localSnap // ignore: cast_nullable_to_non_nullable
              as Snap?,
      storeSnap: freezed == storeSnap
          ? _value.storeSnap
          : storeSnap // ignore: cast_nullable_to_non_nullable
              as Snap?,
      selectedChannel: freezed == selectedChannel
          ? _value.selectedChannel
          : selectedChannel // ignore: cast_nullable_to_non_nullable
              as String?,
      hasUpdate: null == hasUpdate
          ? _value.hasUpdate
          : hasUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      activeChangeId: freezed == activeChangeId
          ? _value.activeChangeId
          : activeChangeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SnapCopyWith<$Res>? get localSnap {
    if (_value.localSnap == null) {
      return null;
    }

    return $SnapCopyWith<$Res>(_value.localSnap!, (value) {
      return _then(_value.copyWith(localSnap: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SnapCopyWith<$Res>? get storeSnap {
    if (_value.storeSnap == null) {
      return null;
    }

    return $SnapCopyWith<$Res>(_value.storeSnap!, (value) {
      return _then(_value.copyWith(storeSnap: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnapDataImplCopyWith<$Res>
    implements $SnapDataCopyWith<$Res> {
  factory _$$SnapDataImplCopyWith(
          _$SnapDataImpl value, $Res Function(_$SnapDataImpl) then) =
      __$$SnapDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      Snap? localSnap,
      Snap? storeSnap,
      String? selectedChannel,
      bool hasUpdate,
      String? activeChangeId});

  @override
  $SnapCopyWith<$Res>? get localSnap;
  @override
  $SnapCopyWith<$Res>? get storeSnap;
}

/// @nodoc
class __$$SnapDataImplCopyWithImpl<$Res>
    extends _$SnapDataCopyWithImpl<$Res, _$SnapDataImpl>
    implements _$$SnapDataImplCopyWith<$Res> {
  __$$SnapDataImplCopyWithImpl(
      _$SnapDataImpl _value, $Res Function(_$SnapDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? localSnap = freezed,
    Object? storeSnap = freezed,
    Object? selectedChannel = freezed,
    Object? hasUpdate = null,
    Object? activeChangeId = freezed,
  }) {
    return _then(_$SnapDataImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      localSnap: freezed == localSnap
          ? _value.localSnap
          : localSnap // ignore: cast_nullable_to_non_nullable
              as Snap?,
      storeSnap: freezed == storeSnap
          ? _value.storeSnap
          : storeSnap // ignore: cast_nullable_to_non_nullable
              as Snap?,
      selectedChannel: freezed == selectedChannel
          ? _value.selectedChannel
          : selectedChannel // ignore: cast_nullable_to_non_nullable
              as String?,
      hasUpdate: null == hasUpdate
          ? _value.hasUpdate
          : hasUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      activeChangeId: freezed == activeChangeId
          ? _value.activeChangeId
          : activeChangeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SnapDataImpl extends _SnapData {
  _$SnapDataImpl(
      {required this.name,
      required this.localSnap,
      required this.storeSnap,
      required this.selectedChannel,
      required this.hasUpdate,
      this.activeChangeId})
      : super._();

  @override
  final String name;
  @override
  final Snap? localSnap;
  @override
  final Snap? storeSnap;
  @override
  final String? selectedChannel;
  @override
  final bool hasUpdate;
  @override
  final String? activeChangeId;

  @override
  String toString() {
    return 'SnapData.definition(name: $name, localSnap: $localSnap, storeSnap: $storeSnap, selectedChannel: $selectedChannel, hasUpdate: $hasUpdate, activeChangeId: $activeChangeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnapDataImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.localSnap, localSnap) ||
                other.localSnap == localSnap) &&
            (identical(other.storeSnap, storeSnap) ||
                other.storeSnap == storeSnap) &&
            (identical(other.selectedChannel, selectedChannel) ||
                other.selectedChannel == selectedChannel) &&
            (identical(other.hasUpdate, hasUpdate) ||
                other.hasUpdate == hasUpdate) &&
            (identical(other.activeChangeId, activeChangeId) ||
                other.activeChangeId == activeChangeId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, localSnap, storeSnap,
      selectedChannel, hasUpdate, activeChangeId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SnapDataImplCopyWith<_$SnapDataImpl> get copyWith =>
      __$$SnapDataImplCopyWithImpl<_$SnapDataImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, Snap? localSnap, Snap? storeSnap,
            String? selectedChannel, bool hasUpdate, String? activeChangeId)
        definition,
  }) {
    return definition(
        name, localSnap, storeSnap, selectedChannel, hasUpdate, activeChangeId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, Snap? localSnap, Snap? storeSnap,
            String? selectedChannel, bool hasUpdate, String? activeChangeId)?
        definition,
  }) {
    return definition?.call(
        name, localSnap, storeSnap, selectedChannel, hasUpdate, activeChangeId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, Snap? localSnap, Snap? storeSnap,
            String? selectedChannel, bool hasUpdate, String? activeChangeId)?
        definition,
    required TResult orElse(),
  }) {
    if (definition != null) {
      return definition(name, localSnap, storeSnap, selectedChannel, hasUpdate,
          activeChangeId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SnapData value) definition,
  }) {
    return definition(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SnapData value)? definition,
  }) {
    return definition?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SnapData value)? definition,
    required TResult orElse(),
  }) {
    if (definition != null) {
      return definition(this);
    }
    return orElse();
  }
}

abstract class _SnapData extends SnapData {
  factory _SnapData(
      {required final String name,
      required final Snap? localSnap,
      required final Snap? storeSnap,
      required final String? selectedChannel,
      required final bool hasUpdate,
      final String? activeChangeId}) = _$SnapDataImpl;
  _SnapData._() : super._();

  @override
  String get name;
  @override
  Snap? get localSnap;
  @override
  Snap? get storeSnap;
  @override
  String? get selectedChannel;
  @override
  bool get hasUpdate;
  @override
  String? get activeChangeId;
  @override
  @JsonKey(ignore: true)
  _$$SnapDataImplCopyWith<_$SnapDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
