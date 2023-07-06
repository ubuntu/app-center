import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/snapx.dart';
import '/widgets.dart';
import 'search_provider.dart';

typedef SnapAutoCompleteOption = ({Snap? snap, String query});

class SearchField extends ConsumerWidget {
  const SearchField({
    super.key,
    required this.onSearch,
    required this.onSelected,
  });

  final ValueChanged<String> onSearch;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return RawAutocomplete<SnapAutoCompleteOption>(
      optionsBuilder: (query) async {
        if (query.text.isEmpty) return [];
        final options = await ref.watch(searchProvider(query.text).future);
        return options
            .take(5)
            .map<SnapAutoCompleteOption>(
                (snap) => (snap: snap, query: query.text))
            .followedBy([(snap: null, query: query.text)]);
      },
      displayStringForOption: (option) => option.snap?.name ?? option.query,
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4.0,
          child: SizedBox(
            width: 500,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return InkWell(
                  onTap: () => onSelected(option),
                  child: Builder(builder: (context) {
                    final bool highlight =
                        AutocompleteHighlightedOption.of(context) == index;
                    if (highlight) {
                      SchedulerBinding.instance
                          .addPostFrameCallback((Duration timeStamp) {
                        Scrollable.ensureVisible(context, alignment: 0.5);
                      });
                    }
                    return option.snap != null
                        ? ListTile(
                            selected: highlight,
                            contentPadding: const EdgeInsets.all(8),
                            leading: SnapIcon(iconUrl: option.snap!.iconUrl),
                            title: Text(option.snap!.titleOrName),
                          )
                        : ListTile(
                            title: Text(
                                l10n.searchFieldsearchForLabel(option.query)),
                            selected: highlight,
                          );
                  }),
                );
              },
            ),
          ),
        ),
      ),
      onSelected: (option) => option.snap != null
          ? onSelected(option.snap!.name)
          : onSearch(option.query),
      fieldViewBuilder: (context, controller, node, onFieldSubmitted) {
        return TextField(
          focusNode: node,
          controller: controller,
          onSubmitted: (_) {
            onFieldSubmitted();
            controller.clear();
          },
          decoration: InputDecoration(
            suffixIcon: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return YaruIconButton(
                  icon: const Icon(YaruIcons.edit_clear),
                  onPressed: controller.text.isEmpty ? null : controller.clear,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
