//
//  Generated code. Do not modify.
//  source: ratings_features_chart.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:app_center_ratings_client/src/generated/ratings_features_chart.pb.dart'
    as $0;
import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

export 'ratings_features_chart.pb.dart';

@$pb.GrpcServiceName('ratings.features.chart.Chart')
class ChartClient extends $grpc.Client {
  ChartClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);
  static final _$getChart =
      $grpc.ClientMethod<$0.GetChartRequest, $0.GetChartResponse>(
          '/ratings.features.chart.Chart/GetChart',
          (value) => value.writeToBuffer(),
          (value) => $0.GetChartResponse.fromBuffer(value));

  $grpc.ResponseFuture<$0.GetChartResponse> getChart($0.GetChartRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getChart, request, options: options);
  }
}

@$pb.GrpcServiceName('ratings.features.chart.Chart')
abstract class ChartServiceBase extends $grpc.Service {
  ChartServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetChartRequest, $0.GetChartResponse>(
        'GetChart',
        getChart_Pre,
        false,
        false,
        (value) => $0.GetChartRequest.fromBuffer(value),
        (value) => value.writeToBuffer()));
  }
  $core.String get $name => 'ratings.features.chart.Chart';

  $async.Future<$0.GetChartResponse> getChart_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GetChartRequest> request) async {
    return getChart(call, await request);
  }

  $async.Future<$0.GetChartResponse> getChart(
      $grpc.ServiceCall call, $0.GetChartRequest request);
}
