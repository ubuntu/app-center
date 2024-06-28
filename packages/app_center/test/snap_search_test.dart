import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cleaned query', () {
    const searchParamters = SnapSearchParameters(
      query: 'a+b=c&d|e>f<g!h(i)j{k}l[m]n^o"p~q*r?s:t\\u/v',
    );
    expect(
      searchParamters.cleanedQuery,
      equals('a b c d e f g h i j k l m n o p q r s t u v'),
    );
  });
}
