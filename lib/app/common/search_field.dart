/*
 * Copyright (C) 2022 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.searchQuery,
    required this.onChanged,
  });

  final String searchQuery;
  final Function(String value) onChanged;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.searchQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onDoubleTap() {
    _controller.selection =
        TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      onKeyEvent: (value) {
        if (value.logicalKey == LogicalKeyboardKey.escape) {
          _clear();
        }
      },
      focusNode: FocusNode(),
      child: GestureDetector(
        onDoubleTap: onDoubleTap,
        child: SizedBox(
          width: 400,
          child: TextField(
            autofocus: true,
            controller: _controller,
            onChanged: widget.onChanged,
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              hintText: context.l10n.searchHint,
              prefixIcon: MediaQuery.of(context).size.width < 611
                  ? null
                  : const Icon(
                      YaruIcons.search,
                      size: 20,
                    ),
              prefixIconConstraints: const BoxConstraints(
                minHeight: 44,
                minWidth: 40,
              ),
              isDense: false,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clear() {
    widget.onChanged('');
    _controller.clear();
  }
}
