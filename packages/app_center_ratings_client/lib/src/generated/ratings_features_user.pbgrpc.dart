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

import 'google/protobuf/empty.pb.dart' as $1;
import 'ratings_features_user.pb.dart' as $0;

export 'ratings_features_user.pb.dart';

@$pb.GrpcServiceName('ratings.features.user.User')
class UserClient extends $grpc.Client {
  static final _$authenticate =
      $grpc.ClientMethod<$0.AuthenticateRequest, $0.AuthenticateResponse>(
          '/ratings.features.user.User/Authenticate',
          ($0.AuthenticateRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.AuthenticateResponse.fromBuffer(value));
  static final _$delete = $grpc.ClientMethod<$1.Empty, $1.Empty>(
      '/ratings.features.user.User/Delete',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.Empty.fromBuffer(value));
  static final _$vote = $grpc.ClientMethod<$0.VoteRequest, $1.Empty>(
      '/ratings.features.user.User/Vote',
      ($0.VoteRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.Empty.fromBuffer(value));
  static final _$listMyVotes =
      $grpc.ClientMethod<$0.ListMyVotesRequest, $0.ListMyVotesResponse>(
          '/ratings.features.user.User/ListMyVotes',
          ($0.ListMyVotesRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.ListMyVotesResponse.fromBuffer(value));
  static final _$getSnapVotes =
      $grpc.ClientMethod<$0.GetSnapVotesRequest, $0.GetSnapVotesResponse>(
          '/ratings.features.user.User/GetSnapVotes',
          ($0.GetSnapVotesRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetSnapVotesResponse.fromBuffer(value));

  UserClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.AuthenticateResponse> authenticate(
      $0.AuthenticateRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$authenticate, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> delete($1.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> vote($0.VoteRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$vote, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListMyVotesResponse> listMyVotes(
      $0.ListMyVotesRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listMyVotes, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetSnapVotesResponse> getSnapVotes(
      $0.GetSnapVotesRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getSnapVotes, request, options: options);
  }
}

@$pb.GrpcServiceName('ratings.features.user.User')
abstract class UserServiceBase extends $grpc.Service {
  $core.String get $name => 'ratings.features.user.User';

  UserServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.AuthenticateRequest, $0.AuthenticateResponse>(
            'Authenticate',
            authenticate_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AuthenticateRequest.fromBuffer(value),
            ($0.AuthenticateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $1.Empty>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.VoteRequest, $1.Empty>(
        'Vote',
        vote_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.VoteRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListMyVotesRequest, $0.ListMyVotesResponse>(
            'ListMyVotes',
            listMyVotes_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListMyVotesRequest.fromBuffer(value),
            ($0.ListMyVotesResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetSnapVotesRequest, $0.GetSnapVotesResponse>(
            'GetSnapVotes',
            getSnapVotes_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetSnapVotesRequest.fromBuffer(value),
            ($0.GetSnapVotesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.AuthenticateResponse> authenticate_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.AuthenticateRequest> request) async {
    return authenticate(call, await request);
  }

  $async.Future<$1.Empty> delete_Pre(
      $grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return delete(call, await request);
  }

  $async.Future<$1.Empty> vote_Pre(
      $grpc.ServiceCall call, $async.Future<$0.VoteRequest> request) async {
    return vote(call, await request);
  }

  $async.Future<$0.ListMyVotesResponse> listMyVotes_Pre($grpc.ServiceCall call,
      $async.Future<$0.ListMyVotesRequest> request) async {
    return listMyVotes(call, await request);
  }

  $async.Future<$0.GetSnapVotesResponse> getSnapVotes_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetSnapVotesRequest> request) async {
    return getSnapVotes(call, await request);
  }

  $async.Future<$0.AuthenticateResponse> authenticate(
      $grpc.ServiceCall call, $0.AuthenticateRequest request);
  $async.Future<$1.Empty> delete($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$1.Empty> vote($grpc.ServiceCall call, $0.VoteRequest request);
  $async.Future<$0.ListMyVotesResponse> listMyVotes(
      $grpc.ServiceCall call, $0.ListMyVotesRequest request);
  $async.Future<$0.GetSnapVotesResponse> getSnapVotes(
      $grpc.ServiceCall call, $0.GetSnapVotesRequest request);
}
