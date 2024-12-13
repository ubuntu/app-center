//
//  Generated code. Do not modify.
//  source: ratings_features_common.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'ratings_features_common.pbenum.dart';

export 'ratings_features_common.pbenum.dart';

class Rating extends $pb.GeneratedMessage {
  factory Rating({
    $core.String? snapId,
    $fixnum.Int64? totalVotes,
    RatingsBand? ratingsBand,
    $core.String? snapName,
  }) {
    final $result = create();
    if (snapId != null) {
      $result.snapId = snapId;
    }
    if (totalVotes != null) {
      $result.totalVotes = totalVotes;
    }
    if (ratingsBand != null) {
      $result.ratingsBand = ratingsBand;
    }
    if (snapName != null) {
      $result.snapName = snapName;
    }
    return $result;
  }
  Rating._() : super();
  factory Rating.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Rating.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Rating', package: const $pb.PackageName(_omitMessageNames ? '' : 'ratings.features.common'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'snapId')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'totalVotes', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..e<RatingsBand>(3, _omitFieldNames ? '' : 'ratingsBand', $pb.PbFieldType.OE, defaultOrMaker: RatingsBand.VERY_GOOD, valueOf: RatingsBand.valueOf, enumValues: RatingsBand.values)
    ..aOS(4, _omitFieldNames ? '' : 'snapName')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Rating clone() => Rating()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Rating copyWith(void Function(Rating) updates) => super.copyWith((message) => updates(message as Rating)) as Rating;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Rating create() => Rating._();
  Rating createEmptyInstance() => create();
  static $pb.PbList<Rating> createRepeated() => $pb.PbList<Rating>();
  @$core.pragma('dart2js:noInline')
  static Rating getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Rating>(create);
  static Rating? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get snapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set snapId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSnapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalVotes => $_getI64(1);
  @$pb.TagNumber(2)
  set totalVotes($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTotalVotes() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalVotes() => clearField(2);

  @$pb.TagNumber(3)
  RatingsBand get ratingsBand => $_getN(2);
  @$pb.TagNumber(3)
  set ratingsBand(RatingsBand v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasRatingsBand() => $_has(2);
  @$pb.TagNumber(3)
  void clearRatingsBand() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get snapName => $_getSZ(3);
  @$pb.TagNumber(4)
  set snapName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSnapName() => $_has(3);
  @$pb.TagNumber(4)
  void clearSnapName() => clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
