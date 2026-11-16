import 'package:app_center/appstream/appstream_service.dart';
import 'package:appstream/appstream.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'components_by_package_provider.g.dart';

/// Returns a map of package name -> Appstream component.
@riverpod
Future<Map<String, AppstreamComponent>> componentsByPackage(Ref ref) async {
  final appstream = getService<AppstreamService>();
  await appstream.init();
  return appstream.getComponentsByPackage();
}
