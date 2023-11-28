import 'dart:convert';
import 'dart:io';

import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:glib/glib.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'exports.dart';

class RatingsService {
  RatingsService(this.client, {@visibleForTesting String? id})
      : _id = id ?? _generateId();

  final RatingsClient client;
  String? _jwt;
  final String _id;

  static String _generateId() {
    final username = glib.getUserName();
    final machineId = File('/etc/machine-id').readAsStringSync().trim();
    return sha256.convert(utf8.encode('[$username:$machineId]')).toString();
  }

  Future<void> _ensureValidToken() async {
    if (_jwt == null || Jwt.isExpired(_jwt!)) {
      _jwt = await client.authenticate(_id);
    }
  }

  Future<Rating?> getRating(String snapId) async {
    await _ensureValidToken();
    return client.getRating(snapId, _jwt!);
  }

  Future<void> vote(Vote vote) async {
    await _ensureValidToken();
    await client.vote(vote.snapId, vote.snapRevision, vote.voteUp, _jwt!);
  }

  Future<void> delete() async {
    await _ensureValidToken();
    await client.delete(_jwt!);
  }

  Future<List<Vote>> listMyVotes(String snapFilter) async {
    await _ensureValidToken();
    return await client.listMyVotes(snapFilter, _jwt!);
  }

  Future<List<Vote>> getSnapVotes(String snapId) async {
    await _ensureValidToken();
    return await client.getSnapVotes(snapId, _jwt!);
  }
}
