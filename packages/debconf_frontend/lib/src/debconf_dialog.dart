import 'package:debconf_frontend/src/debconf_question.dart';
import 'package:flutter/material.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/yaru.dart';

const _kDialogWidth = 500.0;
const _kDialogPadding = EdgeInsets.all(20);
const _kSpacingSmall = 8.0;
const _kSpacing = 16.0;
const _kQuestionSpacing = 24.0;

// Longer lists of choices are shown in a dropdown.
const _kMaxRadioChoices = 6;

// Debconf's passthrough frontend splits multiselect answers on this.
const _kValueSeparator = ', ';

/// Asks [questions] together, as debconf does for each GO command.
///
/// Only set [canGoBack] if the setup script supports it (`CAPB backup`).
Future<DebconfDialogResult> showDebconfDialog(
  BuildContext context, {
  required String title,
  required List<DebconfQuestion> questions,
  bool canGoBack = false,
}) async {
  final result = await showDialog<DebconfDialogResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => DebconfDialog(
      title: title,
      questions: questions,
      canGoBack: canGoBack,
    ),
  );
  return result ?? const DebconfCancelled();
}

/// A page of debconf questions, see [showDebconfDialog].
class DebconfDialog extends StatefulWidget {
  const DebconfDialog({
    required this.title,
    required this.questions,
    this.canGoBack = false,
    super.key,
  });

  final String title;
  final List<DebconfQuestion> questions;
  final bool canGoBack;

  @override
  State<DebconfDialog> createState() => _DebconfDialogState();
}

class _DebconfDialogState extends State<DebconfDialog> {
  late final _values = <String, String>{
    for (final question in widget.questions)
      question.name: _initialValue(question),
  };

  void _close(DebconfDialogResult result) => Navigator.of(context).pop(result);

  @override
  Widget build(BuildContext context) {
    final l10n = UbuntuLocalizations.of(context);
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitleBar(title: Text(widget.title)),
      contentPadding: _kDialogPadding,
      content: SizedBox(
        width: _kDialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: _kQuestionSpacing,
                  children: [
                    for (final question in widget.questions)
                      _QuestionView(
                        question: question,
                        value: _values[question.name]!,
                        onChanged: (value) =>
                            setState(() => _values[question.name] = value),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: _kQuestionSpacing),
            Row(
              spacing: _kSpacingSmall,
              children: [
                if (widget.canGoBack)
                  PushButton.outlined(
                    onPressed: () => _close(const DebconfWentBack()),
                    child: Text(l10n.backLabel),
                  ),
                const Spacer(),
                PushButton.outlined(
                  onPressed: () => _close(const DebconfCancelled()),
                  child: Text(l10n.cancelLabel),
                ),
                PushButton.elevated(
                  onPressed: () => _close(DebconfAnswered(Map.of(_values))),
                  child: Text(l10n.continueLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _initialValue(DebconfQuestion question) => switch (question.type) {
  DebconfQuestionType.boolean => '${question.value == 'true'}',
  DebconfQuestionType.select when !question.choices.contains(question.value) =>
    question.choices.isEmpty ? '' : question.choices.first,
  _ => question.value,
};

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final DebconfQuestion question;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      question.description,
      style: Theme.of(context).textTheme.titleSmall,
    );
    return switch (question.type) {
      DebconfQuestionType.note => _message(YaruInfoType.information),
      DebconfQuestionType.error => _message(YaruInfoType.danger),
      DebconfQuestionType.text => _labeled(
        label,
        Text(question.extendedDescription),
      ),
      DebconfQuestionType.boolean => _explained(_checkbox()),
      DebconfQuestionType.string || DebconfQuestionType.password => _explained(
        _labeled(
          label,
          _TextInput(
            value: value,
            obscureText: question.type == DebconfQuestionType.password,
            onChanged: onChanged,
          ),
        ),
      ),
      DebconfQuestionType.select
          when question.choices.length > _kMaxRadioChoices =>
        _explained(_labeled(label, _dropdown())),
      DebconfQuestionType.select => _explained(
        _labeled(label, _radioButtons()),
      ),
      DebconfQuestionType.multiselect => _explained(
        _labeled(label, _checkboxes()),
      ),
    };
  }

  Widget _explained(Widget input) => question.extendedDescription.isEmpty
      ? input
      : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: _kSpacing,
          children: [Text(question.extendedDescription), input],
        );

  Widget _labeled(Widget label, Widget input) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: _kSpacingSmall,
    children: [label, input],
  );

  Widget _message(YaruInfoType type) => question.extendedDescription.isEmpty
      ? YaruInfoBox(yaruInfoType: type, subtitle: Text(question.description))
      : YaruInfoBox(
          yaruInfoType: type,
          title: Text(question.description),
          subtitle: Text(question.extendedDescription),
        );

  Widget _checkbox() => CheckboxListTile(
    value: value == 'true',
    onChanged: (checked) => onChanged('${checked ?? false}'),
    title: Text(question.description),
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
  );

  Widget _radioButtons() => RadioGroup<String>(
    groupValue: value,
    onChanged: (choice) => onChanged(choice ?? value),
    child: Column(
      children: [
        for (final choice in question.choices)
          RadioListTile<String>(
            value: choice,
            title: Text(choice),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
      ],
    ),
  );

  Widget _dropdown() => MenuButtonBuilder<String>(
    values: question.choices,
    selected: value,
    onSelected: onChanged,
    itemBuilder: (context, choice, _) => Text(choice),
    menuPosition: PopupMenuPosition.under,
  );

  Widget _checkboxes() {
    final selected = value.split(_kValueSeparator).toSet();
    return Column(
      children: [
        for (final choice in question.choices)
          CheckboxListTile(
            value: selected.contains(choice),
            onChanged: (checked) => onChanged(
              question.choices
                  .where(
                    (c) =>
                        c == choice ? checked ?? false : selected.contains(c),
                  )
                  .join(_kValueSeparator),
            ),
            title: Text(choice),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
      ],
    );
  }
}

class _TextInput extends StatefulWidget {
  const _TextInput({
    required this.value,
    required this.obscureText,
    required this.onChanged,
  });

  final String value;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    obscureText: widget.obscureText,
    onChanged: widget.onChanged,
  );
}
