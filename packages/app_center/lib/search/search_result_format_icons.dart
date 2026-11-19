import 'package:app_center/l10n.dart';
import 'package:app_center/search/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

/// Marks which package formats a search result has.
class SearchResultFormatIcons extends StatelessWidget {
  const SearchResultFormatIcons(this.result, {super.key});

  final UnifiedSearchResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (result.snap != null)
          Tooltip(
            message: l10n.packageFormatSnapLabel,
            child: const Icon(YaruIcons.package_snap, size: 16),
          ),
        if (result.deb != null)
          Tooltip(
            message: l10n.packageFormatDebLabel,
            child: const Icon(YaruIcons.package_deb, size: 16),
          ),
      ],
    );
  }
}
