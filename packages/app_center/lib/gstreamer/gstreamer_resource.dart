import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

typedef GstResource = ({
  String name,
  String id,
});

@immutable
class GstResourceCollection {
  const GstResourceCollection(this.list);

  final List<GstResource> list;

  @override
  int get hashCode => Object.hashAll(list);

  @override
  bool operator ==(Object other) {
    return other is GstResourceCollection && list.equals(other.list);
  }
}
