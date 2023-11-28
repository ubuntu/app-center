//
//  Generated code. Do not modify.
//  source: ratings_features_user.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/timestamp.pb.dart' as $2;

class AuthenticateRequest extends $pb.GeneratedMessage {
  factory AuthenticateRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  AuthenticateRequest._() : super();
  factory AuthenticateRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AuthenticateRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuthenticateRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'ratings.features.user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AuthenticateRequest clone() => AuthenticateRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AuthenticateRequest copyWith(void Function(AuthenticateRequest) updates) =>
      super.copyWith((message) => updates(message as AuthenticateRequest))
          as AuthenticateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthenticateRequest create() => AuthenticateRequest._();
  AuthenticateRequest createEmptyInstance() => create();
  static $pb.PbList<AuthenticateRequest> createRepeated() =>
      $pb.PbList<AuthenticateRequest>();
  @$core.pragma('dart2js:noInline')
  static AuthenticateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AuthenticateRequest>(create);
  static AuthenticateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class AuthenticateResponse extends $pb.GeneratedMessage {
  factory AuthenticateResponse({
    $core.String? token,
  }) {
    final $result = create();
    if (token != null) {
      $result.token = token;
    }
    return $result;
  }
  AuthenticateResponse._() : super();
  factory AuthenticateResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AuthenticateResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuthenticateResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'ratings.features.user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AuthenticateResponse clone() =>
      AuthenticateResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AuthenticateResponse copyWith(void Function(AuthenticateResponse) updates) =>
      super.copyWith((message) => updates(message as AuthenticateResponse))
          as AuthenticateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthenticateResponse create() => AuthenticateResponse._();
  AuthenticateResponse createEmptyInstance() => create();
  static $pb.PbList<AuthenticateResponse> createRepeated() =>
      $pb.PbList<AuthenticateResponse>();
  @$core.pragma('dart2js:noInline')
  static AuthenticateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AuthenticateResponse>(create);
  static AuthenticateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => clearField(1);
}

class ListMyVotesRequest extends $pb.GeneratedMessage {
  factory ListMyVotesRequest({
    $core.String? snapIdFilter,
  }) {
    final $result = create();
    if (snapIdFilter != null) {
      $result.snapIdFilter = snapIdFilter;
    }
    return $result;
  }
  ListMyVotesRequest._() : super();
  factory ListMyVotesRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListMyVotesRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMyVotesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'ratings.features.user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'snapIdFilter')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ListMyVotesRequest clone() => ListMyVotesRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ListMyVotesRequest copyWith(void Function(ListMyVotesRequest) updates) =>
      super.copyWith((message) => updates(message as ListMyVotesRequest))
          as ListMyVotesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMyVotesRequest create() => ListMyVotesRequest._();
  ListMyVotesRequest createEmptyInstance() => create();
  static $pb.PbList<ListMyVotesRequest> createRepeated() =>
      $pb.PbList<ListMyVotesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListMyVotesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMyVotesRequest>(create);
  static ListMyVotesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get snapIdFilter => $_getSZ(0);
  @$pb.TagNumber(1)
  set snapIdFilter($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSnapIdFilter() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapIdFilter() => clearField(1);
}

class ListMyVotesResponse extends $pb.GeneratedMessage {
  factory ListMyVotesResponse({
    $core.Iterable<Vote>? votes,
  }) {
    final $result = create();
    if (votes != null) {
      $result.votes.addAll(votes);
    }
    return $result;
  }
  ListMyVotesResponse._() : super();
  factory ListMyVotesResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListMyVotesResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMyVotesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'ratings.features.user'),
      createEmptyInstance: create)
    ..pc<Vote>(1, _omitFieldNames ? '' : 'votes', $pb.PbFieldType.PM,
        subBuilder: Vote.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ListMyVotesResponse clone() => ListMyVotesResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ListMyVotesResponse copyWith(void Function(ListMyVotesResponse) updates) =>
      super.copyWith((message) => updates(message as ListMyVotesResponse))
          as ListMyVotesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMyVotesResponse create() => ListMyVotesResponse._();
  ListMyVotesResponse createEmptyInstance() => create();
  static $pb.PbList<ListMyVotesResponse> createRepeated() =>
      $pb.PbList<ListMyVotesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListMyVotesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMyVotesResponse>(create);
  static ListMyVotesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Vote> get votes => $_getList(0);
}

class GetSnapVotesRequest extends $pb.GeneratedMessage {
  factory GetSnapVotesRequest({
    $core.String? snapId,
  }) {
    final $result = create();
    if (snapId != null) {
      $result.snapId = snapId;
    }
    return $result;
  }
  GetSnapVotesRequest._() : super();
  factory GetSnapVotesRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetSnapVotesRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSnapVotesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'ratings.features.user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'snapId')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetSnapVotesRequest clone() => GetSnapVotesRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetSnapVotesRequest copyWith(void Function(GetSnapVotesRequest) updates) =>
      super.copyWith((message) => updates(message as GetSnapVotesRequest))
          as GetSnapVotesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSnapVotesRequest create() => GetSnapVotesRequest._();
  GetSnapVotesRequest createEmptyInstance() => create();
  static $pb.PbList<GetSnapVotesRequest> createRepeated() =>
      $pb.PbList<GetSnapVotesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetSnapVotesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSnapVotesRequest>(create);
  static GetSnapVotesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get snapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set snapId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSnapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapId() => clearField(1);
}

class GetSnapVotesResponse extends $pb.GeneratedMessage {
  factory GetSnapVotesResponse({
    $core.Iterable<Vote>? votes,
  }) {
    final $result = create();
    if (votes != null) {
      $result.votes.addAll(votes);
    }
    return $result;
  }
  GetSnapVotesResponse._() : super();
  factory GetSnapVotesResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetSnapVotesResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSnapVotesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'ratings.features.user'),
      createEmptyInstance: create)
    ..pc<Vote>(1, _omitFieldNames ? '' : 'votes', $pb.PbFieldType.PM,
        subBuilder: Vote.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetSnapVotesResponse clone() =>
      GetSnapVotesResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetSnapVotesResponse copyWith(void Function(GetSnapVotesResponse) updates) =>
      super.copyWith((message) => updates(message as GetSnapVotesResponse))
          as GetSnapVotesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSnapVotesResponse create() => GetSnapVotesResponse._();
  GetSnapVotesResponse createEmptyInstance() => create();
  static $pb.PbList<GetSnapVotesResponse> createRepeated() =>
      $pb.PbList<GetSnapVotesResponse>();
  @$core.pragma('dart2js:noInline')
  static GetSnapVotesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSnapVotesResponse>(create);
  static GetSnapVotesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Vote> get votes => $_getList(0);
}

