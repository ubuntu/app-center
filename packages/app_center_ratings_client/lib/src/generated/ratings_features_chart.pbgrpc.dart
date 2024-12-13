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

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'ratings_features_chart.pb.dart' as $1;

export 'ratings_features_chart.pb.dart';

@$pb.GrpcServiceName('ratings.features.chart.Chart')
class ChartClient extends $grpc.Client {
  static final _$getChart = $grpc.ClientMethod<$1.GetChartRequest, $1.GetChartResponse>(
      '/ratings.features.chart.Chart/GetChart',
      ($1.GetChartRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetChartResponse.fromBuffer(value));

  ChartClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$1.GetChartResponse> getChart($1.GetChartRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getChart, request, options: options);
  }
}

@$pb.GrpcServiceName('ratings.features.chart.Chart')
abstract class ChartServiceBase extends $grpc.Service {
  $core.String get $name => 'ratings.features.chart.Chart';

  ChartServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.GetChartRequest, $1.GetChartResponse>(
        'GetChart',
        getChart_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetChartRequest.fromBuffer(value),
        ($1.GetChartResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.GetChartResponse> getChart_Pre($grpc.ServiceCall call, $async.Future<$1.GetChartRequest> request) async {
    return getChart(call, await request);
  }

  $async.Future<$1.GetChartResponse> getChart($grpc.ServiceCall call, $1.GetChartRequest request);
}
