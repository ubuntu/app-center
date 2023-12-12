//
//  Generated code. Do not modify.
//  source: ratings_features_app.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:app_center_ratings_client/src/generated/ratings_features_app.pb.dart'
    as $0;
import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

export 'ratings_features_app.pb.dart';

@$pb.GrpcServiceName('ratings.features.app.App')
class AppClient extends $grpc.Client {
  AppClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);
  static final _$getRating =
      $grpc.ClientMethod<$0.GetRatingRequest, $0.GetRatingResponse>(
          '/ratings.features.app.App/GetRating',
          (value) => value.writeToBuffer(),
          (value) => $0.GetRatingResponse.fromBuffer(value));

  $grpc.ResponseFuture<$0.GetRatingResponse> getRating(
      $0.GetRatingRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getRating, request, options: options);
  }
}

@$pb.GrpcServiceName('ratings.features.app.App')
abstract class AppServiceBase extends $grpc.Service {
  AppServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetRatingRequest, $0.GetRatingResponse>(
        'GetRating',
        getRating_Pre,
        false,
        false,
        (value) => $0.GetRatingRequest.fromBuffer(value),
        (value) => value.writeToBuffer()));
  }
  $core.String get $name => 'ratings.features.app.App';

  $async.Future<$0.GetRatingResponse> getRating_Pre($grpc.ServiceCall call,
      $async.Future<$0.GetRatingRequest> request) async {
    return getRating(call, await request);
  }

  $async.Future<$0.GetRatingResponse> getRating(
      $grpc.ServiceCall call, $0.GetRatingRequest request);
}
