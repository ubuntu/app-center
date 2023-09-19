import 'dart:convert';
import 'dart:io';

import 'package:app_center_ratings_client/ratings_client.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:glib/glib.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'exports.dart';

class RatingsService {
  RatingsService(String url, int port,
      [@visibleForTesting RatingsClient? client])
      : _client = client ?? RatingsClient(url, port),
        _id = _generateId();

  final RatingsClient _client;
  String? _jwt;
  final String _id;

  static String _generateId() {
    final username = glib.getUserName();
    final machineId = File('/etc/machine-id').readAsStringSync().trim();
    return sha256.convert(utf8.encode('[$username:$machineId]')).toString();
  }

  Future<void> _ensureValidToken() async {
    if (_jwt == null || Jwt.isExpired(_jwt!)) {
      _jwt = await _client.authenticate(_id);
    }
  }

  Future<Rating?> getRating(String snapId) async {
    await _ensureValidToken();
    return _client.getRating(snapId, _jwt!);
  }

  Future<void> vote(Vote vote) async {
    await _ensureValidToken();
    await _client.vote(vote.snapId, vote.snapRevision, vote.voteUp, _jwt!);
  }

  Future<void> delete() async {
    await _ensureValidToken();
    await _client.delete(_jwt!);
  }

  Future<List<Vote>> listMyVotes(String snapFilter) async {
    await _ensureValidToken();
    return await _client.listMyVotes(snapFilter, _jwt!);
  }

  Future<List<Vote>> getSnapVotes(String snapId) async {
    await _ensureValidToken();
    return await _client.getSnapVotes(snapId, _jwt!);
  }
}
