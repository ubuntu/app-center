//
//  Generated code. Do not modify.
//  source: ratings_features_chart.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use timeframeDescriptor instead')
const Timeframe$json = {
  '1': 'Timeframe',
  '2': [
    {'1': 'TIMEFRAME_UNSPECIFIED', '2': 0},
    {'1': 'TIMEFRAME_WEEK', '2': 1},
    {'1': 'TIMEFRAME_MONTH', '2': 2},
  ],
};

/// Descriptor for `Timeframe`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List timeframeDescriptor = $convert.base64Decode(
    'CglUaW1lZnJhbWUSGQoVVElNRUZSQU1FX1VOU1BFQ0lGSUVEEAASEgoOVElNRUZSQU1FX1dFRU'
    'sQARITCg9USU1FRlJBTUVfTU9OVEgQAg==');

@$core.Deprecated('Use categoryDescriptor instead')
const Category$json = {
  '1': 'Category',
  '2': [
    {'1': 'ART_AND_DESIGN', '2': 0},
    {'1': 'BOOK_AND_REFERENCE', '2': 1},
    {'1': 'DEVELOPMENT', '2': 2},
    {'1': 'DEVICES_AND_IOT', '2': 3},
    {'1': 'EDUCATION', '2': 4},
    {'1': 'ENTERTAINMENT', '2': 5},
    {'1': 'FEATURED', '2': 6},
    {'1': 'FINANCE', '2': 7},
    {'1': 'GAMES', '2': 8},
    {'1': 'HEALTH_AND_FITNESS', '2': 9},
    {'1': 'MUSIC_AND_AUDIO', '2': 10},
    {'1': 'NEWS_AND_WEATHER', '2': 11},
    {'1': 'PERSONALISATION', '2': 12},
    {'1': 'PHOTO_AND_VIDEO', '2': 13},
    {'1': 'PRODUCTIVITY', '2': 14},
    {'1': 'SCIENCE', '2': 15},
    {'1': 'SECURITY', '2': 16},
    {'1': 'SERVER_AND_CLOUD', '2': 17},
    {'1': 'SOCIAL', '2': 18},
    {'1': 'UTILITIES', '2': 19},
  ],
};

/// Descriptor for `Category`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List categoryDescriptor = $convert.base64Decode(
    'CghDYXRlZ29yeRISCg5BUlRfQU5EX0RFU0lHThAAEhYKEkJPT0tfQU5EX1JFRkVSRU5DRRABEg'
    '8KC0RFVkVMT1BNRU5UEAISEwoPREVWSUNFU19BTkRfSU9UEAMSDQoJRURVQ0FUSU9OEAQSEQoN'
    'RU5URVJUQUlOTUVOVBAFEgwKCEZFQVRVUkVEEAYSCwoHRklOQU5DRRAHEgkKBUdBTUVTEAgSFg'
    'oSSEVBTFRIX0FORF9GSVRORVNTEAkSEwoPTVVTSUNfQU5EX0FVRElPEAoSFAoQTkVXU19BTkRf'
    'V0VBVEhFUhALEhMKD1BFUlNPTkFMSVNBVElPThAMEhMKD1BIT1RPX0FORF9WSURFTxANEhAKDF'
    'BST0RVQ1RJVklUWRAOEgsKB1NDSUVOQ0UQDxIMCghTRUNVUklUWRAQEhQKEFNFUlZFUl9BTkRf'
    'Q0xPVUQQERIKCgZTT0NJQUwQEhINCglVVElMSVRJRVMQEw==');

@$core.Deprecated('Use getChartRequestDescriptor instead')
const GetChartRequest$json = {
  '1': 'GetChartRequest',
  '2': [
    {'1': 'timeframe', '3': 1, '4': 1, '5': 14, '6': '.ratings.features.chart.Timeframe', '10': 'timeframe'},
    {'1': 'category', '3': 2, '4': 1, '5': 14, '6': '.ratings.features.chart.Category', '9': 0, '10': 'category', '17': true},
  ],
  '8': [
    {'1': '_category'},
  ],
};

/// Descriptor for `GetChartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChartRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRDaGFydFJlcXVlc3QSPwoJdGltZWZyYW1lGAEgASgOMiEucmF0aW5ncy5mZWF0dXJlcy'
    '5jaGFydC5UaW1lZnJhbWVSCXRpbWVmcmFtZRJBCghjYXRlZ29yeRgCIAEoDjIgLnJhdGluZ3Mu'
    'ZmVhdHVyZXMuY2hhcnQuQ2F0ZWdvcnlIAFIIY2F0ZWdvcnmIAQFCCwoJX2NhdGVnb3J5');

@$core.Deprecated('Use getChartResponseDescriptor instead')
const GetChartResponse$json = {
  '1': 'GetChartResponse',
  '2': [
    {'1': 'timeframe', '3': 1, '4': 1, '5': 14, '6': '.ratings.features.chart.Timeframe', '10': 'timeframe'},
    {'1': 'ordered_chart_data', '3': 2, '4': 3, '5': 11, '6': '.ratings.features.chart.ChartData', '10': 'orderedChartData'},
    {'1': 'category', '3': 3, '4': 1, '5': 14, '6': '.ratings.features.chart.Category', '9': 0, '10': 'category', '17': true},
  ],
  '8': [
    {'1': '_category'},
  ],
};

/// Descriptor for `GetChartResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getChartResponseDescriptor = $convert.base64Decode(
    'ChBHZXRDaGFydFJlc3BvbnNlEj8KCXRpbWVmcmFtZRgBIAEoDjIhLnJhdGluZ3MuZmVhdHVyZX'
    'MuY2hhcnQuVGltZWZyYW1lUgl0aW1lZnJhbWUSTwoSb3JkZXJlZF9jaGFydF9kYXRhGAIgAygL'
    'MiEucmF0aW5ncy5mZWF0dXJlcy5jaGFydC5DaGFydERhdGFSEG9yZGVyZWRDaGFydERhdGESQQ'
    'oIY2F0ZWdvcnkYAyABKA4yIC5yYXRpbmdzLmZlYXR1cmVzLmNoYXJ0LkNhdGVnb3J5SABSCGNh'
    'dGVnb3J5iAEBQgsKCV9jYXRlZ29yeQ==');

@$core.Deprecated('Use chartDataDescriptor instead')
const ChartData$json = {
  '1': 'ChartData',
  '2': [
    {'1': 'raw_rating', '3': 1, '4': 1, '5': 2, '10': 'rawRating'},
    {'1': 'rating', '3': 2, '4': 1, '5': 11, '6': '.ratings.features.common.Rating', '10': 'rating'},
  ],
};

/// Descriptor for `ChartData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chartDataDescriptor = $convert.base64Decode(
    'CglDaGFydERhdGESHQoKcmF3X3JhdGluZxgBIAEoAlIJcmF3UmF0aW5nEjcKBnJhdGluZxgCIA'
    'EoCzIfLnJhdGluZ3MuZmVhdHVyZXMuY29tbW9uLlJhdGluZ1IGcmF0aW5n');

