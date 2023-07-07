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

class SearchField extends ConsumerStatefulWidget {
  const SearchField({
    super.key,
    required this.onSearch,
    required this.onSelected,
  });

  final ValueChanged<String> onSearch;
  final ValueChanged<String> onSelected;

  @override
  ConsumerState<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<SearchField> {
  double? _optionsWidth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final width = (context.findRenderObject() as RenderBox?)?.size.width;
      if (_optionsWidth != width) {
        setState(() => _optionsWidth = width);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RawAutocomplete<SnapAutoCompleteOption>(
      optionsBuilder: (query) async {
        ref.read(queryProvider.notifier).state = query.text;
        final options = await ref.watch(autoCompleteProvider.future);
        if (options.isEmpty) return [];
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
            width: _optionsWidth,
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
                                l10n.searchFieldSearchForLabel(option.query)),
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
          ? widget.onSelected(option.snap!.name)
          : widget.onSearch(option.query),
      fieldViewBuilder: (context, controller, node, onFieldSubmitted) {
        return TextField(
          focusNode: node,
          controller: controller,
          onSubmitted: (_) => onFieldSubmitted(),
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
