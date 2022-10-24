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
import 'package:software/store_app/common/constants.dart';

/// The padding around the content.
const _kWizardContentPadding = EdgeInsets.symmetric(horizontal: 24);

/// The padding around the header.
const _kWizardHeaderPadding = EdgeInsets.fromLTRB(24, 24, 24, 0);

/// The padding around the footer.
const _kWizardFooterPadding = EdgeInsets.fromLTRB(24, 0, 24, 24);

/// The base for wizard pages in the installer.
///
/// Provides the appropriate layout and the common building blocks for
/// installation wizard pages.
class WizardPage extends StatefulWidget {
  /// Creates the wizard page.
  const WizardPage({
    Key? key,
    this.title,
    this.header,
    this.headerPadding = _kWizardHeaderPadding,
    this.content,
    this.contentPadding = _kWizardContentPadding,
    this.footer,
    this.footerPadding = _kWizardFooterPadding,
    this.actions = const <Widget>[],
  }) : super(key: key);

  /// The title widget in the app bar.
  final Widget? title;

  /// A header widget below the title.
  final Widget? header;

  /// Padding around the header widget.
  ///
  /// The default value is `kHeaderPadding`.
  final EdgeInsetsGeometry headerPadding;

  /// A content widget laid out below the header.
  final Widget? content;

  /// Padding around the content widget.
  ///
  /// The default value is `kContentPadding`.
  final EdgeInsetsGeometry contentPadding;

  /// A footer widget on the side of the buttons.
  final Widget? footer;

  /// Padding around the footer widget.
  ///
  /// The default value is `kFooterPadding`.
  final EdgeInsetsGeometry footerPadding;

  /// A list of actions in the button bar.
  final List<Widget> actions;

  @override
  State<WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends State<WizardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: widget.title, automaticallyImplyLeading: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: widget.headerPadding,
            child: widget.header != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: widget.header,
                  )
                : null,
          ),
          if (widget.header != null) const SizedBox(height: kPagePadding),
          Expanded(
            child:
                Padding(padding: widget.contentPadding, child: widget.content),
          ),
          const SizedBox(height: kPagePadding),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: widget.footerPadding,
        child: Row(
          mainAxisAlignment: widget.footer != null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          children: <Widget>[
            if (widget.footer != null) Expanded(child: widget.footer!),
            const SizedBox(width: kPagePadding),
            ButtonBar(
              buttonPadding: EdgeInsets.zero,
              children: widget.actions,
            ),
          ],
        ),
      ),
    );
  }
}
