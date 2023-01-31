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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.searchQuery,
    required this.onChanged,
    this.autofocus = true,
    this.hintText,
  });

  final String? searchQuery;
  final Function(String value) onChanged;
  final bool autofocus;
  final String? hintText;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  Timer? onChangedTimer;

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _controller.text = widget.searchQuery!;
    }
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

  void onChanged(String value) {
    onChangedTimer?.cancel();
    setState(() {
      onChangedTimer = Timer(
        const Duration(milliseconds: 200),
        () => widget.onChanged(value),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final borderColor = light ? theme.dividerColor : Colors.transparent;
    return KeyboardListener(
      onKeyEvent: (value) {
        if (value.logicalKey == LogicalKeyboardKey.escape) {
          _clear();
        }
      },
      focusNode: FocusNode(),
      child: GestureDetector(
        onDoubleTap: onDoubleTap,
        child: Center(
          child: SizedBox(
            width: 280,
            height: 34,
            child: TextField(
              autofocus: widget.autofocus,
              controller: _controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                filled: true,
                hintText: widget.hintText,
                prefixIcon: const Icon(
                  YaruIcons.search,
                  size: 15,
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 0),
                suffixIcon:
                    widget.searchQuery != null && widget.searchQuery!.isNotEmpty
                        ? SizedBox(
                            height: 30,
                            width: 30,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _clear,
                                child: Center(
                                  child: Icon(
                                    YaruIcons.edit_clear,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                suffixIconConstraints:
                    const BoxConstraints(maxWidth: 30, minHeight: 0),
                isDense: true,
                contentPadding: const EdgeInsets.all(8),
                fillColor:
                    light ? Colors.white : Theme.of(context).dividerColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.0,
                    color: borderColor,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.0,
                    color: borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.0,
                    color: theme.primaryColor,
                  ),
                ),
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
