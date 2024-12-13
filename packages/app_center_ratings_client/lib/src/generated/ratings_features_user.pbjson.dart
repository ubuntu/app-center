//
//  Generated code. Do not modify.
//  source: ratings_features_user.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use authenticateRequestDescriptor instead')
const AuthenticateRequest$json = {
  '1': 'AuthenticateRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `AuthenticateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authenticateRequestDescriptor = $convert.base64Decode(
    'ChNBdXRoZW50aWNhdGVSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use authenticateResponseDescriptor instead')
const AuthenticateResponse$json = {
  '1': 'AuthenticateResponse',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `AuthenticateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authenticateResponseDescriptor = $convert.base64Decode(
    'ChRBdXRoZW50aWNhdGVSZXNwb25zZRIUCgV0b2tlbhgBIAEoCVIFdG9rZW4=');

@$core.Deprecated('Use listMyVotesRequestDescriptor instead')
const ListMyVotesRequest$json = {
  '1': 'ListMyVotesRequest',
  '2': [
    {'1': 'snap_id_filter', '3': 1, '4': 1, '5': 9, '10': 'snapIdFilter'},
  ],
};

/// Descriptor for `ListMyVotesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMyVotesRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0TXlWb3Rlc1JlcXVlc3QSJAoOc25hcF9pZF9maWx0ZXIYASABKAlSDHNuYXBJZEZpbH'
    'Rlcg==');

@$core.Deprecated('Use listMyVotesResponseDescriptor instead')
const ListMyVotesResponse$json = {
  '1': 'ListMyVotesResponse',
  '2': [
    {'1': 'votes', '3': 1, '4': 3, '5': 11, '6': '.ratings.features.user.Vote', '10': 'votes'},
  ],
};

/// Descriptor for `ListMyVotesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMyVotesResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0TXlWb3Rlc1Jlc3BvbnNlEjEKBXZvdGVzGAEgAygLMhsucmF0aW5ncy5mZWF0dXJlcy'
    '51c2VyLlZvdGVSBXZvdGVz');

@$core.Deprecated('Use getSnapVotesRequestDescriptor instead')
const GetSnapVotesRequest$json = {
  '1': 'GetSnapVotesRequest',
  '2': [
    {'1': 'snap_id', '3': 1, '4': 1, '5': 9, '10': 'snapId'},
  ],
};

/// Descriptor for `GetSnapVotesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSnapVotesRequestDescriptor = $convert.base64Decode(
    'ChNHZXRTbmFwVm90ZXNSZXF1ZXN0EhcKB3NuYXBfaWQYASABKAlSBnNuYXBJZA==');

@$core.Deprecated('Use getSnapVotesResponseDescriptor instead')
const GetSnapVotesResponse$json = {
  '1': 'GetSnapVotesResponse',
  '2': [
    {'1': 'votes', '3': 1, '4': 3, '5': 11, '6': '.ratings.features.user.Vote', '10': 'votes'},
  ],
};

/// Descriptor for `GetSnapVotesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSnapVotesResponseDescriptor = $convert.base64Decode(
    'ChRHZXRTbmFwVm90ZXNSZXNwb25zZRIxCgV2b3RlcxgBIAMoCzIbLnJhdGluZ3MuZmVhdHVyZX'
    'MudXNlci5Wb3RlUgV2b3Rlcw==');

@$core.Deprecated('Use voteDescriptor instead')
const Vote$json = {
  '1': 'Vote',
  '2': [
    {'1': 'snap_id', '3': 1, '4': 1, '5': 9, '10': 'snapId'},
    {'1': 'snap_revision', '3': 2, '4': 1, '5': 5, '10': 'snapRevision'},
    {'1': 'vote_up', '3': 3, '4': 1, '5': 8, '10': 'voteUp'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timestamp'},
    {'1': 'snap_name', '3': 5, '4': 1, '5': 9, '10': 'snapName'},
  ],
};

/// Descriptor for `Vote`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteDescriptor = $convert.base64Decode(
    'CgRWb3RlEhcKB3NuYXBfaWQYASABKAlSBnNuYXBJZBIjCg1zbmFwX3JldmlzaW9uGAIgASgFUg'
    'xzbmFwUmV2aXNpb24SFwoHdm90ZV91cBgDIAEoCFIGdm90ZVVwEjgKCXRpbWVzdGFtcBgEIAEo'
    'CzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBIbCglzbmFwX25hbWUYBS'
    'ABKAlSCHNuYXBOYW1l');

@$core.Deprecated('Use voteRequestDescriptor instead')
const VoteRequest$json = {
  '1': 'VoteRequest',
  '2': [
    {'1': 'snap_id', '3': 1, '4': 1, '5': 9, '10': 'snapId'},
    {'1': 'snap_revision', '3': 2, '4': 1, '5': 5, '10': 'snapRevision'},
    {'1': 'vote_up', '3': 3, '4': 1, '5': 8, '10': 'voteUp'},
  ],
};

/// Descriptor for `VoteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voteRequestDescriptor = $convert.base64Decode(
    'CgtWb3RlUmVxdWVzdBIXCgdzbmFwX2lkGAEgASgJUgZzbmFwSWQSIwoNc25hcF9yZXZpc2lvbh'
    'gCIAEoBVIMc25hcFJldmlzaW9uEhcKB3ZvdGVfdXAYAyABKAhSBnZvdGVVcA==');

