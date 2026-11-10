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
