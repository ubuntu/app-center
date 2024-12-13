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

import 'ratings_features_common.pb.dart' as $4;

class GetRatingRequest extends $pb.GeneratedMessage {
  factory GetRatingRequest({
    $core.String? snapId,
  }) {
    final $result = create();
    if (snapId != null) {
      $result.snapId = snapId;
    }
    return $result;
  }
  GetRatingRequest._() : super();
  factory GetRatingRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRatingRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRatingRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'ratings.features.app'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'snapId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRatingRequest clone() => GetRatingRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRatingRequest copyWith(void Function(GetRatingRequest) updates) => super.copyWith((message) => updates(message as GetRatingRequest)) as GetRatingRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRatingRequest create() => GetRatingRequest._();
  GetRatingRequest createEmptyInstance() => create();
  static $pb.PbList<GetRatingRequest> createRepeated() => $pb.PbList<GetRatingRequest>();
  @$core.pragma('dart2js:noInline')
  static GetRatingRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRatingRequest>(create);
  static GetRatingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get snapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set snapId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSnapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapId() => clearField(1);
}

class GetRatingResponse extends $pb.GeneratedMessage {
  factory GetRatingResponse({
    $4.Rating? rating,
  }) {
    final $result = create();
    if (rating != null) {
      $result.rating = rating;
    }
    return $result;
  }
  GetRatingResponse._() : super();
  factory GetRatingResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRatingResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRatingResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'ratings.features.app'), createEmptyInstance: create)
    ..aOM<$4.Rating>(1, _omitFieldNames ? '' : 'rating', subBuilder: $4.Rating.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRatingResponse clone() => GetRatingResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRatingResponse copyWith(void Function(GetRatingResponse) updates) => super.copyWith((message) => updates(message as GetRatingResponse)) as GetRatingResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRatingResponse create() => GetRatingResponse._();
  GetRatingResponse createEmptyInstance() => create();
  static $pb.PbList<GetRatingResponse> createRepeated() => $pb.PbList<GetRatingResponse>();
  @$core.pragma('dart2js:noInline')
  static GetRatingResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRatingResponse>(create);
  static GetRatingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $4.Rating get rating => $_getN(0);
  @$pb.TagNumber(1)
  set rating($4.Rating v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRating() => $_has(0);
  @$pb.TagNumber(1)
  void clearRating() => clearField(1);
  @$pb.TagNumber(1)
  $4.Rating ensureRating() => $_ensure(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
