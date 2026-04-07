import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github/github.dart';

import 'package:ubuntu_service/ubuntu_service.dart';

final contributorsProvider = FutureProvider.autoDispose
    .family<List<Contributor>, String>((ref, repo) async {
  const designers = {'anasereijo', 'elioqoshi', 'Zoospora'};
  const exclude = {'weblate'};
  final contributors = await getService<GitHub>()
      .repositories
      .listContributors(RepositorySlug.full(repo))
      .where(
        (c) =>
            c.type == 'User' &&
            !designers.contains(c.login) &&
            !exclude.contains(c.login),
      )
      .toList();
  return [
    ...designers.map(
      (d) => Contributor(
        login: d,
        htmlUrl: 'https://github.com/$d',
        avatarUrl: 'https://avatars.githubusercontent.com/$d',
      ),
    ),
    ...contributors,
  ].sortedBy((c) => c.login?.toLowerCase() ?? '');
});
