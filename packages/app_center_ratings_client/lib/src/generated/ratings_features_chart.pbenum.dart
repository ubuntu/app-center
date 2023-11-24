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

import 'package:protobuf/protobuf.dart' as $pb;

class ChartType extends $pb.ProtobufEnum {
  static const ChartType CHART_TYPE_TOP_UNSPECIFIED =
      ChartType._(0, _omitEnumNames ? '' : 'CHART_TYPE_TOP_UNSPECIFIED');
  static const ChartType CHART_TYPE_TOP =
      ChartType._(1, _omitEnumNames ? '' : 'CHART_TYPE_TOP');

  static const $core.List<ChartType> values = <ChartType>[
    CHART_TYPE_TOP_UNSPECIFIED,
    CHART_TYPE_TOP,
  ];

  static final $core.Map<$core.int, ChartType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static ChartType? valueOf($core.int value) => _byValue[value];

  const ChartType._($core.int v, $core.String n) : super(v, n);
}

class Timeframe extends $pb.ProtobufEnum {
  static const Timeframe TIMEFRAME_UNSPECIFIED =
      Timeframe._(0, _omitEnumNames ? '' : 'TIMEFRAME_UNSPECIFIED');
  static const Timeframe TIMEFRAME_WEEK =
      Timeframe._(1, _omitEnumNames ? '' : 'TIMEFRAME_WEEK');
  static const Timeframe TIMEFRAME_MONTH =
      Timeframe._(2, _omitEnumNames ? '' : 'TIMEFRAME_MONTH');

  static const $core.List<Timeframe> values = <Timeframe>[
    TIMEFRAME_UNSPECIFIED,
    TIMEFRAME_WEEK,
    TIMEFRAME_MONTH,
  ];

  static final $core.Map<$core.int, Timeframe> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Timeframe? valueOf($core.int value) => _byValue[value];

  const Timeframe._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
