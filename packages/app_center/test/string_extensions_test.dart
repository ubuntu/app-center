import 'package:app_center/extensions/string_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('escapedMarkdown', () {
    const input =
        'A great image ![image](https://i.imgur.com/LlOSp3I.gif) and a great [link](https://en.wikipedia.org/wiki/List_of_lists_of_lists), right?';
    const expected =
        'A great image !\\[image](https://i.imgur.com/LlOSp3I.gif) and a great \\[link](https://en.wikipedia.org/wiki/List_of_lists_of_lists), right?';
    expect(input.escapedMarkdown(), expected);
  });

  test('escapedMarkdown with over multiple lines', () {
    const input = '''
A great [link that
spans over
multiple lines](https://en.wikipedia.org/wiki/List_of_lists_of_lists)
''';
    const expected = '''
A great \\[link that
spans over
multiple lines](https://en.wikipedia.org/wiki/List_of_lists_of_lists)
''';
    expect(input.escapedMarkdown(), expected);
  });
}
