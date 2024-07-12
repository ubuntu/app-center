import 'dart:async';

import 'package:app_center_ratings_client/src/chart.dart';
import 'package:app_center_ratings_client/src/generated/google/protobuf/empty.pb.dart';
import 'package:app_center_ratings_client/src/generated/ratings_features_app.pbgrpc.dart'
    as app_pb;
import 'package:app_center_ratings_client/src/generated/ratings_features_chart.pbgrpc.dart'
    as chart_pb;
import 'package:app_center_ratings_client/src/generated/ratings_features_user.pbgrpc.dart'
    as user_pb;
import 'package:app_center_ratings_client/src/ratings.dart';
import 'package:app_center_ratings_client/src/vote.dart';
import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';

class RatingsClient {
  RatingsClient(String serverUrl, int port, bool useTls) {
    final channel = ClientChannel(
      serverUrl,
      port: port,
      options: ChannelOptions(
        credentials: useTls
            ? const ChannelCredentials.secure()
            : const ChannelCredentials.insecure(),
      ),
    );
    _appClient = app_pb.AppClient(channel);
    _userClient = user_pb.UserClient(channel);
    _chartClient = chart_pb.ChartClient(channel);
  }

  // Additional constructor for testing
  @visibleForTesting
  RatingsClient.withClients(
    this._appClient,
    this._userClient,
    this._chartClient,
  );
  late app_pb.AppClient _appClient;
  late user_pb.UserClient _userClient;
  late chart_pb.ChartClient _chartClient;

  Future<String> authenticate(String id) async {
    final request = user_pb.AuthenticateRequest(id: id);
    final grpcResponse = await _userClient.authenticate(request);
    return grpcResponse.token;
  }

  Future<void> delete(String token) async {
    final request = Empty();
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    await _userClient.delete(request, options: callOptions);
  }

  Future<List<ChartData>> getChart(
    Timeframe timeframe,
    String token, [
    int? category,
  ]) async {
    final request = chart_pb.GetChartRequest(
      timeframe: timeframe.toDTO(),
      category: category != null ? chart_pb.Category.valueOf(category) : null,
    );
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    final grpcResponse =
        await _chartClient.getChart(request, options: callOptions);
    return grpcResponse.orderedChartData.map((data) => data.fromDTO()).toList();
  }

  Future<Rating> getRating(
    String snapId,
    String token,
  ) async {
    final request = app_pb.GetRatingRequest(snapId: snapId);
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    final grpcResponse = await _appClient.getRating(
      request,
      options: callOptions,
    );
    return grpcResponse.rating.fromDTO();
  }

  Future<List<Vote>> getSnapVotes(String snapId, String token) async {
    final request = user_pb.GetSnapVotesRequest(snapId: snapId);
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    final grpcResponse = await _userClient.getSnapVotes(
      request,
      options: callOptions,
    );
    return grpcResponse.votes.map((vote) => vote.fromDTO()).toList();
  }

  Future<List<Vote>> listMyVotes(String snapIdFilter, String token) async {
    final request = user_pb.ListMyVotesRequest(snapIdFilter: snapIdFilter);
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    final grpcResponse = await _userClient.listMyVotes(
      request,
      options: callOptions,
    );
    return grpcResponse.votes.map((vote) => vote.fromDTO()).toList();
  }

  Future<void> vote(
    String snapId,
    int snapRevision,
    bool voteUp,
    String token,
  ) async {
    final request = user_pb.VoteRequest(
      snapId: snapId,
      snapRevision: snapRevision,
      voteUp: voteUp,
    );
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    await _userClient.vote(request, options: callOptions);
  }
}
