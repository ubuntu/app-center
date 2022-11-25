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
import 'package:yaru_icons/yaru_icons.dart';

import '../../l10n/l10n.dart';

class MyAppSearchField extends StatefulWidget {
  const MyAppSearchField({
    super.key,
    required this.searchQuery,
    required this.onChanged,
    required this.clear,
  });

  final String searchQuery;
  final Function(String value) onChanged;
  final Function() clear;

  @override
  State<MyAppSearchField> createState() => _MyAppSearchFieldState();
}

class _MyAppSearchFieldState extends State<MyAppSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      onKeyEvent: (value) {
        if (value.logicalKey == LogicalKeyboardKey.escape) {
          if (widget.searchQuery.isNotEmpty) {
            widget.clear();
            _controller.clear();
          }
        }
      },
      focusNode: FocusNode(),
      child: TextField(
        autofocus: true,
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: context.l10n.searchHint,
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Icon(
              YaruIcons.search,
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minHeight: 45,
            minWidth: 40,
          ),
          isDense: false,
          border: const UnderlineInputBorder(),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    onPressed: () {
                      widget.clear();
                      _controller.clear();
                    },
                    icon: Icon(
                      YaruIcons.edit_clear,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
