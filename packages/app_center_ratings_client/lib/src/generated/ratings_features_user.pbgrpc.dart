//
//  Generated code. Do not modify.
//  source: ratings_features_user.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/empty.pb.dart' as $3;
import 'ratings_features_user.pb.dart' as $2;

export 'ratings_features_user.pb.dart';

@$pb.GrpcServiceName('ratings.features.user.User')
class UserClient extends $grpc.Client {
  static final _$authenticate = $grpc.ClientMethod<$2.AuthenticateRequest, $2.AuthenticateResponse>(
      '/ratings.features.user.User/Authenticate',
      ($2.AuthenticateRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.AuthenticateResponse.fromBuffer(value));
  static final _$delete = $grpc.ClientMethod<$3.Empty, $3.Empty>(
      '/ratings.features.user.User/Delete',
      ($3.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.Empty.fromBuffer(value));
  static final _$vote = $grpc.ClientMethod<$2.VoteRequest, $3.Empty>(
      '/ratings.features.user.User/Vote',
      ($2.VoteRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $3.Empty.fromBuffer(value));
  static final _$getSnapVotes = $grpc.ClientMethod<$2.GetSnapVotesRequest, $2.GetSnapVotesResponse>(
      '/ratings.features.user.User/GetSnapVotes',
      ($2.GetSnapVotesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.GetSnapVotesResponse.fromBuffer(value));

  UserClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$2.AuthenticateResponse> authenticate($2.AuthenticateRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$authenticate, request, options: options);
  }

  $grpc.ResponseFuture<$3.Empty> delete($3.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$3.Empty> vote($2.VoteRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$vote, request, options: options);
  }

  $grpc.ResponseFuture<$2.GetSnapVotesResponse> getSnapVotes($2.GetSnapVotesRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getSnapVotes, request, options: options);
  }
}

@$pb.GrpcServiceName('ratings.features.user.User')
abstract class UserServiceBase extends $grpc.Service {
  $core.String get $name => 'ratings.features.user.User';

  UserServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.AuthenticateRequest, $2.AuthenticateResponse>(
        'Authenticate',
        authenticate_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.AuthenticateRequest.fromBuffer(value),
        ($2.AuthenticateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.Empty, $3.Empty>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.Empty.fromBuffer(value),
        ($3.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.VoteRequest, $3.Empty>(
        'Vote',
        vote_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.VoteRequest.fromBuffer(value),
        ($3.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetSnapVotesRequest, $2.GetSnapVotesResponse>(
        'GetSnapVotes',
        getSnapVotes_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.GetSnapVotesRequest.fromBuffer(value),
        ($2.GetSnapVotesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$2.AuthenticateResponse> authenticate_Pre($grpc.ServiceCall call, $async.Future<$2.AuthenticateRequest> request) async {
    return authenticate(call, await request);
  }

  $async.Future<$3.Empty> delete_Pre($grpc.ServiceCall call, $async.Future<$3.Empty> request) async {
    return delete(call, await request);
  }

  $async.Future<$3.Empty> vote_Pre($grpc.ServiceCall call, $async.Future<$2.VoteRequest> request) async {
    return vote(call, await request);
  }

  $async.Future<$2.GetSnapVotesResponse> getSnapVotes_Pre($grpc.ServiceCall call, $async.Future<$2.GetSnapVotesRequest> request) async {
    return getSnapVotes(call, await request);
  }

  $async.Future<$2.AuthenticateResponse> authenticate($grpc.ServiceCall call, $2.AuthenticateRequest request);
  $async.Future<$3.Empty> delete($grpc.ServiceCall call, $3.Empty request);
  $async.Future<$3.Empty> vote($grpc.ServiceCall call, $2.VoteRequest request);
  $async.Future<$2.GetSnapVotesResponse> getSnapVotes($grpc.ServiceCall call, $2.GetSnapVotesRequest request);
}
