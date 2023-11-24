//
//  Generated code. Do not modify.
//  source: ratings_features_chart.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'ratings_features_chart.pbenum.dart';

export 'ratings_features_chart.pbenum.dart';

class GetChartRequest extends $pb.GeneratedMessage {
  factory GetChartRequest({
    Timeframe? timeframe,
    ChartType? type,
  }) {
    final $result = create();
    if (timeframe != null) {
      $result.timeframe = timeframe;
    }
    if (type != null) {
      $result.type = type;
    }
    return $result;
  }
  GetChartRequest._() : super();
  factory GetChartRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetChartRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetChartRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'ratings.features.chart'),
      createEmptyInstance: create)
    ..e<Timeframe>(1, _omitFieldNames ? '' : 'timeframe', $pb.PbFieldType.OE,
        defaultOrMaker: Timeframe.TIMEFRAME_UNSPECIFIED,
        valueOf: Timeframe.valueOf,
        enumValues: Timeframe.values)
    ..e<ChartType>(2, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: ChartType.CHART_TYPE_TOP_UNSPECIFIED,
        valueOf: ChartType.valueOf,
        enumValues: ChartType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetChartRequest clone() => GetChartRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetChartRequest copyWith(void Function(GetChartRequest) updates) =>
      super.copyWith((message) => updates(message as GetChartRequest))
          as GetChartRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChartRequest create() => GetChartRequest._();
  GetChartRequest createEmptyInstance() => create();
  static $pb.PbList<GetChartRequest> createRepeated() =>
      $pb.PbList<GetChartRequest>();
  @$core.pragma('dart2js:noInline')
  static GetChartRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChartRequest>(create);
  static GetChartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Timeframe get timeframe => $_getN(0);
  @$pb.TagNumber(1)
  set timeframe(Timeframe v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTimeframe() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimeframe() => clearField(1);

  @$pb.TagNumber(2)
  ChartType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ChartType v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);
}

class GetChartResponse extends $pb.GeneratedMessage {
  factory GetChartResponse({
    Timeframe? timeframe,
    ChartType? type,
    $core.Iterable<ChartData>? orderedChartData,
  }) {
    final $result = create();
    if (timeframe != null) {
      $result.timeframe = timeframe;
    }
    if (type != null) {
      $result.type = type;
    }
    if (orderedChartData != null) {
      $result.orderedChartData.addAll(orderedChartData);
    }
    return $result;
  }
  GetChartResponse._() : super();
  factory GetChartResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetChartResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetChartResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'ratings.features.chart'),
      createEmptyInstance: create)
    ..e<Timeframe>(1, _omitFieldNames ? '' : 'timeframe', $pb.PbFieldType.OE,
        defaultOrMaker: Timeframe.TIMEFRAME_UNSPECIFIED,
        valueOf: Timeframe.valueOf,
        enumValues: Timeframe.values)
    ..e<ChartType>(2, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: ChartType.CHART_TYPE_TOP_UNSPECIFIED,
        valueOf: ChartType.valueOf,
        enumValues: ChartType.values)
    ..pc<ChartData>(
        3, _omitFieldNames ? '' : 'orderedChartData', $pb.PbFieldType.PM,
        subBuilder: ChartData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetChartResponse clone() => GetChartResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetChartResponse copyWith(void Function(GetChartResponse) updates) =>
      super.copyWith((message) => updates(message as GetChartResponse))
          as GetChartResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChartResponse create() => GetChartResponse._();
  GetChartResponse createEmptyInstance() => create();
  static $pb.PbList<GetChartResponse> createRepeated() =>
      $pb.PbList<GetChartResponse>();
  @$core.pragma('dart2js:noInline')
  static GetChartResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChartResponse>(create);
  static GetChartResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Timeframe get timeframe => $_getN(0);
  @$pb.TagNumber(1)
  set timeframe(Timeframe v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTimeframe() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimeframe() => clearField(1);

  @$pb.TagNumber(2)
  ChartType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ChartType v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<ChartData> get orderedChartData => $_getList(2);
}

class ChartData extends $pb.GeneratedMessage {
  factory ChartData({
    $core.String? app,
    $fixnum.Int64? totalUpVotes,
    $fixnum.Int64? totalDownVotes,
  }) {
    final $result = create();
    if (app != null) {
      $result.app = app;
    }
    if (totalUpVotes != null) {
      $result.totalUpVotes = totalUpVotes;
    }
    if (totalDownVotes != null) {
      $result.totalDownVotes = totalDownVotes;
    }
    return $result;
  }
  ChartData._() : super();
  factory ChartData.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ChartData.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChartData',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'ratings.features.chart'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'app')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'totalUpVotes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'totalDownVotes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ChartData clone() => ChartData()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ChartData copyWith(void Function(ChartData) updates) =>
      super.copyWith((message) => updates(message as ChartData)) as ChartData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChartData create() => ChartData._();
  ChartData createEmptyInstance() => create();
  static $pb.PbList<ChartData> createRepeated() => $pb.PbList<ChartData>();
  @$core.pragma('dart2js:noInline')
  static ChartData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChartData>(create);
  static ChartData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get app => $_getSZ(0);
  @$pb.TagNumber(1)
  set app($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasApp() => $_has(0);
  @$pb.TagNumber(1)
  void clearApp() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalUpVotes => $_getI64(1);
  @$pb.TagNumber(2)
  set totalUpVotes($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasTotalUpVotes() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalUpVotes() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get totalDownVotes => $_getI64(2);
  @$pb.TagNumber(3)
  set totalDownVotes($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTotalDownVotes() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalDownVotes() => clearField(3);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
