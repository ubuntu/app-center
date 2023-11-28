import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';

import 'src/chart.dart';
import 'src/generated/google/protobuf/empty.pb.dart';
import 'src/generated/ratings_features_app.pbgrpc.dart' as appPb;
import 'src/generated/ratings_features_chart.pbgrpc.dart' as chartPb;
import 'src/generated/ratings_features_user.pbgrpc.dart' as userPb;
import 'src/ratings.dart';
import 'src/user.dart';

export 'src/ratings.dart' hide RatingsBandL10n;

class RatingsClient {
  late appPb.AppClient _appClient;
  late userPb.UserClient _userClient;
  late chartPb.ChartClient _chartClient;

  RatingsClient(String serverUrl, int port) {
    final channel = ClientChannel(
      serverUrl,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _appClient = appPb.AppClient(channel);
    _userClient = userPb.UserClient(channel);
    _chartClient = chartPb.ChartClient(channel);
  }

  // Additional constructor for testing
  @visibleForTesting
  RatingsClient.withClients(
    this._appClient,
    this._userClient,
    this._chartClient,
  );

  Future<String> authenticate(String id) async {
    final request = userPb.AuthenticateRequest(id: id);
    final grpcResponse = await _userClient.authenticate(request);
    return grpcResponse.token;
  }

  Future<void> delete(String token) async {
    final request = Empty();
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    await _userClient.delete(request, options: callOptions);
  }

  Future<List<ChartData>> getChart(Timeframe timeframe, String token) async {
    final request = chartPb.GetChartRequest(timeframe: timeframe.toDTO());
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
    final request = appPb.GetRatingRequest(snapId: snapId);
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    final grpcResponse = await _appClient.getRating(
      request,
      options: callOptions,
    );
    return grpcResponse.rating.fromDTO();
  }

  Future<List<Vote>> getSnapVotes(String snap_id, String token) async {
    final request = userPb.GetSnapVotesRequest(snapId: snap_id);
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    final grpcResponse = await _userClient.getSnapVotes(
      request,
      options: callOptions,
    );
    return grpcResponse.votes.map((vote) => vote.fromDTO()).toList();
  }

  Future<List<Vote>> listMyVotes(String snapIdFilter, String token) async {
    final request = userPb.ListMyVotesRequest(snapIdFilter: snapIdFilter);
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    final grpcResponse = await _userClient.listMyVotes(
      request,
      options: callOptions,
    );
    return grpcResponse.votes.map((vote) => vote.fromDTO()).toList();
  }

  Future<void> vote(
      String snapId, int snapRevision, bool voteUp, String token) async {
    final request = userPb.VoteRequest(
      snapId: snapId,
      snapRevision: snapRevision,
      voteUp: voteUp,
    );
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    await _userClient.vote(request, options: callOptions);
  }
}
