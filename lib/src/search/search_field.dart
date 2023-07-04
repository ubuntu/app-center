import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onSubmitted: (query) {
        widget.onSearch(query);
        _controller.clear();
      },
      decoration: InputDecoration(
        suffixIcon: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return YaruIconButton(
              icon: const Icon(YaruIcons.edit_clear),
              onPressed: _controller.text.isEmpty ? null : _controller.clear,
            );
          },
        ),
      ),
    );
  }
}
