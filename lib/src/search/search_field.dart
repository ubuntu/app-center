import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/appstream.dart';
import '/snapd.dart';
import '/widgets.dart';
import 'search_provider.dart';

sealed class AutoCompleteOption {
  String get title => switch (this) {
        AutoCompleteSnapOption(snap: final snap) => snap.titleOrName,
        AutoCompleteDebOption(deb: final deb) => deb.getLocalizedName(),
        AutoCompleteSectionOption(section: final section) => section,
        AutoCompleteSearchOption(query: final query) => query,
        AutoCompleteDividerOption() => '',
      };
  bool get selectable => switch (this) {
        AutoCompleteSectionOption() || AutoCompleteDividerOption() => false,
        _ => true,
      };
}

class AutoCompleteSnapOption extends AutoCompleteOption {
  final Snap snap;
  AutoCompleteSnapOption(this.snap);
}

class AutoCompleteDebOption extends AutoCompleteOption {
  final AppstreamComponent deb;
  AutoCompleteDebOption(this.deb);
}

class AutoCompleteSectionOption extends AutoCompleteOption {
  final String section;
  AutoCompleteSectionOption(this.section);
}

class AutoCompleteSearchOption extends AutoCompleteOption {
  final String query;
  AutoCompleteSearchOption(this.query);
}

class AutoCompleteDividerOption extends AutoCompleteOption {}

class SearchField extends ConsumerStatefulWidget {
  const SearchField({
    super.key,
    required this.onSearch,
    required this.onSnapSelected,
    required this.onDebSelected,
  });

  final ValueChanged<String> onSearch;
  final ValueChanged<String> onSnapSelected;
  final ValueChanged<AppstreamComponent> onDebSelected;

  @override
  ConsumerState<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<SearchField> {
  double? _optionsWidth;
  bool _optionsAvailable = false;

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
    return RawAutocomplete<AutoCompleteOption>(
      optionsBuilder: (query) async {
        ref.read(queryProvider.notifier).state = query.text;
        final options = await ref.watch(autoCompleteProvider.future);
        if (options.snaps.isEmpty && options.debs.isEmpty) return [];
        final snapOptions = options.snaps
            .take(3)
            .map<AutoCompleteOption>(AutoCompleteSnapOption.new)
            .toList();
        final debOptions = options.debs
            .take(3)
            .map<AutoCompleteOption>(AutoCompleteDebOption.new)
            .toList();
        return <AutoCompleteOption>[
          if (snapOptions.isNotEmpty) ...[
            AutoCompleteSectionOption(l10n.searchFieldSnapSection),
            ...snapOptions,
            AutoCompleteDividerOption()
          ],
          if (debOptions.isNotEmpty) ...[
            AutoCompleteSectionOption(l10n.searchFieldDebSection),
            ...debOptions,
            AutoCompleteDividerOption(),
          ],
          AutoCompleteSearchOption(query.text),
        ];
      },
      displayStringForOption: (option) => option.title,
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
                _optionsAvailable = options.isNotEmpty;
                return InkWell(
                  onTap: option.selectable ? () => onSelected(option) : null,
                  child: Builder(builder: (context) {
                    final bool selected =
                        AutocompleteHighlightedOption.of(context) == index;
                    if (selected) {
                      SchedulerBinding.instance
                          .addPostFrameCallback((Duration timeStamp) {
                        Scrollable.ensureVisible(context, alignment: 0.5);
                      });
                    }
                    return _AutoCompleteTile(
                      option: option,
                      selected: selected,
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ),
      onSelected: (option) => switch (option) {
        AutoCompleteSnapOption(snap: final snap) =>
          widget.onSnapSelected(snap.name),
        AutoCompleteDebOption(deb: final deb) => widget.onDebSelected(deb),
        AutoCompleteSearchOption(query: final query) => widget.onSearch(query),
        _ => () {}
      },
      fieldViewBuilder: (context, controller, node, onFieldSubmitted) {
        return Consumer(builder: (context, ref, child) {
          ref.listen(queryProvider, (prev, next) {
            if (!node.hasPrimaryFocus) controller.text = next ?? '';
          });
          const iconConstraints = BoxConstraints(
            minWidth: 32,
            minHeight: 32,
            maxWidth: 32,
            maxHeight: 32,
          );
          return TextField(
            focusNode: node,
            controller: controller,
            onChanged: (_) => _optionsAvailable = false,
            onSubmitted: (query) =>
                _optionsAvailable ? onFieldSubmitted() : widget.onSearch(query),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              fillColor: Theme.of(context).dividerColor,
              prefixIcon: const Icon(YaruIcons.search, size: 16),
              prefixIconConstraints: iconConstraints,
              hintText: l10n.searchFieldSearchHint,
              suffixIcon: AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return YaruIconButton(
                    icon: const Icon(YaruIcons.edit_clear, size: 16),
                    onPressed:
                        controller.text.isEmpty ? null : controller.clear,
                  );
                },
              ),
              suffixIconConstraints: iconConstraints,
            ),
          );
        });
      },
    );
  }
}

class _AutoCompleteTile extends StatelessWidget {
  const _AutoCompleteTile({required this.option, required this.selected});

  static const _iconSize = 32.0;

  final AutoCompleteOption option;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (option) {
      AutoCompleteSnapOption(snap: final snap) => ListTile(
          selected: selected,
          title: Text(snap.titleOrName),
          leading: AppIcon(
            size: _iconSize,
            iconUrl: snap.iconUrl,
          ),
        ),
      AutoCompleteDebOption(deb: final deb) => ListTile(
          selected: selected,
          title: Text(deb.getLocalizedName()),
          leading: AppIcon(
            size: _iconSize,
            iconUrl:
                deb.icons.whereType<AppstreamRemoteIcon>().firstOrNull?.url,
          ),
        ),
      AutoCompleteSearchOption(query: final query) => ListTile(
          selected: selected,
          title: Text(
            l10n.searchFieldSearchForLabel(query),
          ),
        ),
      AutoCompleteSectionOption(section: final section) => ListTile(
          title: Text(
            section,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      AutoCompleteDividerOption() => const Divider(),
    };
  }
}
