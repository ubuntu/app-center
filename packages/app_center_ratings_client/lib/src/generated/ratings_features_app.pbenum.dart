//
//  Generated code. Do not modify.
//  source: ratings_features_app.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class RatingsBand extends $pb.ProtobufEnum {
  static const RatingsBand VERY_GOOD =
      RatingsBand._(0, _omitEnumNames ? '' : 'VERY_GOOD');
  static const RatingsBand GOOD =
      RatingsBand._(1, _omitEnumNames ? '' : 'GOOD');
  static const RatingsBand NEUTRAL =
      RatingsBand._(2, _omitEnumNames ? '' : 'NEUTRAL');
  static const RatingsBand POOR =
      RatingsBand._(3, _omitEnumNames ? '' : 'POOR');
  static const RatingsBand VERY_POOR =
      RatingsBand._(4, _omitEnumNames ? '' : 'VERY_POOR');
  static const RatingsBand INSUFFICIENT_VOTES =
      RatingsBand._(5, _omitEnumNames ? '' : 'INSUFFICIENT_VOTES');

  static const $core.List<RatingsBand> values = <RatingsBand>[
    VERY_GOOD,
    GOOD,
    NEUTRAL,
    POOR,
    VERY_POOR,
    INSUFFICIENT_VOTES,
  ];

  static final $core.Map<$core.int, RatingsBand> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static RatingsBand? valueOf($core.int value) => _byValue[value];

  const RatingsBand._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
