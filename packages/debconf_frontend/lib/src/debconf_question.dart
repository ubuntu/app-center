/// The debconf template types that can be shown in a dialog.
enum DebconfQuestionType {
  string,
  password,
  boolean,
  select,
  multiselect,
  note,
  text,
  error,
}

/// A question that debconf asks while a package is being set up.
class DebconfQuestion {
  const DebconfQuestion({
    required this.name,
    required this.type,
    this.description = '',
    this.extendedDescription = '',
    this.choices = const [],
    this.value = '',
  });

  /// The template name, e.g. `tzdata/Areas`.
  final String name;

  final DebconfQuestionType type;

  /// A short prompt, or the heading of a note, text or error.
  final String description;

  /// The explanation shown above the input.
  final String extendedDescription;

  /// The translated choices of a select or multiselect question.
  final List<String> choices;

  /// The current value in debconf's format, e.g. `true` or `a, b`.
  final String value;
}

/// What the user did with a page of debconf questions.
sealed class DebconfDialogResult {
  const DebconfDialogResult();
}

/// The questions were answered; [values] has the value of every question.
final class DebconfAnswered extends DebconfDialogResult {
  const DebconfAnswered(this.values);

  final Map<String, String> values;
}

/// The user wants to go back to the previous questions.
final class DebconfWentBack extends DebconfDialogResult {
  const DebconfWentBack();
}

/// The user cancelled the setup.
final class DebconfCancelled extends DebconfDialogResult {
  const DebconfCancelled();
}
