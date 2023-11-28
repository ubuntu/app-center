//
//  Generated code. Do not modify.
//  source: ratings_features_common.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use ratingsBandDescriptor instead')
const RatingsBand$json = {
  '1': 'RatingsBand',
  '2': [
    {'1': 'VERY_GOOD', '2': 0},
    {'1': 'GOOD', '2': 1},
    {'1': 'NEUTRAL', '2': 2},
    {'1': 'POOR', '2': 3},
    {'1': 'VERY_POOR', '2': 4},
    {'1': 'INSUFFICIENT_VOTES', '2': 5},
  ],
};

/// Descriptor for `RatingsBand`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List ratingsBandDescriptor = $convert.base64Decode(
    'CgtSYXRpbmdzQmFuZBINCglWRVJZX0dPT0QQABIICgRHT09EEAESCwoHTkVVVFJBTBACEggKBF'
    'BPT1IQAxINCglWRVJZX1BPT1IQBBIWChJJTlNVRkZJQ0lFTlRfVk9URVMQBQ==');

@$core.Deprecated('Use ratingDescriptor instead')
const Rating$json = {
  '1': 'Rating',
  '2': [
    {'1': 'snap_id', '3': 1, '4': 1, '5': 9, '10': 'snapId'},
    {'1': 'total_votes', '3': 2, '4': 1, '5': 4, '10': 'totalVotes'},
    {
      '1': 'ratings_band',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.ratings.features.common.RatingsBand',
      '10': 'ratingsBand'
    },
  ],
};

/// Descriptor for `Rating`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ratingDescriptor = $convert.base64Decode(
    'CgZSYXRpbmcSFwoHc25hcF9pZBgBIAEoCVIGc25hcElkEh8KC3RvdGFsX3ZvdGVzGAIgASgEUg'
    'p0b3RhbFZvdGVzEkcKDHJhdGluZ3NfYmFuZBgDIAEoDjIkLnJhdGluZ3MuZmVhdHVyZXMuY29t'
    'bW9uLlJhdGluZ3NCYW5kUgtyYXRpbmdzQmFuZA==');
