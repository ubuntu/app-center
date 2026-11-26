import 'package:app_center/apps/app_title_bar.dart';
import 'package:app_center/layout.dart';
import 'package:material_ui/material_ui.dart';

const _infoBarPadding = 32.0;

/// A page layout to display a single app and its associated actions.
class AppPage extends StatefulWidget {
  const AppPage({
    required this.titleBar,
    required this.actionBar,
    required this.infoBar,
    required this.body,
    this.selectable = false,
    super.key,
  });

  /// [AppTitleBar] to use for the top-most section of the app page.
  final Widget titleBar;

  /// Widget for package-specific actions like install, uninstall, etc.
  final Widget actionBar;

  /// App info bar for app metadata.
  final Widget infoBar;

  /// Extended app description and image content.
  final Widget body;

  /// Whether the page text is selectable as one piece.
  ///
  /// When enabled, the scrollable page content is wrapped in a
  /// [SelectionArea], so that the text of all page sections can be selected
  /// together, and dragging a selection past the viewport edge scrolls the
  /// page.
  final bool selectable;

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  final _scrollController = ScrollController();

  /// Excluded from the tab order, but focusable so that the selection
  /// shortcuts (Ctrl+C, Ctrl+A) keep working while text is selected.
  final _selectionFocusNode = FocusNode(skipTraversal: true);

  @override
  void dispose() {
    _scrollController.dispose();
    _selectionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context) {
        final layout = ResponsiveLayout.of(context);

        final Widget content = Column(
          children: [
            const SizedBox(height: kPagePadding),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Center(
                  child: SizedBox(
                    width: layout.totalWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: kPagePadding),
                        widget.titleBar,
                        const SizedBox(height: kPagePadding),
                        widget.actionBar,
                        const SizedBox(height: _infoBarPadding),
                        const Divider(),
                        const SizedBox(height: _infoBarPadding),
                        widget.infoBar,
                        const SizedBox(height: _infoBarPadding),
                        const Divider(),
                        const SizedBox(height: _infoBarPadding),
                        widget.body,
                        const SizedBox(height: kPagePadding),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

        // Provides a fallback for keyboard scrolling when focus is not within
        // the scroll view itself, e.g. on the selection area below.
        return PrimaryScrollController(
          controller: _scrollController,
          child: widget.selectable
              ? SelectionArea(
                  // Wrapping the scroll view instead of its contents makes the
                  // scroll view scroll when a selection is dragged past the
                  // viewport edge.
                  focusNode: _selectionFocusNode,
                  child: content,
                )
              : content,
        );
      },
    );
  }
}
