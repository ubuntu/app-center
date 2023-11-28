import 'package:freezed_annotation/freezed_annotation.dart';

import 'generated/ratings_features_chart.pb.dart' as pb;
import 'ratings.dart' as common;

part 'chart.freezed.dart';

@freezed
class ChartData with _$ChartData {
  const factory ChartData({
    required double rawRating,
    required common.Rating rating,
  }) = _ChartData;
}

enum Timeframe {
  unspecified,
  week,
  month,
}

extension ChartDataFromDTO on pb.ChartData {
  ChartData fromDTO() {
    return ChartData(
      rating: this.rating.fromDTO(),
      rawRating: this.rawRating,
    );
  }
}

extension TimeframeFromDTO on pb.Timeframe {
  Timeframe fromDTO() {
    return switch (this) {
      pb.Timeframe.TIMEFRAME_UNSPECIFIED => Timeframe.unspecified,
      pb.Timeframe.TIMEFRAME_WEEK => Timeframe.week,
      pb.Timeframe.TIMEFRAME_MONTH => Timeframe.month,
      _ => Timeframe.unspecified,
    };
  }
}

extension TimeframeToDTO on Timeframe {
  pb.Timeframe toDTO() {
    return switch (this) {
      Timeframe.unspecified => pb.Timeframe.TIMEFRAME_UNSPECIFIED,
      Timeframe.week => pb.Timeframe.TIMEFRAME_WEEK,
      Timeframe.month => pb.Timeframe.TIMEFRAME_MONTH,
    };
  }
}
