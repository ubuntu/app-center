import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SearchField extends StatefulWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return TextField(
      controller: _controller,
      onChanged: (value) => model.searchQuery = value,
      autofocus: true,
      decoration: InputDecoration(
        suffixIcon: DropdownButton<SnapSection>(
          underline: const SizedBox(),
          value: model.selectedSection,
          borderRadius: BorderRadius.circular(10),
          elevation: 2,
          items: [
            for (final section in SnapSection.values)
              DropdownMenuItem(
                value: section,
                child: Row(
                  children: [
                    Icon(
                      snapSectionToIcon[section],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(section.localize(context.l10n))
                  ],
                ),
              )
          ],
          onChanged: (v) {
            model.selectedSection = v!;
            model.init();
          },
        ),
        prefixIcon: model.searchQuery == ''
            ? const Icon(YaruIcons.search)
            : YaruRoundIconButton(
                size: 36,
                onTap: () {
                  model.searchQuery = '';
                  _controller.text = '';
                },
                child: const Icon(YaruIcons.edit_clear),
              ),
        isDense: false,
        border: const UnderlineInputBorder(),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}
