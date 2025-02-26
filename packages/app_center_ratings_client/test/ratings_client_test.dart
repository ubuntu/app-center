import 'dart:async';

import 'package:app_center_ratings_client/app_center_ratings_client.dart'
    hide Rating, RatingsBand, Vote;
import 'package:app_center_ratings_client/src/chart.dart' as chart;
import 'package:app_center_ratings_client/src/generated/google/protobuf/empty.pb.dart';
import 'package:app_center_ratings_client/src/generated/google/protobuf/timestamp.pb.dart';
import 'package:app_center_ratings_client/src/generated/ratings_features_app.pbgrpc.dart'
    as pb;
import 'package:app_center_ratings_client/src/generated/ratings_features_chart.pbgrpc.dart'
    as pb_chart;
import 'package:app_center_ratings_client/src/generated/ratings_features_common.pb.dart';
import 'package:app_center_ratings_client/src/generated/ratings_features_user.pbgrpc.dart';
import 'package:app_center_ratings_client/src/ratings.dart' as ratings;
import 'package:app_center_ratings_client/src/vote.dart' as user;
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'ratings_client_test.mocks.dart';

@GenerateMocks([pb.AppClient, UserClient, pb_chart.ChartClient])
void main() {
  final mockAppClient = MockAppClient();
  final mockUserClient = MockUserClient();
  final mockChartClient = MockChartClient();
  final ratingsClient =
      RatingsClient.withClients(mockAppClient, mockUserClient, mockChartClient);

  test('get chart', () async {
    const snapId = 'foobar';
    const token = 'bar';
    const timeframe = chart.Timeframe.month;
    const snapName = 'foobarName';
    final pbChartList = [
      pb_chart.ChartData(
        rawRating: 3,
        rating: Rating(
          snapId: snapId,
          totalVotes: Int64(105),
          ratingsBand: RatingsBand.NEUTRAL,
          snapName: snapName,
        ),
      ),
    ];

    final expectedResponse = [
      const chart.ChartData(
        rawRating: 3,
        rating: ratings.Rating(
          snapId: snapId,
          totalVotes: 105,
          ratingsBand: ratings.RatingsBand.neutral,
          snapName: snapName,
        ),
      ),
    ];
    final mockResponse = pb_chart.GetChartResponse(
      timeframe: pb_chart.Timeframe.TIMEFRAME_MONTH,
      orderedChartData: pbChartList,
    );
    final request = pb_chart.GetChartRequest(
      timeframe: pb_chart.Timeframe.TIMEFRAME_MONTH,
      category: pb_chart.Category.GAMES,
    );
    when(
      mockChartClient.getChart(
        request,
        options: anyNamed('options'),
      ),
    ).thenAnswer(
      (_) => MockResponseFuture<pb_chart.GetChartResponse>(mockResponse),
    );
    final response = await ratingsClient.getChart(
      timeframe,
      token,
      pb_chart.Category.GAMES,
    );
    expect(
      response,
      equals(expectedResponse),
    );
    final capturedArgs = verify(
      mockChartClient.getChart(
        request,
        options: captureAnyNamed('options'),
      ),
    ).captured;
    final capturedOptions = capturedArgs.single as CallOptions;
    expect(
      capturedOptions.metadata,
      containsPair(
        'authorization',
        'Bearer $token',
      ),
    );
  });

  test('get rating', () async {
    const snapId = 'foo';
    const token = 'bar';
    const snapName = 'fooName';
    final pbRating = Rating(
      snapId: snapId,
      totalVotes: Int64(105),
      ratingsBand: RatingsBand.NEUTRAL,
      snapName: snapName,
    );
    const expectedResponse = ratings.Rating(
      snapId: snapId,
      totalVotes: 105,
      ratingsBand: ratings.RatingsBand.neutral,
      snapName: snapName,
    );
    final mockResponse = pb.GetRatingResponse(rating: pbRating);
    final request = pb.GetRatingRequest(snapName: snapName, snapId: snapId);
    when(
      mockAppClient.getRating(
        request,
        options: anyNamed('options'),
      ),
    ).thenAnswer(
      (_) => MockResponseFuture<pb.GetRatingResponse>(mockResponse),
    );
    final response = await ratingsClient.getRating(
      snapName,
      snapId,
      token,
    );
    expect(
      response,
      equals(expectedResponse),
    );
    final capturedArgs = verify(
      mockAppClient.getRating(
        request,
        options: captureAnyNamed('options'),
      ),
    ).captured;
    final capturedOptions = capturedArgs.single as CallOptions;
    expect(
      capturedOptions.metadata,
      containsPair(
        'authorization',
        'Bearer $token',
      ),
    );
  });

  test('authenticate user', () async {
    const id = 'foo';
    const token = 'bar';
    final mockResponse = AuthenticateResponse(token: token);
    final request = AuthenticateRequest(id: id);
    when(mockUserClient.authenticate(request)).thenAnswer(
      (_) => MockResponseFuture<AuthenticateResponse>(mockResponse),
    );
    final response = await ratingsClient.authenticate(id);
    verify(mockUserClient.authenticate(request)).captured;
    expect(
      response,
      equals(token),
    );
  });

  test('user votes', () async {
    const snapId = 'foo';
    const snapName = 'fooName';
    const snapRevision = 1;
    const voteUp = true;
    const token = 'bar';
    final request = VoteRequest(
      snapName: snapName,
      snapId: snapId,
      snapRevision: snapRevision,
      voteUp: voteUp,
    );

    when(
      mockUserClient.vote(
        request,
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) => MockResponseFuture<Empty>(Empty()));
    await ratingsClient.vote(
      snapName,
      snapId,
      snapRevision,
      voteUp,
      token,
    );
    final capturedArgs = verify(
      mockUserClient.vote(
        request,
        options: captureAnyNamed('options'),
      ),
    ).captured;
    final capturedOptions = capturedArgs.single as CallOptions;
    expect(
      capturedOptions.metadata,
      containsPair(
        'authorization',
        'Bearer $token',
      ),
    );
  });

  test('user votes by snap id', () async {
    const snapId = '123';
    const token = 'bar';
    const snapName = 'foo';
    final time = DateTime.now().toUtc();
    final mockVotes = <Vote>[
      Vote(
        snapId: snapId,
        snapRevision: 1,
        voteUp: true,
        timestamp: Timestamp.fromDateTime(time),
        snapName: snapName,
      ),
      Vote(
        snapId: snapId,
        snapRevision: 2,
        voteUp: false,
        timestamp: Timestamp.fromDateTime(time),
        snapName: snapName,
      ),
    ];
    final expectedResponse = <user.Vote>[
      user.Vote(
        snapId: snapId,
        snapRevision: 1,
        voteUp: true,
        dateTime: time,
        snapName: snapName,
      ),
      user.Vote(
        snapId: snapId,
        snapRevision: 2,
        voteUp: false,
        dateTime: time,
        snapName: snapName,
      ),
    ];
    final mockResponse = GetSnapVotesResponse(votes: mockVotes);
    final request = GetSnapVotesRequest(snapId: snapId);

    when(
      mockUserClient.getSnapVotes(
        request,
        options: anyNamed('options'),
      ),
    ).thenAnswer(
      (_) => MockResponseFuture<GetSnapVotesResponse>(mockResponse),
    );
    final response = await ratingsClient.getSnapVotes(
      snapId,
      token,
    );
    expect(response, equals(expectedResponse));

    final capturedArgs = verify(
      mockUserClient.getSnapVotes(
        request,
        options: captureAnyNamed('options'),
      ),
    ).captured;
    final capturedOptions = capturedArgs.single as CallOptions;
    expect(
      capturedOptions.metadata,
      containsPair(
        'authorization',
        'Bearer $token',
      ),
    );
  });

  test('delete user', () async {
    const token = 'bar';
    final request = Empty();

    when(
      mockUserClient.delete(
        request,
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) => MockResponseFuture<Empty>(Empty()));
    await ratingsClient.delete(token);

    final capturedArgs = verify(
      mockUserClient.delete(request, options: captureAnyNamed('options')),
    ).captured;
    final capturedOptions = capturedArgs.single as CallOptions;
    expect(
      capturedOptions.metadata,
      containsPair(
        'authorization',
        'Bearer $token',
      ),
    );
  });
}

class MockResponseFuture<T> extends Mock implements ResponseFuture<T> {
  MockResponseFuture(this.value);
  final T value;

  @override
  Future<S> then<S>(FutureOr<S> Function(T) onValue, {Function? onError}) =>
      Future.value(value).then(
        onValue,
        onError: onError,
      );
}
