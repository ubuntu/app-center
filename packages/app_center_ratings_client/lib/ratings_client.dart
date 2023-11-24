import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';

import 'src/app.dart' as app;
import 'src/generated/google/protobuf/empty.pb.dart';
import 'src/generated/ratings_features_app.pbgrpc.dart';
import 'src/generated/ratings_features_user.pbgrpc.dart';
import 'src/user.dart' as user;

class RatingsClient {
  late AppClient _appClient;
  late UserClient _userClient;

  RatingsClient(String serverUrl, int port) {
    final channel = ClientChannel(
      serverUrl,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _appClient = AppClient(channel);
    _userClient = UserClient(channel);
  }

  // Additional constructor for testing
  @visibleForTesting
  RatingsClient.withClients(
    this._appClient,
    this._userClient,
  );

  Future<app.Rating> getRating(
    String snapId,
    String token,
  ) async {
    final request = GetRatingRequest(snapId: snapId);
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    final grpcResponse = await _appClient.getRating(
      request,
      options: callOptions,
    );
    return grpcResponse.rating.fromDTO();
  }

  Future<String> authenticate(String id) async {
    final request = AuthenticateRequest(id: id);
    final grpcResponse = await _userClient.authenticate(request);
    return grpcResponse.token;
  }

  Future<List<user.Vote>> listMyVotes(String snapIdFilter, String token) async {
    final request = ListMyVotesRequest(snapIdFilter: snapIdFilter);
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
    final request = VoteRequest(
      snapId: snapId,
      snapRevision: snapRevision,
      voteUp: voteUp,
    );
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    await _userClient.vote(request, options: callOptions);
  }

  Future<void> delete(String token) async {
    final request = Empty();
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    await _userClient.delete(request, options: callOptions);
  }

  Future<List<user.Vote>> getSnapVotes(String snap_id, String token) async {
    final request = GetSnapVotesRequest(snapId: snap_id);
    final callOptions =
        CallOptions(metadata: {'authorization': 'Bearer $token'});
    final grpcResponse = await _userClient.getSnapVotes(
      request,
      options: callOptions,
    );
    return grpcResponse.votes.map((vote) => vote.fromDTO()).toList();
  }
}
