//
//  Generated code. Do not modify.
//  source: ratings_features_app.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getRatingRequestDescriptor instead')
const GetRatingRequest$json = {
  '1': 'GetRatingRequest',
  '2': [
    {'1': 'snap_id', '3': 1, '4': 1, '5': 9, '10': 'snapId'},
    {'1': 'snap_name', '3': 2, '4': 1, '5': 9, '10': 'snapName'},
  ],
};

/// Descriptor for `GetRatingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRatingRequestDescriptor = $convert.base64Decode(
    'ChBHZXRSYXRpbmdSZXF1ZXN0EhcKB3NuYXBfaWQYASABKAlSBnNuYXBJZBIbCglzbmFwX25hbW'
    'UYAiABKAlSCHNuYXBOYW1l');

@$core.Deprecated('Use getRatingResponseDescriptor instead')
const GetRatingResponse$json = {
  '1': 'GetRatingResponse',
  '2': [
    {'1': 'rating', '3': 1, '4': 1, '5': 11, '6': '.ratings.features.common.Rating', '10': 'rating'},
  ],
};

/// Descriptor for `GetRatingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRatingResponseDescriptor = $convert.base64Decode(
    'ChFHZXRSYXRpbmdSZXNwb25zZRI3CgZyYXRpbmcYASABKAsyHy5yYXRpbmdzLmZlYXR1cmVzLm'
    'NvbW1vbi5SYXRpbmdSBnJhdGluZw==');

