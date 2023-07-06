import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github/github.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final contributorsProvider =
    FutureProvider.autoDispose.family((ref, String repo) {
  return getService<GitHub>()
      .repositories
      .listContributors(RepositorySlug.full(repo))
      .toList();
});
