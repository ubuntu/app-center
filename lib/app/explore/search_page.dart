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
import 'package:software/app/common/app_banner.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/loading_banner_grid.dart';
import 'package:software/l10n/l10n.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.header,
    this.searchResult,
    this.preferSnap = true,
  });

  final Widget header;
  final Map<String, AppFinding>? searchResult;
  final bool preferSnap;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late ScrollController _controller;
  late int _searchResultAmount;

  @override
  void initState() {
    super.initState();
    _searchResultAmount = 30;

    _controller = ScrollController();
    _controller.addListener(() {
      if (_controller.position.maxScrollExtent == _controller.offset) {
        setState(() {
          _searchResultAmount = _searchResultAmount + 5;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchResult == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingExploreHeader(),
          Expanded(child: LoadingBannerGrid()),
        ],
      );
    }

    return Column(
      children: [
        widget.header,
        if (widget.searchResult!.isNotEmpty)
          Expanded(
            child: GridView.builder(
              controller: _controller,
              padding: const EdgeInsets.only(
                bottom: 15,
                right: 15,
                left: 15,
              ),
              gridDelegate: kGridDelegate,
              shrinkWrap: true,
              itemCount:
                  widget.searchResult!.entries.take(_searchResultAmount).length,
              itemBuilder: (context, index) {
                final appFinding =
                    widget.searchResult!.entries.elementAt(index);
                return AppBanner(
                  appFinding: appFinding,
                  showPackageKit: true,
                  showSnap: true,
                  preferSnap: widget.preferSnap,
                );
              },
            ),
          )
        else
          Expanded(
            child: _NoSearchResultPage(message: context.l10n.noPackageFound),
          ),
      ],
    );
  }
}

class _NoSearchResultPage extends StatelessWidget {
  const _NoSearchResultPage({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🐣❓',
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 400,
            child: Text(
              message,
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 25),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 200,
          ),
        ],
      ),
    );
  }
}
