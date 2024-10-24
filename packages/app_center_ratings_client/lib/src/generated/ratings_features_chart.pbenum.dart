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

class Timeframe extends $pb.ProtobufEnum {
  static const Timeframe TIMEFRAME_UNSPECIFIED = Timeframe._(0, _omitEnumNames ? '' : 'TIMEFRAME_UNSPECIFIED');
  static const Timeframe TIMEFRAME_WEEK = Timeframe._(1, _omitEnumNames ? '' : 'TIMEFRAME_WEEK');
  static const Timeframe TIMEFRAME_MONTH = Timeframe._(2, _omitEnumNames ? '' : 'TIMEFRAME_MONTH');

  static const $core.List<Timeframe> values = <Timeframe> [
    TIMEFRAME_UNSPECIFIED,
    TIMEFRAME_WEEK,
    TIMEFRAME_MONTH,
  ];

  static final $core.Map<$core.int, Timeframe> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Timeframe? valueOf($core.int value) => _byValue[value];

  const Timeframe._($core.int v, $core.String n) : super(v, n);
}

class Category extends $pb.ProtobufEnum {
  static const Category ART_AND_DESIGN = Category._(0, _omitEnumNames ? '' : 'ART_AND_DESIGN');
  static const Category BOOK_AND_REFERENCE = Category._(1, _omitEnumNames ? '' : 'BOOK_AND_REFERENCE');
  static const Category DEVELOPMENT = Category._(2, _omitEnumNames ? '' : 'DEVELOPMENT');
  static const Category DEVICES_AND_IOT = Category._(3, _omitEnumNames ? '' : 'DEVICES_AND_IOT');
  static const Category EDUCATION = Category._(4, _omitEnumNames ? '' : 'EDUCATION');
  static const Category ENTERTAINMENT = Category._(5, _omitEnumNames ? '' : 'ENTERTAINMENT');
  static const Category FEATURED = Category._(6, _omitEnumNames ? '' : 'FEATURED');
  static const Category FINANCE = Category._(7, _omitEnumNames ? '' : 'FINANCE');
  static const Category GAMES = Category._(8, _omitEnumNames ? '' : 'GAMES');
  static const Category HEALTH_AND_FITNESS = Category._(9, _omitEnumNames ? '' : 'HEALTH_AND_FITNESS');
  static const Category MUSIC_AND_AUDIO = Category._(10, _omitEnumNames ? '' : 'MUSIC_AND_AUDIO');
  static const Category NEWS_AND_WEATHER = Category._(11, _omitEnumNames ? '' : 'NEWS_AND_WEATHER');
  static const Category PERSONALISATION = Category._(12, _omitEnumNames ? '' : 'PERSONALISATION');
  static const Category PHOTO_AND_VIDEO = Category._(13, _omitEnumNames ? '' : 'PHOTO_AND_VIDEO');
  static const Category PRODUCTIVITY = Category._(14, _omitEnumNames ? '' : 'PRODUCTIVITY');
  static const Category SCIENCE = Category._(15, _omitEnumNames ? '' : 'SCIENCE');
  static const Category SECURITY = Category._(16, _omitEnumNames ? '' : 'SECURITY');
  static const Category SERVER_AND_CLOUD = Category._(17, _omitEnumNames ? '' : 'SERVER_AND_CLOUD');
  static const Category SOCIAL = Category._(18, _omitEnumNames ? '' : 'SOCIAL');
  static const Category UTILITIES = Category._(19, _omitEnumNames ? '' : 'UTILITIES');

  static const $core.List<Category> values = <Category> [
    ART_AND_DESIGN,
    BOOK_AND_REFERENCE,
    DEVELOPMENT,
    DEVICES_AND_IOT,
    EDUCATION,
    ENTERTAINMENT,
    FEATURED,
    FINANCE,
    GAMES,
    HEALTH_AND_FITNESS,
    MUSIC_AND_AUDIO,
    NEWS_AND_WEATHER,
    PERSONALISATION,
    PHOTO_AND_VIDEO,
    PRODUCTIVITY,
    SCIENCE,
    SECURITY,
    SERVER_AND_CLOUD,
    SOCIAL,
    UTILITIES,
  ];

  static final $core.Map<$core.int, Category> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Category? valueOf($core.int value) => _byValue[value];

  const Category._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