class Vote extends $pb.GeneratedMessage {
  factory Vote({
    $core.String? snapId,
    $core.int? snapRevision,
    $core.bool? voteUp,
    $2.Timestamp? timestamp,
  }) {
    final $result = create();
    if (snapId != null) {
      $result.snapId = snapId;
    }
    if (snapRevision != null) {
      $result.snapRevision = snapRevision;
    }
    if (voteUp != null) {
      $result.voteUp = voteUp;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  Vote._() : super();
  factory Vote.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Vote.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Vote',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'ratings.features.user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'snapId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'snapRevision', $pb.PbFieldType.O3)
    ..aOB(3, _omitFieldNames ? '' : 'voteUp')
    ..aOM<$2.Timestamp>(4, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Vote clone() => Vote()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Vote copyWith(void Function(Vote) updates) =>
      super.copyWith((message) => updates(message as Vote)) as Vote;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Vote create() => Vote._();
  Vote createEmptyInstance() => create();
  static $pb.PbList<Vote> createRepeated() => $pb.PbList<Vote>();
  @$core.pragma('dart2js:noInline')
  static Vote getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Vote>(create);
  static Vote? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get snapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set snapId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSnapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get snapRevision => $_getIZ(1);
  @$pb.TagNumber(2)
  set snapRevision($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasSnapRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearSnapRevision() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get voteUp => $_getBF(2);
  @$pb.TagNumber(3)
  set voteUp($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasVoteUp() => $_has(2);
  @$pb.TagNumber(3)
  void clearVoteUp() => clearField(3);

  @$pb.TagNumber(4)
  $2.Timestamp get timestamp => $_getN(3);
  @$pb.TagNumber(4)
  set timestamp($2.Timestamp v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => clearField(4);
  @$pb.TagNumber(4)
  $2.Timestamp ensureTimestamp() => $_ensure(3);
}

class VoteRequest extends $pb.GeneratedMessage {
  factory VoteRequest({
    $core.String? snapId,
    $core.int? snapRevision,
    $core.bool? voteUp,
  }) {
    final $result = create();
    if (snapId != null) {
      $result.snapId = snapId;
    }
    if (snapRevision != null) {
      $result.snapRevision = snapRevision;
    }
    if (voteUp != null) {
      $result.voteUp = voteUp;
    }
    return $result;
  }
  VoteRequest._() : super();
  factory VoteRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory VoteRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoteRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'ratings.features.user'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'snapId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'snapRevision', $pb.PbFieldType.O3)
    ..aOB(3, _omitFieldNames ? '' : 'voteUp')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  VoteRequest clone() => VoteRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  VoteRequest copyWith(void Function(VoteRequest) updates) =>
      super.copyWith((message) => updates(message as VoteRequest))
          as VoteRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoteRequest create() => VoteRequest._();
  VoteRequest createEmptyInstance() => create();
  static $pb.PbList<VoteRequest> createRepeated() => $pb.PbList<VoteRequest>();
  @$core.pragma('dart2js:noInline')
  static VoteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoteRequest>(create);
  static VoteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get snapId => $_getSZ(0);
  @$pb.TagNumber(1)
  set snapId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSnapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get snapRevision => $_getIZ(1);
  @$pb.TagNumber(2)
  set snapRevision($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasSnapRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearSnapRevision() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get voteUp => $_getBF(2);
  @$pb.TagNumber(3)
  set voteUp($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasVoteUp() => $_has(2);
  @$pb.TagNumber(3)
  void clearVoteUp() => clearField(3);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
