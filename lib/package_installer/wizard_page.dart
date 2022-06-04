import 'package:flutter/material.dart';

/// The spacing between Continue and Back buttons.
const kButtonBarSpacing = 8.0;

/// The spacing between header, content, and footer.
const kContentSpacing = 20.0;

/// The padding around the content.
const kContentPadding = EdgeInsets.symmetric(horizontal: 24);

/// The padding around the header.
const kHeaderPadding = EdgeInsets.fromLTRB(24, 24, 24, 0);

/// The padding around the footer.
const kFooterPadding = EdgeInsets.fromLTRB(24, 0, 24, 24);

/// The fraction of content width in relation to the page.
const kContentWidthFraction = 0.7;

/// The size of a radio indicator.
const kRadioSize = Size.square(kMinInteractiveDimension - 8);

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
    this.headerPadding = kHeaderPadding,
    this.content,
    this.contentPadding = kContentPadding,
    this.footer,
    this.footerPadding = kFooterPadding,
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
          if (widget.header != null) const SizedBox(height: kContentSpacing),
          Expanded(
            child:
                Padding(padding: widget.contentPadding, child: widget.content),
          ),
          const SizedBox(height: kContentSpacing),
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
            const SizedBox(width: kContentSpacing),
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
