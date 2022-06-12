import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: _controller,
        onChanged: (value) => model.searchQuery = value,
        autofocus: true,
        decoration: InputDecoration(
          prefixIcon: model.searchQuery == ''
              ? null
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
        ),
      ),
    );
  }
}
